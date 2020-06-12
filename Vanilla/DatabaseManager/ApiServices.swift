//
//  APIServices.swift
//
//  Copyright © 2019 nCubeLabs. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

enum APIServiceError:Error {
    case UnKnownError
    case ObjectResponseNIL
    case RequestError(message:String)
}

/// Alamofire.upload: Upload files with multipart, stream, file or data methods.
/// Alamofire.download: Download files or resume a download already in progress.
/// Alamofire.request: Every other HTTP request not associated with file transfers.
typealias CompletionHandler = (Error?, BaseRES?) -> Void

/// These APIs in this class will take param as RequestData (Mappale) and return value as ResponseData (Mappale) in completionHandler.
/// Specific data model is declared in ResponseData.

class APIServices{
    static let BaseURLString = "https://dark-tenure-246403.appspot.com/api"
    var shouldPrintLog = true

    // Upload files.
    func uploadFiles<ResponseType:UploadFileRES>(filesUploadData:[FileUploadData], params:[String:Any]?, API:String, responseClass:ResponseType.Type, completionHandler:@escaping UploadFileCompletionHandler){
        
        // Upload file have no BaseREQ
        let fullPath = APIServices.BaseURLString + API
        
        var headers: HTTPHeaders = [:]
        
        let access_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjU0LCJlbWFpbCI6InRoYW5oLm5ndXllbkBnbWFpbC5jb20iLCJyb2xlIjo5OSwicHJvdmlkZXIiOiJlbWFpbCIsIm5hbWUiOiJEYXZpZCBOZ3V5ZW4iLCJmaXJzdF9uYW1lIjoiRGF2aWQiLCJsYXN0X25hbWUiOiJOZ3V5ZW4iLCJyZWZyZXNoS2V5IjoicTRqYmRSUkMwMXMyUmJUK3g0T011QT09IiwiaWF0IjoxNTkwNDAwMTY5LCJleHAiOjE1OTI5OTIxNjl9.-QOL0YrBIzdJ7nVE5QZYaiZJMA3AQPFDx_eaiv51yIU"
    
        
        Alamofire.upload(multipartFormData: { (multipart) in
            
            if let params = params{
                
                for (key, value) in params {
                    multipart.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
            }
            
            for fileUploadData in filesUploadData{
                multipart.append(fileUploadData.fileData, withName: fileUploadData.fieldName, fileName: fileUploadData.fileName, mimeType: fileUploadData.mineType)
            }
            
            
        }, usingThreshold: UInt64.init(), to: fullPath, method: .post, headers: headers) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON(completionHandler: { (response) in
                    
                    if response.result.error != nil{
                        completionHandler(response.result.error, nil)
                    }
                    else
                    {
                        let value = response.result.value as? [String : Any]
                        
                        if self.shouldPrintLog{
                            print("Results: \(Utils.convertDictToJSONString(dict: value))")
                        }
                        
                        
                        // 1.
                        let objectResponse = Mapper<ResponseType>().map(JSONObject: value)
                        
                        // 2.
                        if objectResponse == nil {
                            completionHandler(APIServiceError.ObjectResponseNIL, nil)
                            return
                        }
                        
                        // 3.
                        if let errors = objectResponse!.errors, errors.count > 0{
                            
                            let messages = errors.map({ (serverError) -> String in
                                return (serverError.msg ?? "Error")
                            }).joined(separator: ", ")
                            
                            
                            
                            Utils.printErrorWith(message: messages)
                            completionHandler(APIServiceError.RequestError(message: messages), nil)
                            return
                        }
                        
                        completionHandler(nil, objectResponse!)
                    }
                })
                
            case .failure(let error):
                Utils.printErrorWith(message: error.localizedDescription)
                completionHandler(error, nil)
                break
            }
        }
        
    }
    
    
    // Base service function.
    func getService<ResponseType:BaseRES>(urlRequest:URLRequestConvertible, responseClass:ResponseType.Type, completionHandler:@escaping CompletionHandler){
        
        Alamofire.request(urlRequest).responseJSON { (response) in
            
            switch response.result{
                
            case .success:
                
                let value = response.result.value as? [String : Any]
                
                if self.shouldPrintLog{
                    print("Results: \(Utils.convertDictToJSONString(dict: value))")
                }
                
                // 1.
                let objectResponse = Mapper<ResponseType>().map(JSONObject: value)
   
                // 2.
                if objectResponse == nil {
                    completionHandler(APIServiceError.ObjectResponseNIL, nil)
                    return
                }
                
                // 3.
                if let errors = objectResponse!.errors, errors.count > 0{
                    
                    let messages = errors.map({ (serverError) -> String in
                        return (serverError.msg ?? "Error")
                    }).joined(separator: ", ")
                    
                    
                    
                    Utils.printErrorWith(message: messages)
                    completionHandler(APIServiceError.RequestError(message: messages), nil)
                    return
                }

                completionHandler(nil, objectResponse!)
                
            case .failure(let error):
                Utils.printErrorWith(message: error.localizedDescription)
                completionHandler(error, nil)
           
            }
        }
    
    }
    
    
    private func getPublicService<ResponseType:BaseRES>(urlRequest:String, responseClass:ResponseType.Type, completionHandler:@escaping (Error?, [String:Any]?) -> Void){
        
        Alamofire.request(urlRequest).responseJSON { (response) in
            
            switch response.result{
                
            case .success:
                
                guard let value = response.result.value as? [String:Any] else {
                    completionHandler(APIServiceError.RequestError(message: "Invalid Json array data"), nil)
                    return
                }
                
                completionHandler(nil, value)
                
            case .failure(let error):
                Utils.printErrorWith(message: error.localizedDescription)
                completionHandler(error, nil)
                
            }
        }
        
    }
        


}
