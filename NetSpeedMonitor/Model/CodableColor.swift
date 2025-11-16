//
//  CodableColor.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/15.
//
import AppKit
import SwiftUI

struct CodableColor: Codable, Hashable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(_ color: Color) {
        let nsColor = NSColor(color)
        // 转换为 sRGB 颜色空间，确保可以安全访问 RGB 组件
        guard let rgbColor = nsColor.usingColorSpace(.sRGB) else {
            // 如果转换失败，使用默认的白色
            logger.error("Failed to convert color to sRGB, using white as fallback")
            self.red = 1.0
            self.green = 1.0
            self.blue = 1.0
            self.alpha = 1.0
            return
        }

        self.red = Double(rgbColor.redComponent)
        self.green = Double(rgbColor.greenComponent)
        self.blue = Double(rgbColor.blueComponent)
        self.alpha = Double(rgbColor.alphaComponent)
    }

    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
