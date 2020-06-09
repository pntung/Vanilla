//
//  VanillaDataManager.swift
//  Vanilla
//
//  Created by Tung Pham on 6/5/20.
//  Copyright © 2020 Terralogic. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation


class VanillaDataManager {
    static let sharedInstance: VanillaDataManager = VanillaDataManager()
    
    let realm = try! Realm()
    
    
    private init() {}
    
    
    func addNewPosition(_ pos: PositionInfo) {
        
        try! self.realm.write {
            self.realm.add(pos)
            LogManager.sharedInstance.saveLogInfo("Inserted successfully")
        }
        
    }
    
    func getLocationArray() -> [CLLocationCoordinate2D] {
        var coordinateArray: [CLLocationCoordinate2D] = []
        
        
        let postionList: Results<PositionInfo> = self.realm.objects(PositionInfo.self)
        for positionInfo in postionList {
            let coor = CLLocationCoordinate2D(latitude: positionInfo.latititude, longitude: positionInfo.longtitude)
            coordinateArray.append(coor)
        }
        
        if coordinateArray.count == 0 {
            LogManager.sharedInstance.saveLogInfo("Database is empty or it get the issue")
        }
        
        return coordinateArray
    }
    
    
    func getPositionsFromDB() -> [PositionInfo] {
        var posList: [PositionInfo] = []
        let positions : Results<PositionInfo> = self.realm.objects(PositionInfo.self)
        
        for positionInfo in positions {
            posList.append(positionInfo)
        }
        
        if posList.count == 0 {
            LogManager.sharedInstance.saveLogInfo("Database is empty or it get the issue")
        }
        
        return posList
    }
    
}
