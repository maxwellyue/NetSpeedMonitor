import AppKit
import Foundation
import SwiftUI

struct MenuBarLabel: View {
    @StateObject var monitor: NetworkMonitor = .init()

    private var renderedIcon: NSImage? {
        let renderer = ImageRenderer(content: MenuBarLabelContent(throughput: monitor.throughput))
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 3
        renderer.isOpaque = false
        guard let nsImage = renderer.nsImage else { return nil }
        nsImage.isTemplate = true
        return nsImage
    }

    var body: some View {
        Group {
            if let image = renderedIcon {
                Image(nsImage: image)
                    .frame(width: 66, height: 22)
            } else {
                Text(verbatim: "UI Error")
            }
        }
        .tag("MenuBarIcon")
    }
}

#Preview {
    MenuBarLabel()
        .padding()
}
