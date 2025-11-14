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
    }
}
