//
//  LogVC.swift
//  e-wrist
//
//  Created by Administrator on 10/30/19.
//  Copyright © 2019 terralogic. All rights reserved.
//

import UIKit

enum LogError:Error{
    case FileNotFound
    case LogNotFound
    case UserNotFound
}

typealias UploadFileCompletionHandler = (Error?, UploadFileRES?) -> Void

class LogVC {
    static let ServerDateTimeMili = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static var backgroundTask = UIBackgroundTaskIdentifier.invalid
    
    static func save(_ text:String, force: Bool = false) {
        print("[FILELOGGER]\(text)")
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "PrintFileTestExpired", expirationHandler: {
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
        })

        DispatchQueue.global(qos: .background).async {
            log(text: text, force: force) {
                UIApplication.shared.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = UIBackgroundTaskIdentifier.invalid
            }
        }
    }
    
    static func log(text:String, force: Bool = false, completion: (() -> Void)? = nil){
        let date = Date().toGMTString(format: LogVC.ServerDateTimeMili)
        let userID = 54
        let key = "log_\(userID)_\(date)"
        UserDefaults.standard.set(text, forKey: key)
        
        completion?()
    }
    
    static func uploadLogFile(completion:@escaping UploadFileCompletionHandler){
        
        var finalLogs = ""
        var logKeys:[String] = []
        
        let userId = 54
        
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            let prefix = "log_\(userId)_"
            if key.hasPrefix(prefix){
                logKeys.append(key)
            }
        }
        
        logKeys.sort { (key1, key2) -> Bool in
            return key1 < key2
        }
        
        for key in logKeys {
            let prefix = "log_\(userId)_"
            let date = key.replacingOccurrences(of: prefix, with: "")
            let log = UserDefaults.standard.object(forKey: key) as? String
            if let _log = log {
                finalLogs = "\(finalLogs)\n \(date) -> \(_log)"
            }
            UserDefaults.standard.removeObject(forKey: key)
        }
    
        
        let data = finalLogs.data(using: .utf8)
        
        guard let _data = data else {
            completion(LogError.LogNotFound, nil)
            return
        }
        
        let time = Date().toGMTString(format: "MMddyyHHmmss")
        let fileNameForUpload =  "iOS_\(UIDevice.current.systemVersion)_User_\(userId)_Build_\(Utils.getAppBuildString() ?? "")_\(time).txt"
        
        let fileUploadData = FileUploadData(fieldName: "log", fileName: fileNameForUpload, fileData: _data, mineType: "text/plain")
        
        APIServices().uploadFiles(filesUploadData: [fileUploadData], params: nil, API: "/files/uploadfile", responseClass: UploadFileRES.self, completionHandler: completion)

    }
}

extension Date {
    func toGMTString(format: String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        dateformatter.calendar = Calendar(identifier: .iso8601)
        dateformatter.locale = Locale(identifier: "en_US_POSIX")
        dateformatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateformatter.string(from: self)
    }
}
