//
//  AppDelegate.swift
//  Vanilla
//
//  Created by Tung Pham on 6/3/20.
//  Copyright © 2020 Terralogic. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        FirebaseApp.configure()

        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        LogVC.save("ENTERED FOREGROUND", force: true)
         VanillaDataManager.shared.getPositionsFromDB(at: "[ENTERED FOREGROUND]")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        LogVC.save("ENTERED BACKGROUND", force: true)
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

