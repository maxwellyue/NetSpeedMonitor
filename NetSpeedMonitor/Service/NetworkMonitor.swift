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
    private var previousCounters: NetworkByteCounters = .get()

    private func startTimer() {
        timerTask = Task {
            while !Task.isCancelled {
                let netSpeedUpdateInterval = await Profiles.shared.netSpeedUpdateInterval
                let current = NetworkByteCounters.get()
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

extension NetworkByteCounters {
    static func get() -> NetworkByteCounters {
        var addrsPtr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addrsPtr) == 0, let firstAddr = addrsPtr else {
            logger.error("getifaddrs failed")
            return NetworkByteCounters(rx: 0, tx: 0, perInterface: [:])
        }

        defer { freeifaddrs(addrsPtr) }

        var totalRx: UInt64 = 0
        var totalTx: UInt64 = 0
        var perInterface: [String: InterfaceByteCounters] = [:]

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
                    perInterface[name] = InterfaceByteCounters(rx: rx, tx: tx)
                }
            }
        }

        // 如果没有任何统计数据，也返回 nil
        guard !perInterface.isEmpty else {
            logger.error("perInterface is empty")
            return NetworkByteCounters(rx: 0, tx: 0, perInterface: [:])
        }
        return NetworkByteCounters(rx: totalRx, tx: totalTx, perInterface: perInterface)
    }
}

extension NetworkThroughput {
    static func calculate(from previous: NetworkByteCounters, to current: NetworkByteCounters, interval: TimeInterval) -> NetworkThroughput {
        @inline(__always)
        func safeDelta(_ current: UInt64, _ previous: UInt64) -> Double {
            if current >= previous {
                return Double(current - previous)
            } else {
                // 计数器回绕或重置
                return Double(UInt64.max - previous) + Double(current) + 1.0
            }
        }

        let deltaRx = safeDelta(current.rx, previous.rx)
        let deltaTx = safeDelta(current.tx, previous.tx)
        guard interval > 0 else {
            logger.error("interval is zero or less than zero.")
            return NetworkThroughput(rxBps: 0, txBps: 0)
        }
        return NetworkThroughput(rxBps: deltaRx / interval, txBps: deltaTx / interval)
    }
}
