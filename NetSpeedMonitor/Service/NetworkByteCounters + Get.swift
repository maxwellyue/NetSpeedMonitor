//
//  NetworkByteCounters + Get.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/16.
//
import Foundation

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
