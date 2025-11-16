//
//  MenuBarLabelStyle.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/14.
//
import SwiftUI

struct MenuBarLabelStyle: Equatable {
    var lines: LayoutDirection
    var icon: Icon
    var foreground: ForegroundStyle
    var fontDesign: FontDesign

    init(lines: LayoutDirection, icon: Icon, foreground: ForegroundStyle, fontDesign: FontDesign) {
        self.lines = lines
        self.icon = icon
        self.foreground = foreground
        self.fontDesign = fontDesign
    }

    static let `default` = MenuBarLabelStyle(lines: .horizontal, icon: .arrows, foreground: .template, fontDesign: .rounded)
}

extension MenuBarLabelStyle: Codable {
    enum CodingKeys: String, CodingKey {
        case lines
        case icon
        case foreground
        case fontDesign
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lines = try container.decode(LayoutDirection.self, forKey: .lines)
        self.icon = try container.decode(Icon.self, forKey: .icon)
        self.foreground = try container.decode(ForegroundStyle.self, forKey: .foreground)
        self.fontDesign = try container.decode(FontDesign.self, forKey: .fontDesign)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lines, forKey: .lines)
        try container.encode(icon, forKey: .icon)
        try container.encode(foreground, forKey: .foreground)
        try container.encode(fontDesign, forKey: .fontDesign)
    }
}
