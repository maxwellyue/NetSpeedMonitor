//
//  Logger.swift
//  NetSpeedMonitor
//
//  Created by yueyuemax on 2025/11/16.
//
import Foundation
import os.log

public var logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "unknown bundle", category: "netspeedmonitor")
