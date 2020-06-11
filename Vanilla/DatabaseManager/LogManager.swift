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
import FirebaseAnalytics


class LogManager {
    static let sharedInstance: LogManager = LogManager()
    
    let log = OSLog(subsystem: "com.montre.duoveo.log", category: "Terra_Log")
    /*
    let log = OSLog(subsystem: "com.montre.duoveo.log", category: "Terra_Log")
    
    private init() {}
    
    func saveLogCurrentLocation(_ current: CLLocationCoordinate2D) {
        os_log(.error, log: log, "curent location with Latitude: %f - Longitude: %f", current.latitude, current.longitude)
    }
    
    func saveLogInfo(_ text: String) {
        os_log(.error, log: log, "%{public}@", text)
    }
    
    func saveLogPositionInfos(_ posList: [PositionInfo]) {
        os_log(.error, log: log, "%{public}@", posList)
    }
    */
    
    let filename = "vanillalog.txt"
    
    private func saveContentToFile(content: String) {
        
        let fm = FileManager.default
        let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        if let handle = try? FileHandle(forWritingTo: log) {
            handle.seekToEndOfFile()
            handle.write(content.data(using: .utf8)!)
            handle.closeFile()
        }
        else {
            try? content.data(using: .utf8)?.write(to: log)
        }
        
    }
    
    private func readContentFromLogFile() -> String {
        var content: String = ""
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        
            let fileURL = dir.appendingPathComponent(filename)

            //writing
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                content = text2
            }
            catch {
                /* error handling here */
            }
        }
        
        return content
    }
    
    func sendLogToFirebase() {
        let strContent = readContentFromLogFile()
        
        os_log(.error, log: log, "%{public}@", strContent)
        
        
        let eventName = "VanillaLog"
        Analytics.logEvent(eventName, parameters:
            [
                "data": strContent
            ]
        )
    }
    
    func saveLogCurrentLocation(_ current: CLLocationCoordinate2D) {
        
        os_log(.error, log: log, "curent location with Latitude: %f - Longitude: %f", current.latitude, current.longitude)
        
        let text = String(format: "curent location with Latitude: %f - Longitude: %f \n", current.latitude, current.longitude)
        
        saveContentToFile(content: text)
    }
    
    func saveLogInfo(_ text: String) {
        
        os_log(.error, log: log, "%{public}@", text)
        
        let temp = String(format: "%@ \n", text)
        saveContentToFile(content: temp)
    }
    
    func saveLogPositionInfos(_ posList: [PositionInfo]) {
        
        os_log(.error, log: log, "%{public}@", posList)
        
        var text: String = ""
        for posInfo in posList {
            let str = String(format: "Date: %@, location with Latitude: %f - Longitude: %f \n", posInfo.posTime , posInfo.latititude, posInfo.longtitude)
            text += str
        }
        
        saveContentToFile(content: text)
    }
    
}
