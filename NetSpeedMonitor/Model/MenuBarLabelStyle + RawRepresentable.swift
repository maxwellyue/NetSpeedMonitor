//
//  RawRepresentable + RawRepresentable.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/15.
//
import SwiftUI

extension MenuBarLabelStyle: RawRepresentable {
    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8) else {
            logger.error("Failed to decode data")
            return nil
        }
        do {
            let result = try JSONDecoder().decode(Self.self, from: data)
            self = result
            return
        } catch {
            logger.error("Failed to decode: \(error.localizedDescription)")
            return nil
        }
    }

    var rawValue: String {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [] // 不格式化，减少大小
            let data = try encoder.encode(self)
            guard let result = String(data: data, encoding: .utf8) else {
                logger.error("Failed to stringfy data")
                return ""
            }
            return result
        } catch let error as EncodingError {
            logger.error("Failed to encode MenuBarLabelStyle: \(error.localizedDescription)")
            // EncodingError 是枚举，需要从关联值中获取 context
            switch error {
            case .invalidValue(_, let context):
                logger.error("Encoding context: \(context.debugDescription)")
                for (index, key) in context.codingPath.enumerated() {
                    logger.error("  Coding path[\(index)]: \(key.stringValue)")
                }
            @unknown default:
                break
            }
            return ""
        } catch {
            logger.error("Failed to encode MenuBarLabelStyle: \(error.localizedDescription)")
            return ""
        }
    }
}
