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
        WindowGroup("自定义", id: WindowID.menuBarLabelStyleView.rawValue) {
            MenuBarLabelStyleView()
        }
        .windowResizability(.contentSize)
        .windowIdealSize(.fitToContent)
    }
}

enum WindowID: String {
    case menuBarLabelStyleView
}
