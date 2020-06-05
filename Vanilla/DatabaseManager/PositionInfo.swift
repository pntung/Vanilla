//
//  PositionInfo.swift
//  Vanilla
//
//  Created by Tung Pham on 6/5/20.
//  Copyright © 2020 Terralogic. All rights reserved.
//

import Foundation
import RealmSwift

class PositionInfo: Object {
    @objc dynamic var longtitude: Double = 0.0
    @objc dynamic var latititude: Double = 0.0
    @objc dynamic var posTime: NSDate = NSDate()
}
