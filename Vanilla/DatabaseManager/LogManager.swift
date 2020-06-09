//
//  LogManager.swift
//  Vanilla
//
//  Created by Tung Pham on 6/9/20.
//  Copyright © 2020 Terralogic. All rights reserved.
//

import Foundation
import os.log
import CoreLocation


class LogManager {
    static let sharedInstance: LogManager = LogManager()
    
    let log = OSLog(subsystem: "com.montre.duoveo.log", category: "Terra_Log")
    
    private init() {}
    
    func saveLogCurrentLocation(_ current: CLLocationCoordinate2D) {
        os_log(.error, log: log, "curent location with Latitude: %f - Longitude: %f", current.latitude, current.longitude)
    }
    
    func saveLogInfo(_ text: String) {
        os_log(.error, log: log, "%@", text)
    }
    
    func saveLogPositionInfos(_ posList: [PositionInfo]) {
        os_log(.error, log: log, "%@", posList)
    }
}
