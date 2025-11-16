import SwiftUI

@main
struct NetSpeedMonitorApp: App {
    var body: some Scene {
        MenuBarExtra {
            MenuContentView()
        } label: {
            MenuBarLabel()
        }
        .menuBarExtraStyle(.menu)

        // 自定义窗口
        WindowGroup("Customize", id: WindowID.menuBarLabelStyleView.rawValue) {
            MenuBarLabelStyleView()
        }
        .windowIdealSize(.fitToContent)
    }
}

enum WindowID: String {
    case menuBarLabelStyleView
}
