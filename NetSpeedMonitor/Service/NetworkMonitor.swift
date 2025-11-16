//
//  NetworkMonitor.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/14.
//

import SwiftUI

class NetworkMonitor: ObservableObject {
    @Published var throughput: NetworkThroughput?

    private var timerTask: Task<Void, Never>?
    private var previousCounters: NetworkByteCounters = .get()
    private var previousSampleTime: ContinuousClock.Instant?
    private let clock = ContinuousClock()

    private func startTimer() {
        timerTask = Task {
            while !Task.isCancelled {
                let netSpeedUpdateInterval = await Profiles.shared.netSpeedUpdateInterval
                let current = NetworkByteCounters.get()
                let sampleTime = clock.now

                guard let previousSampleTime else {
                    self.previousSampleTime = sampleTime
                    self.previousCounters = current
                    try? await Task.sleep(for: .seconds(Double(netSpeedUpdateInterval.rawValue)))
                    continue
                }

                let elapsed = previousSampleTime.duration(to: sampleTime)
                let intervalSeconds = elapsed.secondsDouble
                guard intervalSeconds > 0 else {
                    self.previousSampleTime = sampleTime
                    self.previousCounters = current
                    try? await Task.sleep(for: .seconds(Double(netSpeedUpdateInterval.rawValue)))
                    continue
                }

                let newSpeed = NetworkThroughput.calculate(from: previousCounters, to: current, interval: intervalSeconds)
                logger.info("current txBytes: \(String(format: "%.6f", newSpeed.txBps)) B/s, rtBytes: \(String(format: "%.6f", newSpeed.rxBps)) B/s")
                await MainActor.run {
                    self.throughput = newSpeed
                }
                self.previousCounters = current
                self.previousSampleTime = sampleTime
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
        self.startTimer()
    }

    deinit {
        self.stopTimer()
    }
}

private extension Duration {
    var secondsDouble: Double {
        let components = self.components
        let attosecondsPerSecond = 1_000_000_000_000_000_000.0
        return Double(components.seconds) + Double(components.attoseconds) / attosecondsPerSecond
    }
}
