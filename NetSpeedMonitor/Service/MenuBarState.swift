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

    @Published var throughput: NetworkThroughput?

    private var timerTask: Task<Void, Never>?
    private var previousCounters: NetworkCounters = .get()

    private func startTimer() {
        timerTask = Task {
            while !Task.isCancelled {
                let current = NetworkCounters.get()
                let newSpeed = NetworkThroughput.calculate(from: previousCounters, to: current, interval: Double(netSpeedUpdateInterval.rawValue))
                logger.info("current txBytes: \(String(format: "%.6f", newSpeed.txBps)) B/s, rtBytes: \(String(format: "%.6f", newSpeed.rxBps)) B/s")
                await MainActor.run {
                    self.throughput = newSpeed
                }
                self.previousCounters = current
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
