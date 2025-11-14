//
//  NetworkMonitor.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/14.
//

import SwiftUI

class NetworkMonitor: ObservableObject {
    @Published var throughput: NetworkThroughput?

    private var timerTask: Task<Void, Never>?
    private var previousCounters: NetworkCounters = .get()

    private func startTimer() {
        timerTask = Task {
            while !Task.isCancelled {
                let netSpeedUpdateInterval = await Profiles.shared.netSpeedUpdateInterval
                let current = NetworkCounters.get()
                let newSpeed = NetworkThroughput.calculate(from: previousCounters, to: current, interval: Double(netSpeedUpdateInterval.rawValue))
                logger.info("current txBytes: \(String(format: "%.6f", newSpeed.txBps)) B/s, rtBytes: \(String(format: "%.6f", newSpeed.rxBps)) B/s")
                await MainActor.run {
                    self.throughput = newSpeed
                }
                self.previousCounters = current
                try? await Task.sleep(for: .seconds(Double(netSpeedUpdateInterval.rawValue)))
            }
        }
        logger.info("startTimer")
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
        logger.info("stopTimer")
    }

    init() {
        self.startTimer()
    }

    deinit {
        self.stopTimer()
    }
}

extension NetworkCounters {
    static func get() -> NetworkCounters {
        var addrsPtr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addrsPtr) == 0, let firstAddr = addrsPtr else {
            logger.error("getifaddrs failed")
            return NetworkCounters(totalRxBytes: 0, totalTxBytes: 0, perInterface: [:])
        }

        defer { freeifaddrs(addrsPtr) }

        var totalRx: UInt64 = 0
        var totalTx: UInt64 = 0
        var perInterface: [String: InterfaceCounters] = [:]

        var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let current = ptr?.pointee {
            defer { ptr = current.ifa_next }

            guard let cName = current.ifa_name,
                  let name = String(validatingUTF8: cName) else { continue }

            let flags = Int32(current.ifa_flags)
            let isUp = (flags & IFF_UP) != 0
            let isLoopback = (flags & IFF_LOOPBACK) != 0
            if !isUp || isLoopback { continue }

            if let dataPtr = current.ifa_data {
                let ifdata = dataPtr.load(as: if_data.self)
                let rx = UInt64(ifdata.ifi_ibytes)
                let tx = UInt64(ifdata.ifi_obytes)

                // 只统计特定接口
                if name.hasPrefix("en") || name.hasPrefix("awdl") || name == "p2p0" {
                    totalRx += rx
                    totalTx += tx
                    perInterface[name] = InterfaceCounters(rxBytes: rx, txBytes: tx)
                }
            }
        }

        // 如果没有任何统计数据，也返回 nil
        guard !perInterface.isEmpty else {
            logger.error("perInterface is empty")
            return NetworkCounters(totalRxBytes: 0, totalTxBytes: 0, perInterface: [:])
        }
        return NetworkCounters(totalRxBytes: totalRx, totalTxBytes: totalTx, perInterface: perInterface)
    }
}

extension NetworkThroughput {
    static func calculate(from previous: NetworkCounters, to current: NetworkCounters, interval: TimeInterval) -> NetworkThroughput {
        let deltaRx = Double(current.totalRxBytes - previous.totalRxBytes)
        let deltaTx = Double(current.totalTxBytes - previous.totalTxBytes)
        guard interval > 0 else {
            logger.error("interval is zero or less than zero.")
            return NetworkThroughput(rxBps: 0, txBps: 0)
        }
        return NetworkThroughput(rxBps: deltaRx / interval, txBps: deltaTx / interval)
    }
}
