//
//  MenuBarLabelStyle + Icon.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/15.
//
import Foundation

extension MenuBarLabelStyle {
    enum Icon: Hashable, Codable {
        case none
        case arrows
        case triangles
        case trianglesFill
        case chevrons
        case arrowshape
        case arrowshapeFill
        case minimal
        case custom(tx: String, rx: String)
    }
}

extension MenuBarLabelStyle.Icon {
    static let presets: [MenuBarLabelStyle.Icon] = [
        .arrows,
        .minimal,
        .chevrons,
        .triangles,
        .trianglesFill,
        .arrowshape,
        .arrowshapeFill
    ]

    static let allOptions: [MenuBarLabelStyle.Icon] = [.none] + presets

    var scale: CGFloat {
        switch self {
        case .arrowshape, .arrowshapeFill:
            return 0.75
        default: return 0.85
        }
    }

    var tx: String? {
        switch self {
        case .none: return nil

        case .arrows: return "arrow.up"

        case .triangles: return "arrowtriangle.up"

        case .trianglesFill: return "arrowtriangle.up.fill"

        case .chevrons: return "chevron.up"

        case .arrowshape: return "arrowshape.up"

        case .arrowshapeFill: return "arrowshape.up.fill"

        case .minimal: return "arrow.up.forward"

        case .custom(let tx, _): return tx
        }
    }

    var rx: String? {
        switch self {
        case .none: return nil

        case .arrows: return "arrow.down"

        case .triangles: return "arrowtriangle.down"

        case .trianglesFill: return "arrowtriangle.down.fill"

        case .chevrons: return "chevron.down"

        case .arrowshape: return "arrowshape.down"

        case .arrowshapeFill: return "arrowshape.down.fill"

        case .minimal: return "arrow.down.backward"

        case .custom(_, let rx): return rx
        }
    }

    func imageName(for flow: TrafficFlow) -> String? {
        switch flow {
        case .tx: return tx
        case .rx: return rx
        }
    }
}
