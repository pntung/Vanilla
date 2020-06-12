//
//
//  Created by Thoai Nguyen on 7/01/19.
//  Copyright © 2019 nCubeLabs. All rights reserved.
//
import Foundation
import Alamofire
import ObjectMapper

class FileUploadData {
    var fieldName:String // important.
    var fileData:Data
    var mineType:String
    var fileName:String
    
    init(fieldName:String, fileName:String, fileData:Data, mineType:String){
        self.fieldName = fieldName
        self.fileName = fileName
        self.fileData = fileData
        self.mineType = mineType
    }
    
    // For image upload
    init(fieldName:String, fileName:String, image:UIImage) {
        self.fieldName = fieldName
        self.fileName = fileName
        self.fileData = image.jpegData(compressionQuality: 0.6)!
        self.mineType = "image/jpeg"
    }
}


class BaseModel: Mappable {
    
    init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {}
    
}

class ServerError: BaseModel {
    
    var msg:String?
    var param:String?
    var value:String?
    var location:String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        msg <- map["msg"]
        param <- map["param"]
        value <- map["value"]
        location <- map["location"]
    }
}

class BaseREQ: Mappable {
    
    required init?(map: Map) {}
    
    init() {}
    
    func mapping(map: Map) {}
    
    func printData(){
        print("---------- Request ----------")
        print(Utils.convertDictToJSONString(dict: self.toJSON()))
        print("---------- Ending Request ----------")
    }
}

class BaseRES: Mappable {
    
    var errors:[ServerError]?
    
    required init?(map: Map) {}
    
    init(){}
    
    func printData(){
        print("---------- Response ----------")
        print(Utils.convertDictToJSONString(dict: self.toJSON()))
        print("---------- Ending Response ----------")
    }
    
    func mapping(map: Map) {
        errors <- map["errors"]
    }
}
