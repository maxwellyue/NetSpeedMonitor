//
//  MenuBarLabelContent.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/13.
//
import SwiftUI

struct MenuBarLabelContent: View {
    var traffic: NetTraffic?

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if let traffic {
                Text("↑ \(formatSpeed(bytes: traffic.outBytes))/s")
                Text("↓ \(formatSpeed(bytes: traffic.inBytes))/s")
            } else {
                Text("↑ --/s")
                Text("↓ --/s")
            }
        }
        .font(.system(size: 8, weight: .bold, design: .rounded))
        .monospacedDigit()
        .frame(height: 22, alignment: .trailing)
    }

    private func formatSpeed(bytes: Double) -> String {
        let clampedBytes = max(0, bytes)
        return Self.byteFormatter.string(fromByteCount: Int64(clampedBytes))
    }
}

extension MenuBarLabelContent {
    static let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        formatter.allowsNonnumericFormatting = false
        return formatter
    }()
}
