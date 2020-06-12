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
    static let shared: VanillaDataManager = VanillaDataManager()
    
    let realm = try! Realm()
    
    
    private init() {}
    
    
    func addNewPosition(_ pos: PositionInfo) {
        
        try! self.realm.write {
            self.realm.add(pos)
            LogVC.save("Inserted successfully")
        }
        
    }
    
    func removeAllRecord() {
        try! self.realm.write {
            self.realm.deleteAll()
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
            LogVC.save("Database is empty or it get the issue")
        }
        
        return coordinateArray
    }
    
    
    func getPositionsFromDB(at: String) {
        LogVC.save("GPS Records after [\(at)]")
        var posList: [PositionInfo] = []
        let positions : Results<PositionInfo> = self.realm.objects(PositionInfo.self)
        
        for positionInfo in positions {
            LogVC.save(">>>>>> \(positionInfo)")
            posList.append(positionInfo)
        }
    }
    
}
