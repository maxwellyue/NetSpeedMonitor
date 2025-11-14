import os.log
import SwiftUI

public var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "elegracer")

struct MenuContentView: View {
    @ObservedObject var profiles: Profiles = .shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Section {
                HStack {
                    Toggle("Start at Login", isOn: $profiles.autoLaunchEnabled)
                        .toggleStyle(.button)
                        .onChange(of: profiles.autoLaunchEnabled, initial: false) { oldState, newState in
                            logger.info("Toggle::StartAtLogin: oldState：\(oldState), newState: \(newState)")
                        }
                }.fixedSize()
            }

            Divider()

            Section {
                HStack {
                    ForEach(NetSpeedUpdateInterval.allCases) { interval in
                        Toggle(
                            interval.displayName,
                            isOn: Binding(
                                get: { profiles.netSpeedUpdateInterval == interval },
                                set: { if $0 { profiles.netSpeedUpdateInterval = interval } }
                            )
                        )
                        .toggleStyle(.button)
                    }
                }
            } header: {
                Text("Update Interval")
            }

            Divider()

            Section {
                Button("Open Activity Monitor", action: onClickOpenActivityMonitor)
            }

            Divider()

            Section {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .fixedSize()
    }

    private func onClickOpenActivityMonitor() {
        let bundleID = "com.apple.ActivityMonitor"
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            let config = NSWorkspace.OpenConfiguration()
            config.activates = true

            NSWorkspace.shared.openApplication(at: appURL,
                                               configuration: config,
                                               completionHandler: { _, error in
                                                   if let error = error {
                                                       logger.warning("Open Activity Monitor failed: \(error.localizedDescription)")
                                                   } else {
                                                       logger.info("Open Activity Monitor succeeded.")
                                                   }
                                               })
        } else {
            logger.warning("Cannot find Activity Monitor.")
        }
    }
}
