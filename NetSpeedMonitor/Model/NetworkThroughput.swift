//
//  NetworkSpeed.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/14.
//
import Darwin
import Foundation

/// total RxBytes, total TxBytes, per interface
struct NetworkByteCounters {
    let rx: UInt64
    let tx: UInt64
    let perInterface: [String: InterfaceByteCounters]

    subscript(flow: TrafficFlow) -> UInt64 {
        switch flow {
        case .rx: return rx
        case .tx: return tx
        }
    }

    struct InterfaceByteCounters {
        let rx: UInt64
        let tx: UInt64
    }
}

struct NetworkThroughput {
    let rxBps: Double
    let txBps: Double

    subscript(flow: TrafficFlow) -> Double {
        switch flow {
        case .rx: return rxBps
        case .tx: return txBps
        }
    }
}

enum TrafficFlow: CaseIterable {
    case tx
    case rx
}
