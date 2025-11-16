//
//  MenuBarLabelStyle + FontDesign.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/15.
//
import SwiftUI

extension MenuBarLabelStyle {
    enum FontDesign: String, CaseIterable, Codable {
        case `default`
        case monospaced
        case rounded
        case serif

        init(_ design: Font.Design) {
            switch design {
            case .default: self = .default
            case .monospaced: self = .monospaced
            case .rounded: self = .rounded
            case .serif: self = .serif
            @unknown default: self = .default
            }
        }

        var design: Font.Design {
            switch self {
            case .default: return .default
            case .monospaced: return .monospaced
            case .rounded: return .rounded
            case .serif: return .serif
            }
        }

        var displayName: LocalizedStringResource {
            switch self {
            case .default: return "Default"
            case .monospaced: return "Monospaced"
            case .rounded: return "Rounded"
            case .serif: return "Serif"
            }
        }
    }
}
