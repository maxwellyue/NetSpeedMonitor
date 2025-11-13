//
//  NetTraffic.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/13.
//
import Foundation
import SystemConfiguration

struct NetTraffic: Sendable {
    var inBytes: Double = 0.0
    var outBytes: Double = 0.0

    private static func findPrimaryInterface() -> String? {
        let storeRef = SCDynamicStoreCreate(nil, "FindCurrentInterfaceIpMac" as CFString, nil, nil)
        let global = SCDynamicStoreCopyValue(storeRef, "State:/Network/Global/IPv4" as CFString)
        let primaryInterface = global?.value(forKey: "PrimaryInterface") as? String
        return primaryInterface
    }

    static func current(using receiver: NetTrafficStatReceiver) -> NetTraffic? {
        guard let primaryInterface = findPrimaryInterface() else {
            logger.info("primaryInterface is nil")
            return nil
        }

        guard let netTrafficStatMap = receiver.getNetTrafficStatMap() else {
            logger.info("netTrafficStatMap is nil")
            return nil
        }

        guard let netTrafficStat = netTrafficStatMap.object(forKey: primaryInterface) as? NetTrafficStatOC else {
            logger.info("netTrafficStat is nil")
            return nil
        }

        guard let inBytes = netTrafficStat.ibytes_per_sec as? Double,
              let outBytes = netTrafficStat.obytes_per_sec as? Double
        else {
            logger.info("inBytes or outBytes is nil")
            return nil
        }
        logger.info("current inBytes: \(String(format: "%.6f", inBytes)) B/s, outBytes: \(String(format: "%.6f", outBytes)) B/s")
        return NetTraffic(inBytes: inBytes, outBytes: outBytes)
    }
}
