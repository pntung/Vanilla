//
//  File.swift
//  e-wrist
//
//  Created by Administrator on 8/20/19.
//  Copyright © 2019 nCubeLabs. All rights reserved.
//

import Foundation
import ObjectMapper

class UploadFileRES: BaseRES{
    var url:String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        self.url <- map["url"]
    }
}
