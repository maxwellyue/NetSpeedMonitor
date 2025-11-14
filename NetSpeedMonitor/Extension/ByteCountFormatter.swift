//
//  ByteCountFormatter.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/14.
//
import Foundation

extension ByteCountFormatter {
    static let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        formatter.allowsNonnumericFormatting = false
        return formatter
    }()
}
