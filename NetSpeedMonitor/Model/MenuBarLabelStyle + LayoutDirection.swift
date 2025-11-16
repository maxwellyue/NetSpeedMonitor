//
//  MenuBarLabelStyle + LayoutDirection.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/15.
//
import Foundation

extension MenuBarLabelStyle {
    enum LayoutDirection: String, CaseIterable, Codable {
        case horizontal
        case vertical

        var displayName: LocalizedStringResource {
            switch self {
            case .horizontal: return "Horizontal"
            case .vertical: return "Vertical"
            }
        }
    }
}
