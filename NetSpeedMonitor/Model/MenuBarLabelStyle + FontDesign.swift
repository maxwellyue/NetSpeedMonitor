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

        var displayName: String {
            switch self {
            case .default: return "默认"
            case .monospaced: return "等宽"
            case .rounded: return "圆角"
            case .serif: return "衬线"
            }
        }
    }
}
