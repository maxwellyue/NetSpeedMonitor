//
//  NetworkThroughput + Calculate.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/16.
//
import Foundation

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
