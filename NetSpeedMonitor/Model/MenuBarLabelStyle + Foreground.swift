//
//  MenuBarLabelStyle + Foreground.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/15.
//

import SwiftUI

extension MenuBarLabelStyle {
    enum ForegroundStyle: Hashable, Codable {
        case template
        case accented(tx: CodableColor, rx: CodableColor)

        var isTemplate: Bool {
            switch self {
            case .template: return true
            case .accented: return false
            }
        }
    }
}

extension View {
    @ViewBuilder
    func foreground(_ style: MenuBarLabelStyle.ForegroundStyle, for flow: TrafficFlow) -> some View {
        switch style {
        case .template:
            self
        case .accented(let tx, let rx):
            switch flow {
            case .tx:
                self.foregroundStyle(tx.color)
            case .rx:
                self.foregroundStyle(rx.color)
            }
        }
    }
}
