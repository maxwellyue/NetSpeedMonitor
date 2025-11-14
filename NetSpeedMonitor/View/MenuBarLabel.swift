import AppKit
import Foundation
import SwiftUI

struct MenuBarLabel: View {
    @StateObject var monitor: NetworkMonitor = .init()

    var body: some View {
        Group {
            if let image = MenuBarLabelContent(throughput: monitor.throughput).snapshot() {
                Image(nsImage: image)
                    .frame(width: 66, height: 22)
            } else {
                Text(verbatim: "UI Error")
            }
        }
    }
}

#Preview {
    MenuBarLabel()
        .padding()
}
