//
//  NetworkThroughput + Calculate.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/16.
//
import Foundation

extension NetworkThroughput {
    private static func safeDelta(_ current: UInt64, _ previous: UInt64) -> Double {
        // 正常递增：最常见情况
        if current >= previous {
            let delta = Double(current - previous)
            logger.trace("Delta OK — previous: \(previous), current: \(current), delta: \(delta)")
            return delta
        }

        // previous > current：需要判断 reset/ wrap
        let diff = Double(previous) - Double(current)
        let resetThreshold = 256.0 * 1024.0 * 1024.0 // 256 MB

        if diff > resetThreshold {
            // 情况 A：reset（接口重置、网络切换、系统唤醒等）
            logger.notice("""
                NIC Counter Reset Detected —
                previous: \(previous),
                current: \(current),
                diff: \(diff),
                threshold: \(resetThreshold)
            """)
            return Double(current)
        } else {
            // 情况 B：真正 wrap-around（理论上极少发生）
            let wrapped = Double(UInt64.max - previous) + Double(current) + 1.0
            logger.warning("""
                NIC Counter Wrap-Around —
                previous: \(previous),
                current: \(current),
                diff: \(diff),
                computedWrapDelta: \(wrapped)
            """)
            return wrapped
        }
    }

    static func calculate(from previous: NetworkByteCounters, to current: NetworkByteCounters, interval: TimeInterval) -> NetworkThroughput {
        let deltaRx = safeDelta(current.rx, previous.rx)
        let deltaTx = safeDelta(current.tx, previous.tx)
        guard interval > 0 else {
            logger.error("interval is zero or less than zero.")
            return NetworkThroughput(rxBps: 0, txBps: 0)
        }
        return NetworkThroughput(rxBps: deltaRx / interval, txBps: deltaTx / interval)
    }

    static func formatted(_ value: Double?) -> String {
        guard let value, value.isFinite, value >= 0 else {
            return "--/s"
        }

        // 避免 Double 精度误差造成的 Int64 溢出
        if value >= Double(Int64.max - 1024) {
            logger.error("value is greater than Int64 range.")
            return "\(ByteCountFormatter.byteFormatter.string(fromByteCount: Int64.max))/s"
        }

        // 四舍五入，但避免越界
        let r = value.rounded(.toNearestOrAwayFromZero)
        let clamped = min(r, Double(Int64.max))
        let rounded = Int64(clamped)
        return "\(ByteCountFormatter.byteFormatter.string(fromByteCount: rounded))/s"
    }
}
