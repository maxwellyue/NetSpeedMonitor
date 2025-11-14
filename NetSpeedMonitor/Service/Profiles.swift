import SwiftUI

@MainActor
class Profiles: ObservableObject {
    static let shared = Profiles()

    @AppStorage("AutoLaunchEnabled") var autoLaunchEnabled: Bool = false {
        didSet {
            do {
                try SMAppServiceManager.autoLaunch(enable: self.autoLaunchEnabled)
            } catch {
                autoLaunchEnabled = SMAppServiceManager.isAutoLaunchEnabled
            }
        }
    }

    @AppStorage("NetSpeedUpdateInterval") var netSpeedUpdateInterval: NetSpeedUpdateInterval = .Sec1

    init() {
        self.autoLaunchEnabled = SMAppServiceManager.isAutoLaunchEnabled
    }
}
