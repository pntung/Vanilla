//
//  VanillaDataManager.swift
//  Vanilla
//
//  Created by Tung Pham on 6/5/20.
//  Copyright © 2020 Terralogic. All rights reserved.
//

import Foundation
import RealmSwift



class VanillaDataManager {
    static let sharedInstance: VanillaDataManager = VanillaDataManager()
    
    let realm = try! Realm()
    
    
    private init() {}
    
    
    func addNewPosition(_ pos: PositionInfo) {
        
        try! self.realm.write {
            self.realm.add(pos)
        }
        
        let postionList: Results<PositionInfo> = self.realm.objects(PositionInfo.self)
        //print("----------------- list: %@", postionList)
    }
    
}
