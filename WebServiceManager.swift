//
//  TOD_WebServiceManager.swift
//  TOD
//
//  Created by Prince Sojitra on 06/09/16.
//  Copyright © 2016 DRC Systems. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD


class WebServiceManager: NSObject
{
    
    static var instance: WebServiceManager!
    
    var isLoaderRemoved:Bool = true
    var timer:Timer?
    class func sharedInstance() -> WebServiceManager
    {
        self.instance = (self.instance ?? WebServiceManager())
        return self.instance
    }
    
    class func callWebService(WSUrl:String, WSMethod:HTTPMethod,WSParams:Dictionary<String, AnyObject> ,WSHeader :Dictionary<String, AnyObject>,isLoader:Bool = true,WSCompletionBlock:@escaping (_ data:AnyObject?,_ error:NSError?) -> ())
    {
        
        if Utils.Is_Internet_Connection_Available() {
            let iParmsDict :Dictionary<String, AnyObject>  =  WSParams
            print(iParmsDict)
            
            let iWsURL : String = WSUrl
            print(iWsURL)
            print(iParmsDict)
            
            let url = URL(string: WSUrl)
            let aStrDomain = url?.host
            let iHeaders = WSHeader
            
            request(WSUrl, method: WSMethod, parameters: WSParams, encoding: URLEncoding.default, headers: iHeaders as? [String : String])
                .responseData { response in
                    
                    if let data = response.data {
                        
                        do
                        {
                            let iStrResponse = NSString(data: data, encoding: String.Encoding.isoLatin1.rawValue)
                            // print("responseString = \(iStrResponse)")
                            
                            let dataResponse:NSData! = iStrResponse?.data(using: String.Encoding.utf8.rawValue) as NSData!
                            
                            let object:AnyObject? = try JSONSerialization.jsonObject(with: dataResponse! as Data, options:.mutableLeaves) as AnyObject
                            
                            if object! is NSArray
                            {
                                var iArrResponse: NSArray!
                                iArrResponse = object as! NSArray
                                
                                WSCompletionBlock(iArrResponse!,nil)
                                
                            }
                            else
                            {
                                var iDictResponse: Dictionary <String, AnyObject>!
                                iDictResponse = object as! Dictionary
                                
                                do
                                {
                                    let data = try JSONSerialization.data(withJSONObject: iDictResponse, options: JSONSerialization.WritingOptions.prettyPrinted)
                                    
                                    
                                    let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                                    
                                    let newString = json!.replacingOccurrences(of: "<null>", with: "")
                                    
                                    if let data = newString.data(using: String.Encoding.utf8) {
                                        do {
                                            iDictResponse = try JSONSerialization.jsonObject(with: data, options:.mutableLeaves) as! Dictionary<String, AnyObject>
                                            
                                        } catch let error as NSError {
                                            print(error)
                                        }
                                    }
                                    
                                }catch
                                {
                                }
                                
                                WSCompletionBlock(iDictResponse! as AnyObject?,nil)
                            }
                            
                        }
                        catch let caught as NSError
                        {
                            WSCompletionBlock(nil,caught)
                            
                        }
                        catch
                        {
                            let error: NSError = NSError(domain: aStrDomain!, code: 1, userInfo: nil)
                            if isLoader {
                                sharedInstance().isLoaderRemoved = true
                                sharedInstance().timer?.invalidate()
                                
                            }
                            WSCompletionBlock(nil,error)
                        }
                    }
            }
        
        } else {
          
          
        }
       
      
    }
    
    
   
    
    
    class func callImageUploadWithParameterUsingMultipart(WSUrl:String,WSParams:[String : Any],WSHeader:[String : String],isLoader:Bool,iImgArray:NSArray,iStrImgParamName:String, WSCompletionBlock:@escaping (_ data:AnyObject?,_ error:NSError?) -> ()) {
        
        
        if isLoader  {
            
            if Constants.APPDELEGATE.window != nil {
                DispatchQueue.main.async {
                    
                }
                SVProgressHUD.show()
                //  MBProgressHUD.showAdded(to: Constants.APPDELEGATE.window!, animated: true)
            }
        }
         let manager = Utils.Manager
        manager.upload(multipartFormData: { (multipartFormData) in

            for image in iImgArray
            {
                let imageData:Data = (image as! UIImage).pngData()! as Data
                print(imageData)
                multipartFormData.append(imageData, withName: "file", fileName: "test.png", mimeType: "application/octet-stream")
            }
          //  multipartFormData.append("TestCV.pdf".data(using:.utf8)!, withName: "fileName")
            for (key, value) in WSParams {

                multipartFormData.append((value as! NSString).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, to: WSUrl,
           method:.post,
           headers:WSHeader , encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print(progress)
                })
                print(upload.response?.allHeaderFields as Any)
                upload.responseJSON { response in
                    do
                    {
                        if isLoader
                        {
                            
                            if Constants.APPDELEGATE.window != nil {
                                DispatchQueue.main.async
                                    {
                                        
                                }
                                SVProgressHUD.dismiss()
                                
                            }
                        }
                        guard response.result.error == nil else {
                            print("error response")
                            print(response.result.error!)
                            return
                        }
                        let object:AnyObject? = try JSONSerialization.jsonObject(with: response.data! as Data, options:.mutableLeaves) as AnyObject
                        
                        if object! is NSArray
                        {
                            var iArrResponse: NSArray!
                            iArrResponse = object as! NSArray
                            if isLoader {
                                
                            }
                            WSCompletionBlock(iArrResponse!,nil)
                            
                        }
                        else
                        {
                            var iDictResponse: Dictionary <String, AnyObject>!
                            iDictResponse = object as! Dictionary
                            
                            do
                            {
                                let data = try JSONSerialization.data(withJSONObject: iDictResponse, options: JSONSerialization.WritingOptions.prettyPrinted)
                                
                                
                                let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                                
                                let newString = json!.replacingOccurrences(of: "<null>", with: "")
                                
                                if let data = newString.data(using: String.Encoding.utf8) {
                                    do {
                                        
                                        iDictResponse = try JSONSerialization.jsonObject(with: data, options:.mutableLeaves) as! Dictionary<String, AnyObject>
                                        WSCompletionBlock(iDictResponse! as AnyObject?,nil)
                                        // //print(iDictResponse)
                                    } catch let error as NSError {
                                        print(error)
                                    }
                                }
                                
                            }catch
                            {
                            }
                            
                            
                        }
                        
                    }
                    catch let caught as NSError  {
                        
                        WSCompletionBlock(nil,caught)
                    }
                    catch {   }
                }
                
            case .failure(let encodingError) :
                if isLoader
                {
                    
                    if Constants.APPDELEGATE.window != nil {
                        DispatchQueue.main.async {
                            
                        }
                        SVProgressHUD.dismiss()
                    }
                }
                print (encodingError.localizedDescription)
                
            }
        }
        )
    }
    
    ////
    class func callFileUploadWithParameterUsingMultipart(WSUrl:String,WSParams:[String : Any],WSHeader:[String : String],isLoader:Bool,iImgArray:NSArray,iStrImgParamName:String, WSCompletionBlock:@escaping (_ data:AnyObject?,_ error:NSError?) -> ())
    {
        if isLoader  {
            
            if Constants.APPDELEGATE.window != nil {
                DispatchQueue.main.async {
                    
                }
                SVProgressHUD.show()
                //  MBProgressHUD.showAdded(to: Constants.APPDELEGATE.window!, animated: true)
            }
        }
        let manager = Utils.Manager
        manager.upload(multipartFormData: { (multipartFormData) in
           // let imageData: NSData = NSData(base64Encoded: iImgArray[0] as! String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
        // let imageData:Data = UIImagePNGRepresentation(iImgArray[0] as! UIImage)! as Data
    
            let imageData : Data = Data(base64Encoded: iImgArray[0] as! String, options: .ignoreUnknownCharacters)!
          multipartFormData.append(imageData, withName: "file", fileName: iImgArray[1] as! String, mimeType: "application/octet-stream")
            //  multipartFormData.append("TestCV.pdf".data(using:.utf8)!, withName: "fileName")
            for (key, value) in WSParams {
                
                multipartFormData.append((value as! NSString).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, to: WSUrl,
           method:.post,
           headers:WSHeader , encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    print(progress)
                })
                print(upload.response?.allHeaderFields as Any)
                upload.responseJSON { response in
                    do
                    {
                        if isLoader
                        {
                            
                            if Constants.APPDELEGATE.window != nil {
                                DispatchQueue.main.async
                                    {
                                        
                                }
                                SVProgressHUD.dismiss()
                                
                            }
                        }
                        guard response.result.error == nil else {
                            print("error response")
                            print(response.result.error!)
                            return
                        }
                        let object:AnyObject? = try JSONSerialization.jsonObject(with: response.data! as Data, options:.mutableLeaves) as AnyObject
                        
                        if object! is NSArray
                        {
                            var iArrResponse: NSArray!
                            iArrResponse = object as! NSArray
                            if isLoader {
                                
                            }
                            WSCompletionBlock(iArrResponse!,nil)
                            
                        }
                        else
                        {
                            var iDictResponse: Dictionary <String, AnyObject>!
                            iDictResponse = object as! Dictionary
                            
                            do
                            {
                                let data = try JSONSerialization.data(withJSONObject: iDictResponse, options: JSONSerialization.WritingOptions.prettyPrinted)
                                
                                
                                let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                                
                                let newString = json!.replacingOccurrences(of: "<null>", with: "")
                                
                                if let data = newString.data(using: String.Encoding.utf8) {
                                    do {
                                        
                                        iDictResponse = try JSONSerialization.jsonObject(with: data, options:.mutableLeaves) as! Dictionary<String, AnyObject>
                                        WSCompletionBlock(iDictResponse! as AnyObject?,nil)
                                        // //print(iDictResponse)
                                    } catch let error as NSError {
                                        print(error)
                                    }
                                }
                                
                            }catch
                            {
                            }
                            
                            
                        }
                        
                    }
                    catch let caught as NSError  {
                        
                        WSCompletionBlock(nil,caught)
                    }
                    catch {   }
                }
                
            case .failure(let encodingError) :
                if isLoader
                {
                    
                    if Constants.APPDELEGATE.window != nil {
                        DispatchQueue.main.async {
                            
                        }
                        SVProgressHUD.dismiss()
                    }
                }
                print (encodingError.localizedDescription)
                
            }
        }
        )
    }
    }

