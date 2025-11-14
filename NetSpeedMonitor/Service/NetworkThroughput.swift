//
//  NetworkSpeed.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/14.
//
import Darwin
import Foundation

struct NetworkCounters {
    let totalRxBytes: UInt64
    let totalTxBytes: UInt64
    let perInterface: [String: InterfaceCounters]

    struct InterfaceCounters {
        let rxBytes: UInt64
        let txBytes: UInt64
    }
}

struct NetworkThroughput {
    let rxBps: Double
    let txBps: Double
}
