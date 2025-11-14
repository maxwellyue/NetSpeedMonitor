//
//  MenuBarLabelContent.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/13.
//
import SwiftUI

struct MenuBarLabelContent: View {
    var throughput: NetworkThroughput?

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if let throughput {
                Text(verbatim: "↑ \(NetworkThroughput.format(bytes: throughput.txBps))/s")
                Text(verbatim: "↓ \(NetworkThroughput.format(bytes: throughput.rxBps))/s")
            } else {
                Text(verbatim: "↑ --/s")
                Text(verbatim: "↓ --/s")
            }
        }
        .font(.system(size: 8, weight: .bold, design: .rounded))
        .monospacedDigit()
        .frame(height: 22, alignment: .trailing)
    }
}

extension NetworkThroughput {
    static func format(bytes: Double) -> String {
        let formatter = ByteCountFormatter.byteFormatter
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
