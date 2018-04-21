//
//  Service.swift
//  Util_Classes
//
//  Created by AppstoneLab on 13/09/17.
//  Copyright © 2017 AppstoneLab. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SVProgressHUD
import AlamofireObjectMapper
import AlamofireImage
import ObjectMapper

protocol ServiceDelegate
{
    func onFault(resultData:[String:Any]?,ServiceName:String)
    func onResult(resultData:Any?,ServiceName:String)
}
public class Service
{
    var receivedData:[String:Any]?
    var receivedArray:NSArray?
    var delegate: ServiceDelegate?
    var apiName:String?

    init()
    {
    }
    func checkInternetStatus() -> Bool
    {
        return Reachability.isConnectedToNetwork();
    }
    func getTopMostController() -> UIViewController
    {
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topController?.presentedViewController
        {
            topController = presentedViewController
        }
        // topController should now be your topmost view controller
        return topController!
    }
    //MARK: PUT 
    func callPutURL(url:URL,parameters:[String:Any]?,encodingType:String,headers:[String : String]!) -> Void
    {
        // post request and response json(with default options)
        if self.checkInternetStatus()
        {
            doAlamoFire.sharedInstance.upload(multipartFormData: { multipartFormData in
                    if encodingType.isEqual("default")
                    {
                        for (key,value) in parameters! {
                            multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                        }
                    }
                   else
                    {
                        do {
                            let data = try JSONSerialization.data(withJSONObject: "", options: JSONSerialization.WritingOptions.prettyPrinted)
                            multipartFormData.append(data, withName: "json key name", mimeType: "application/json")
                        } catch let myJSONError {
                            print(myJSONError)
                        }
                    }},
                      to: url,
                      method:.put,
                      headers:headers,
                      encodingCompletion: { encodingResult in
                      switch encodingResult {
                         case .success(let upload, _, _):
                         upload.validate().responseJSON
                         { response in
                         switch response.result
                         {
                                case .success:
                                   if let status = response.response?.statusCode
                                    {
                                            switch(status)
                                            {
                                                case 200:
                                                    print(response.result.value as Any)
                                                    self.receivedData = response.result.value as! [String : Any]?
                                                    self.delegate?.onResult(resultData: self.receivedData!,ServiceName:self.apiName!)
                                                    break
                                                default:
                                                    let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                                    self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                                    self.delegate?.onFault(resultData: self.receivedData!,ServiceName:self.apiName!)
                                                    break
                                                }
                                      }
                                     break
                                               case .failure(let error):
                                                Utils.HideAllHud()
                                                print("update failed",error.localizedDescription)
                                                break
                                            }
                                    }
                                    break
                        
                                    case .failure(let error):
                                                 Utils.HideAllHud()
                                                 print("update failed",error.localizedDescription)
                                                 break
                                    }
            })
        }
        else
        {
            Utils.HideAllHud()
            let alert = UIAlertController(title: "No Internet", message: "Please check your Internet connection.", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default)
            { (alert) in

                self.callPutURL(url: url, parameters: parameters, encodingType: encodingType,headers: headers)
            }
            alert.addAction(retryAction)
            presetAlertController(controller:alert)
        }
    }
    
    //MARK: DELETE 
    func callDeleteURL(url:URL,parameters:[String:Any],encodingType:String,headers:[String : String]!) -> Void {
        if self.checkInternetStatus()
        {
                doAlamoFire.sharedInstance.upload(multipartFormData: { multipartFormData in
                    if encodingType.isEqual("default")
                    {
                        for (key,value) in parameters {
                            multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                        }
                    }
                    else
                    {
                        do {
                            let data = try JSONSerialization.data(withJSONObject: "", options: JSONSerialization.WritingOptions.prettyPrinted)
                            multipartFormData.append(data, withName: "json key name", mimeType: "application/json")
                        } catch let myJSONError {
                            print(myJSONError)
                        }
                    }},
                  to: url,
                  method:.delete,
                  headers:headers,
                  encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.validate().responseJSON
                            { response in
                                switch response.result
                                {
                                case .success:
                                    if let status = response.response?.statusCode
                                    {
                                        switch(status)
                                        {
                                        case 200:
                                            print(response.result.value as Any)
                                            self.receivedData = response.result.value as! [String : Any]?
                                            self.delegate?.onResult(resultData: self.receivedData!,ServiceName:self.apiName!)
                                            break
                                        default:
                                            let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                            self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                            self.delegate?.onFault(resultData: self.receivedData!,ServiceName:self.apiName!)
                                            break
                                        }
                                    }
                                    break
                                case .failure(let error):
                                    Utils.HideAllHud()
                                    print("Delete failed",error.localizedDescription)
                                    break
                                }
                        }
                        break
                        
                    case .failure(let error):
                        Utils.HideAllHud()
                        print("Delete failed",error.localizedDescription)
                        break
                    }
            })
        }
        else{
            Utils.HideAllHud()
            let alert = UIAlertController(title: "No Internet", message: "Please check your Internet connection.", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default)
            { (alert) in

                self.callDeleteURL(url: url, parameters: parameters, encodingType:encodingType,headers: headers)
            }
            alert.addAction(retryAction)
            presetAlertController(controller:alert)
        }

    }
     //MARK: GET 
    func callGetURL(url:URL,parameters:[String:Any]?,encodingType:String,headers:[String : String]?) -> Void {

        if self.checkInternetStatus()
        {
         //   Utils.Show()
            if encodingType .isEqual("default")
            {
                doAlamoFire.sharedInstance.request(url, method: .get, parameters: parameters, encoding:URLEncoding.default, headers: headers)
                    .responseJSON { response in
                        
                        switch response.result
                        {
                            case .success:
                            if let status = response.response?.statusCode
                            {
                                switch(status)
                                {
                                case 200:
                                     if let signupResponse = response.result.value
                                     {
                                        self.delegate?.onResult(resultData: signupResponse,ServiceName:self.apiName!)
                                     }
                                default:
                                    let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                    self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                    self.delegate?.onFault(resultData: self.receivedData!,ServiceName:self.apiName!)
                                }
                            }
                       break
                        case .failure(let error):
                            Utils.HideAllHud()
                            self.delegate?.onFault(resultData: nil,ServiceName:self.apiName!)
                            print(error)
                            break
                        }
                }
            }
            else{
                doAlamoFire.sharedInstance.request(url, method: .get, parameters: parameters, encoding:JSONEncoding.default, headers: headers)
                    .responseJSON { response in

                        if let status = response.response?.statusCode
                        {
                            switch(status){

                            case 200:
                                self.receivedData = response.result.value as! [String : Any]?
                                self.delegate?.onResult(resultData: self.receivedData!,ServiceName:self.apiName!)
                            default:
                                let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                self.delegate?.onFault(resultData: self.receivedData!,ServiceName:self.apiName!)
                            }
                        }
                }
            }
        }
        else
        {
            Utils.HideAllHud()
            let alert = UIAlertController(title: "No Internet", message: "Please check your Internet connection.", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default)
            { (alert) in

                self.callGetURL(url: url, parameters: parameters, encodingType: encodingType,headers: headers)
            }
            alert.addAction(retryAction)
            presetAlertController(controller:alert)
        }
    }

   //MARK: POST 
    func callPostURL(url:URL,parameters:[String:Any],encodingType:String,headers:[String : String]?) -> Void {
        if self.checkInternetStatus()
        {
           // Utils.Show()
            if encodingType .isEqual("default")
            {
                doAlamoFire.sharedInstance.request(url, method: .post, parameters: parameters, encoding:URLEncoding.httpBody, headers: headers)
                    .responseJSON { response in
                    
                    switch response.result {
                            
                        case .success:
                            
                            if let status = response.response?.statusCode
                            {
                                switch(status)
                                {
                                case 200:
                                    if let signupResponse = response.result.value
                                    {
                                        self.delegate?.onResult(resultData: signupResponse,ServiceName:self.apiName!)
                                    }
                                    break
                                default:
                                    let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                    self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                    self.delegate?.onFault(resultData: self.receivedData!,ServiceName:self.apiName!)
                                    break
                                }
                            }
                            break
                        case .failure(let error):
                            Utils.HideAllHud()
                            self.delegate?.onFault(resultData: nil,ServiceName:self.apiName!)
                            print(error)
                            break
                        }
                }
            }
            else{
                doAlamoFire.sharedInstance.request(url, method: .post, parameters: parameters, encoding:JSONEncoding.default, headers: headers)
                    .responseJSON { response in
                        if let status = response.response?.statusCode
                        {
                            switch(status){
                            case 200:
                                self.receivedData = response.result.value as! [String : Any]?
                                self.delegate?.onResult(resultData: self.receivedData!,ServiceName:self.apiName!)
                            default:
                                let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                self.delegate?.onFault(resultData: self.receivedData!,ServiceName:self.apiName!)
                            }
                        }
                }
            }
        }
        else{
            Utils.HideAllHud()
            let alert = UIAlertController(title: "No Internet", message: "Please check your Internet connection.", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default)
            { (alert) in

                self.callPostURL(url: url, parameters: parameters, encodingType: encodingType,headers: headers)
            }
            alert.addAction(retryAction)
             presetAlertController(controller:alert)
        }
    }
    //MARK: Synchronous POST 
    func callSynchronousPostURL(url:URL,parameters:[String:Any],encodingType:String,headers:[String : String]?) -> Void
    {
        if self.checkInternetStatus()
        {
            let response = Alamofire.request(url, method: .post, parameters: parameters, encoding:URLEncoding.httpBody, headers: headers).responseJSON(options: .allowFragments)
       
            if let status = response.response?.statusCode
            {
                switch(status)
                {
                    case 200:
                        if let signupResponse = response.result.value
                        {
                            self.delegate?.onResult(resultData: signupResponse,ServiceName:self.apiName!)
                        }
                        break
                    default:
                        let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                        self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                        self.delegate?.onFault(resultData: self.receivedData!,ServiceName:self.apiName!)
                        break
                }
            }
        }
        else
        {
            Utils.HideAllHud()
            let alert = UIAlertController(title: "No Internet", message: "Please check your Internet connection.", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default)
            { (alert) in
                
                self.callSynchronousPostURL(url: url, parameters: parameters, encodingType: encodingType,headers: headers)
            }
            alert.addAction(retryAction)
            presetAlertController(controller:alert)
        }
    }
    //MARK: DownloadImage 
    func downloadImage(url:String,savedImageName:String)
    {
        if self.checkInternetStatus()
        {
         //   Utils.Show()
           Alamofire.request(url).responseImage { response in
            if let image = response.result.value {
                if let data = UIImagePNGRepresentation(image) {
                    let filename = self.getDocumentsDirectory().appendingPathComponent(savedImageName)
                  //  print("filename \(filename)")
                    try? data.write(to: filename)
                }
            }
        }
        }
        else{
            Utils.HideAllHud()
            let alert = UIAlertController(title: "No Internet", message: "Please check your Internet connection.", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default)
            { (alert) in

                self.downloadImage(url:url,savedImageName:savedImageName)
            }
            alert.addAction(retryAction)
             presetAlertController(controller:alert)
        }
    }

    func getDocumentsDirectory() -> URL {

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirectory = paths[0]

        return docDirectory
    }

   //MARK: Upload Image 
    func uploadImagesAndData(url:String,params:[String : AnyObject]?,image1: UIImage,headers : [String : String],fileName:String) -> Void
    {
        if self.checkInternetStatus()
        {
            let imageData = UIImagePNGRepresentation(image1)
            doAlamoFire.sharedInstance.upload(multipartFormData: { multipartFormData in
                if params != nil
                {
                    for (key,value) in params!
                    {
                        multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                    }
                }
                multipartFormData.append(imageData!, withName: "File", fileName: fileName, mimeType: "image/png")
               },
                     to: url,
                     method:.post,
                     headers:headers,
                     encodingCompletion: { encodingResult in

                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.validate()
                            .responseJSON { response in

                                        switch response.result {

                                        case .success:

                                            if let status = response.response?.statusCode
                                            {
                                                switch(status){

                                                case 200:
                                                    //print(response.result.value)
                                                    self.receivedData = response.result.value as! [String : Any]?
                                                    self.delegate?.onResult(resultData: self.receivedData!,ServiceName:self.apiName!)
                                                    break
                                                default:
                                                    let dict:NSDictionary = (response.result.value as! NSDictionary?)!
                                                    self.receivedData = dict.object(forKey: "error") as! [String : Any]?
                                                    self.delegate?.onFault(resultData: self.receivedData!,ServiceName:self.apiName!)
                                                    break
                                                }
                                            }
                                            break
                                        case .failure(let error):
                                            Utils.HideAllHud()
                                            print("upload image error",error.localizedDescription)
                                            break
                                        }
                                    }
                        break
                    case .failure(let error):
                        Utils.HideAllHud()
                        print("upload image error",error.localizedDescription)
                        break
                    }
            })
          }
        else{
            Utils.HideAllHud()
            let alert = UIAlertController(title: "No Internet", message: "Please check your Internet connection.", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default)
            { (alert) in

               self.uploadImagesAndData(url:url,params:params , image1: image1,headers :headers,fileName: fileName)
            }
            alert.addAction(retryAction)
            presetAlertController(controller:alert)
        }

    }
    //MARK: CancelRequest 
    func cancelNetworkRequest()
    {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    func presetAlertController(controller:UIAlertController)
    {
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        rootViewController?.present(controller, animated: true, completion: nil)
    }
}
