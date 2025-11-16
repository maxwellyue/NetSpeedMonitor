//
//  MenuBarLabelTemplate.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/15.
//

import SwiftUI

struct MenuBarLabelTemplate: View {
    let throughput: NetworkThroughput?
    let lines: MenuBarLabelStyle.LayoutDirection
    let icon: MenuBarLabelStyle.Icon
    let foreground: MenuBarLabelStyle.ForegroundStyle
    let fontDesign: MenuBarLabelStyle.FontDesign

    init(throughput: NetworkThroughput?, lines: MenuBarLabelStyle.LayoutDirection, icon: MenuBarLabelStyle.Icon, foreground: MenuBarLabelStyle.ForegroundStyle, fontDesign: MenuBarLabelStyle.FontDesign) {
        self.throughput = throughput
        self.lines = lines
        self.icon = icon
        self.foreground = foreground
        self.fontDesign = fontDesign
    }

    init(throughput: NetworkThroughput?, style: MenuBarLabelStyle) {
        self.throughput = throughput
        self.lines = style.lines
        self.icon = style.icon
        self.foreground = style.foreground
        self.fontDesign = style.fontDesign
    }

    @ViewBuilder
    func text(_ value: Double?) -> Text {
        Text(verbatim: "\(NetworkThroughput.formatted(value))")
    }

    func iconSize(for layout: MenuBarLabelStyle.LayoutDirection) -> CGFloat {
        switch layout {
        case .horizontal: return 8
        case .vertical: return 6
        }
    }

    func spacing(for layout: MenuBarLabelStyle.LayoutDirection) -> CGFloat {
        switch layout {
        case .horizontal: return 2
        case .vertical: return 2
        }
    }

    @ViewBuilder
    func lines(for layout: MenuBarLabelStyle.LayoutDirection) -> some View {
        ForEach(TrafficFlow.allCases, id: \.self) { flow in
            Group {
                if let imageName = icon.imageName(for: flow) {
                    HStack(spacing: spacing(for: layout)) {
                        Image(systemName: imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconSize(for: layout), height: iconSize(for: layout))
                            .fontWeight(.bold)
                        text(throughput?[flow])
                    }
                } else {
                    text(throughput?[flow])
                }
            }
            .foreground(foreground, for: flow)
        }
    }

    var body: some View {
        Group {
            switch lines {
            case .horizontal:
                HStack(spacing: 8) {
                    lines(for: .horizontal)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .font(.system(size: 12, weight: .regular, design: self.fontDesign.design))
            case .vertical:
                VStack(alignment: .trailing, spacing: 0) {
                    lines(for: .vertical)
                }
                .font(.system(size: 8, weight: .regular, design: self.fontDesign.design))
            }
        }
        .monospacedDigit()
        .frame(height: 22, alignment: .trailing)
    }
}

#Preview {
    MenuBarLabelTemplate(throughput: .init(rxBps: 120, txBps: 200),
                         lines: .horizontal,
                         icon: .arrows,
                         foreground: .template,
                         fontDesign: .rounded)
}
