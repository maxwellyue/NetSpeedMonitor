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

    struct InterfaceByteCounters {
        let rx: UInt64
        let tx: UInt64
    }
}

struct NetworkThroughput {
    let rxBps: Double
    let txBps: Double
}
