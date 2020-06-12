//
//  Utils.swift
//  Vanilla
//
//  Created by QuanMac on 6/12/20.
//  Copyright © 2020 Terralogic. All rights reserved.
//

import Foundation

class Utils {
    static func convertDictToJSONString(dict:[String:Any]?) -> String {
        guard let dict = dict else {return ""}
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        
        return jsonString!
    }
    
    static func getAppBuildString() -> String?{
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(build)"
        }
        else{
            return nil
        }
    }
    
    static func printErrorWith(message:String) {
        print("------------- Error: \(message)")
        LogVC.save("[Error]Message: \(message)", force: true)
    }
    
    static func printSuccessWith(message:String) {
        print("------------- Success: \(message)")
        LogVC.save("[Succeed]Message: \(message)", force: true)
    }
}
