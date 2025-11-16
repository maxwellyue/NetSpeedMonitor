//
//  MenuBarLabelStyleView.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/15.
//
import SwiftUI

struct MenuBarLabelStyleView: View {
    @State var fontDesign: MenuBarLabelStyle.FontDesign = .rounded
    @State var lines: MenuBarLabelStyle.LayoutDirection = .horizontal
    @State var icon: MenuBarLabelStyle.Icon = .arrows
    @State var foreground: MenuBarLabelStyle.ForegroundStyle = .template

    @State var txColor: Color = .teal
    @State var rxColor: Color = .orange

    let throughput = NetworkThroughput(rxBps: 1024 * 1024 * 1.5, txBps: 1024 * 1024 * 2.5)

    var currentStyle: MenuBarLabelStyle {
        MenuBarLabelStyle(
            lines: lines,
            icon: icon,
            foreground: foreground,
            fontDesign: fontDesign
        )
    }

    var minmumWidth: CGFloat {
        switch self.lines {
        case .horizontal:
            return 160
        case .vertical:
            return 64
        }
    }

    var body: some View {
        Form {
            // 预览区域
            Section {
                Picker("排列方式", selection: $lines) {
                    ForEach(MenuBarLabelStyle.LayoutDirection.allCases, id: \.self) { line in
                        Text(line.displayName)
                            .tag(line)
                    }
                }
                .pickerStyle(.segmented)

                VStack {
                    Picker("前景样式", selection: Binding(
                        get: {
                            switch foreground {
                            case .template: return 0
                            case .accented: return 1
                            }
                        },
                        set: { index in
                            if index == 0 {
                                foreground = .template
                            } else {
                                foreground = .accented(tx: CodableColor(txColor), rx: CodableColor(rxColor))
                            }
                        }
                    )) {
                        Text("跟随系统").tag(0)
                        Text("自定义颜色").tag(1)
                    }
                    .pickerStyle(.segmented)

                    if case .accented = foreground {
                        HStack {
                            Spacer()
                            ColorPicker("上传颜色", selection: $txColor)
                                .onChange(of: txColor) { _, newColor in
                                    if case .accented(_, let rx) = foreground {
                                        foreground = .accented(tx: CodableColor(newColor), rx: rx)
                                    }
                                }

                            ColorPicker("下载颜色", selection: $rxColor)
                                .onChange(of: rxColor) { _, newColor in
                                    if case .accented(let tx, _) = foreground {
                                        foreground = .accented(tx: tx, rx: CodableColor(newColor))
                                    }
                                }
                        }
                        .labelsHidden()
                    }
                }

                Picker("字体风格", selection: $fontDesign) {
                    ForEach(MenuBarLabelStyle.FontDesign.allCases, id: \.self) { design in
                        Text(design.displayName)
                            .tag(design)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                HStack {
                    Spacer()
                    MenuBarLabelTemplate(
                        throughput: throughput,
                        lines: lines,
                        icon: icon,
                        foreground: foreground,
                        fontDesign: fontDesign
                    )
                    Spacer()
                }
                .padding(.vertical)
            }

            // 图标类型
            Section {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: minmumWidth, maximum: .infinity))]) {
                    ForEach(MenuBarLabelStyle.Icon.allOptions, id: \.self) { iconOption in
                        Button {
                            icon = iconOption
                        } label: {
                            VStack {
                                MenuBarLabelTemplate(
                                    throughput: throughput,
                                    lines: lines,
                                    icon: iconOption,
                                    foreground: foreground,
                                    fontDesign: fontDesign
                                )
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SelectionButtonStyle(selected: icon == iconOption))
                        .buttonBorderShape(.capsule)
                    }
                }
                .frame(maxWidth: .infinity)
            } header: {
                Text("图标类型")
            } footer: {
                Text("选择用于表示上传和下载的图标样式")
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minWidth: 400, minHeight: 600)
        .frame(idealWidth: 400, idealHeight: 600)
        .padding()
        .task {
            let style = Profiles.shared.style
            self.fontDesign = style.fontDesign
            self.lines = style.lines
            self.icon = style.icon
            self.foreground = style.foreground
            if case .accented(let tx, let rx) = style.foreground {
                self.txColor = tx.color
                self.rxColor = rx.color
            }
        }
        .onChange(of: self.currentStyle) {
            Profiles.shared.style = self.currentStyle
        }
    }
}

#Preview {
    MenuBarLabelStyleView()
}

struct SelectionButtonStyle: PrimitiveButtonStyle {
    var selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        if selected {
            BorderedProminentButtonStyle()
                .makeBody(configuration: configuration)
        } else {
            BorderedButtonStyle()
                .makeBody(configuration: configuration)
        }
    }
}
