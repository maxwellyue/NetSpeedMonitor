import AppKit
import Foundation
import SwiftUI

struct MenuBarLabel: View {
    @StateObject var monitor: NetworkMonitor = .init()
    @ObservedObject var profiles: Profiles = .shared

    var style: MenuBarLabelStyle {
        profiles.style
    }

    var image: NSImage? {
        MenuBarLabelTemplate(throughput: monitor.throughput, style: profiles.style)
            .snapshot(isTemplate: profiles.style.foreground.isTemplate)
    }

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
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
