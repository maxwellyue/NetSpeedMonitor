import SwiftUI

class MenuBarState: ObservableObject {
    @AppStorage("AutoLaunchEnabled") var autoLaunchEnabled: Bool = false {
        didSet {
            do {
                try SMAppServiceManager.autoLaunch(enable: self.autoLaunchEnabled)
            } catch {
                autoLaunchEnabled = SMAppServiceManager.isAutoLaunchEnabled
            }
        }
    }

    @AppStorage("NetSpeedUpdateInterval") var netSpeedUpdateInterval: NetSpeedUpdateInterval = .Sec1 {
        didSet {
            logger.info("netSpeedUpdateInterval, \(self.netSpeedUpdateInterval.displayName)")
            stopTimer()
            startTimer()
        }
    }

    @Published var traffic: NetTraffic?

    private var timerTask: Task<Void, Never>?
    private var netTrafficStat = NetTrafficStatReceiver()

    private func startTimer() {
        timerTask = Task {
            while !Task.isCancelled {
                let traffic = NetTraffic.current(using: netTrafficStat)
                await MainActor.run {
                    self.traffic = traffic
                }
                try? await Task.sleep(for: .seconds(Double(netSpeedUpdateInterval.rawValue)))
            }
        }
        logger.info("startTimer")
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
        logger.info("stopTimer")
    }

    init() {
        self.autoLaunchEnabled = SMAppServiceManager.isAutoLaunchEnabled
        self.startTimer()
    }

    deinit {
        self.stopTimer()
    }
}
