//
//  SMAppServiceManager.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/13.
//
import ServiceManagement

/// 管理自动启动
enum SMAppServiceManager {
    static func autoLaunch(enable: Bool) throws {
        guard enable != SMAppServiceManager.isAutoLaunchEnabled else {
            logger.info("UpdateAutoLaunchStatus skipped, autoLaunchEnabled: \(String(enable)), service.enabled: \(String(SMAppServiceManager.isAutoLaunchEnabled))")
            return
        }

        let service = SMAppService.mainApp
        if enable {
            if service.status == .notFound || service.status == .notRegistered {
                try service.register()
            }
        } else {
            if service.status == .enabled {
                try service.unregister()
            }
        }
        logger.info("updateAutoLaunchStatus succeeded, autoLaunchEnabled: \(String(enable)), service.enabled: \(String(service.status == .enabled))")
    }

    static var isAutoLaunchEnabled: Bool {
        let service = SMAppService.mainApp
        let status = service.status
        return status == .enabled
    }
}
