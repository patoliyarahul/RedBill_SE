//
//  Utils.swift
//  Allo Boulangerie
//
//  Created by Dharmesh Vaghani on 04/04/16.
//  Copyright © 2016 Dharmesh Vaghani. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

enum CharacterSetType: String {
    
    case Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
    case Numeric = "0123456789"
    case AlphaNumeric = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_. "
}

// MARK:- enum for prescrption

enum prescrptionStatus {
    case ACTIIVE
    case INACTIVE
    case UNPURCHSED
}


func getHeaderForGetRequest() -> HTTPHeaders {
    let headers : HTTPHeaders = [
        :]
    return headers
}

func getHeaderForPostRequest() -> HTTPHeaders {
    let headers : HTTPHeaders = [
        "X-SP-USER" : "|e83cf6ddcf778e37bfe3d48fc78a6502062fc",
        "Content-Type" : "application/x-www-form-urlencoded"
    ]
    
    return headers
}

func baseURL() -> String {
    return Constant.URL_PREFIX
}

func fromURL(uri : String) -> String {
    print(baseURL() + uri)
    return baseURL() + uri
}

func getConfigDict() -> [String: Any
    ] {
        var configDict = [String : Any]()
        
        if let path = Bundle.main.url(forResource: "config", withExtension: "plist") {
            if let dict = NSDictionary(contentsOf: path) as? [String: Any] {
                configDict = dict
            }
        }
        
        return configDict
}

class Utils: NSObject {
    
    class func Show(_ message:String = "Please wait"){
        var load : MBProgressHUD = MBProgressHUD()
        
        load = MBProgressHUD.showAdded(to: UIApplication.shared.windows[0], animated: true)
        load.mode = MBProgressHUDMode.indeterminate
        load.labelText = message;
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        UIApplication.shared.windows[0].addSubview(load)
    }
    
    class func HideHud(){
        DispatchQueue.main.async {
            MBProgressHUD.hideAllHUDs(for: UIApplication.shared.windows[0], animated: true)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    class func showAlert(_ title: String, message: String, controller: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    
    class func storeResponseToUserDefault(_ resultObject: AnyObject) {
        userDefault.set(true, forKey: Constant.kIsLoggedIn)
        
        for key in resultObject.allKeys {
            
            if resultObject.object(forKey: key) is NSNull {
                userDefault.set("", forKey: key as! String)
            } else {
                
                if (resultObject.object(forKey: key)! as AnyObject).isKind(of: NSDictionary.self) {
                    storeResponseToUserDefault(resultObject.object(forKey: key) as! NSDictionary)
                } else {
                    userDefault.set(resultObject.object(forKey: key), forKey: key as! String)
                }
            }
        }
        UserDefaults().synchronize()
    }
    
    class func setUserInfoObject(_ object: Any) {
        let encodedObject = NSKeyedArchiver.archivedData(withRootObject: object)
        let defaults = UserDefaults.standard
        defaults.set(encodedObject, forKey: "USERLOGINDATA");
        defaults.synchronize()
    }
    
    class func getUserInfoObject() -> Any {
        let defaults = UserDefaults.standard
        let encodedObject: Data? = defaults.object(forKey: "USERLOGINDATA") as! Data?
        if encodedObject == nil
        {
            return NSNull()
        }
        else
        {
            let object: Any? = NSKeyedUnarchiver.unarchiveObject(with: encodedObject!)
            return object!
        }
    }
    
    class func removeUserInfoObject() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "USERLOGINDATA")
        defaults.synchronize()
    }
    
    class func isObjectNotNil(_ ob: Any?) -> Bool {
        if ob == nil {
            return false
        }
        if (ob is NSNull) {
            return false
        }
        return true
    }
    
    class func downloadImage(_ url: String, imageView: UIImageView) {
        
        let finalUrl = url
        
        let imageDownloader = UIImageView.af_sharedImageDownloader
        if let imageCache2 = imageDownloader.imageCache {
            let urlRequest = URLRequest(url: URL(string: finalUrl)!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
            _ = imageCache2.removeImage(for: urlRequest, withIdentifier: nil)
        }
        
        if let encodedString = finalUrl.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlFragmentAllowed),
            let url = URL(string: encodedString) {
            
            imageView.af_setImage(withURL: url)
        }
    }
    
    class func readPlist(plistName: String) -> NSArray
    {
        var stateArray = [String]()
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: plistName, ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        let enumerator: NSEnumerator? = (myDict! as NSDictionary).objectEnumerator()
        while let key:NSMutableDictionary = enumerator?.nextObject() as! NSMutableDictionary? {
            
            stateArray.append(key.value(forKey: "state") as! String)
        }
        var sortDescriptor: NSSortDescriptor?
        sortDescriptor = NSSortDescriptor(key: nil, ascending: true)
        let sortDescriptors: [Any] = [sortDescriptor!]
        
        stateArray = (stateArray as NSArray).sortedArray(using: sortDescriptors as! [NSSortDescriptor]) as! Array
        
        print(stateArray)
        
        return stateArray as NSArray
        
    }
    
    class func validateTextFeildLength(charSetType: CharacterSetType.RawValue,text:String,length:Int) -> Bool
    {
        if text.characters.count <= length
        {
            let aSet = NSCharacterSet(charactersIn:charSetType).inverted
            let compSepByCharInSet = text.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return text == numberFiltered
        }
        else
        {
            return false
        }
        
    }
    
    
    class func isModal(_ vC:UIViewController) -> Bool {
        if vC.presentingViewController != nil {
            return true
        } else if vC.navigationController?.presentingViewController?.presentedViewController == vC.navigationController  {
            return true
        } else if vC.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
    class func formetPhoneNumber(text1:String , range:NSRange,textFeild:UITextField,txtString:String) -> Bool
    {
        
        if txtString == ""{ //BackSpace
            
            return true
            
        }else if text1.characters.count < 3{
            
            if text1.characters.count == 1{
                
                textFeild.text = "("
            }
            
        }else if text1.characters.count == 4{
            
            textFeild.text = textFeild.text! + ") "
            
        }else if text1.characters.count == 9{
            
            textFeild.text = textFeild.text! + "-"
            
        }else if text1.characters.count > 13{
            
            return false
        }
        return true
    }
}
// MARK: - Dynemic Attribuite
func addAttributes(text:String,range:NSRange,fontName:String) -> NSMutableAttributedString
{
    let multipleAttributes: [String : Any] = [
        NSFontAttributeName :UIFont.init(name:fontName, size:14)!]
    let underlineAttributedString = NSMutableAttributedString(string:text)
    underlineAttributedString.addAttributes(multipleAttributes, range: range)
    return underlineAttributedString
}

func base64forData(_ theData: Data) -> String {
    
    let strBase64 = theData.base64EncodedString(options: .lineLength64Characters)
    return strBase64
}

func convertDate(_ toDate: String, fromFormate: String, toFormate: String) -> String {
    defer {
    }
    do {
        let formatter = DateFormatter()
        formatter.dateFormat = fromFormate
        let date: Date? = formatter.date(from: toDate)
        formatter.dateFormat = toFormate
        var output: String = formatter.string(from: date!)
        if output == "" {
            output = toDate
        }
        return output
    } catch _ {
        return ""
    }
}


func configureTableView(_ myTableView: UITableView) {
    myTableView.tableFooterView = UIView()
    myTableView.rowHeight = UITableViewAutomaticDimension
    myTableView.estimatedRowHeight = 59
}

func setValueFromUserDefaultToTextField(textField: UITextField, key: String) {
    if let str = userDefault.string(forKey: key) {
        textField.text = str
    }
}

func addCurrencyprifix(value : Int)-> String {
    return "$ " + String(value)
}

func reloadTableViewWithAnimation(myTableView: UITableView) {
    let range = NSMakeRange(0, myTableView.numberOfSections)
    let sections = NSIndexSet(indexesIn: range)
    myTableView.reloadSections(sections as IndexSet, with: .automatic)
}

func checkWeatherDictIsInArray(sourceDictArray: [Dictionary<String, String>], dict: Dictionary<String, String>, key: String) -> (Bool, Int) {
    var index = 0
    for tempDict in sourceDictArray {
        if tempDict[key] == dict[key] {
            return (true, index)
        }
        index += 1
    }
    return (false, index)
}

func getAttributedTextWithSpacing(text: String) -> NSMutableAttributedString {
    let attributedAddress = NSMutableAttributedString(string: text)
    let mutableParagraphStyle = NSMutableParagraphStyle()
    mutableParagraphStyle.lineSpacing = 5
    
    attributedAddress.addAttribute(NSParagraphStyleAttributeName, value: mutableParagraphStyle, range: NSMakeRange(0, text.characters.count))
    
    return attributedAddress
}

extension Date {
    func stringDate(format: String, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}

func identifyCreditCard(cardNumber : String) -> String {
    
    var newString = cardNumber.replacingOccurrences(of: " ", with: "")
    newString = newString.replacingOccurrences(of: "-", with: "")
    
    var noOfCharacterInCard = 0
    
    let regVisa     = "^4[0-9]{12}(?:[0-9]{3})?$"
    let regMaster   = "^5[1-5][0-9]{14}$"
    let regExpress  = "^3[47][0-9]{13}$"
    let regDiners   = "^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
    let regDiscover = "^6(?:011|5[0-9]{2})[0-9]{12}$"
    let regJSB      = "^(?:2131|1800|35\\d{3})\\d{11}$"
    
    let predicateVisa       = NSPredicate(format: "self matches %@", regVisa)
    let predicateMaster     = NSPredicate(format: "self matches %@", regMaster)
    let predicateExpress    = NSPredicate(format: "self matches %@", regExpress)
    let predicateDiners     = NSPredicate(format: "self matches %@", regDiners)
    let predicateDiscover   = NSPredicate(format: "self matches %@", regDiscover)
    let predicateJSB        = NSPredicate(format: "self matches %@", regJSB)
    
    if predicateDiners.evaluate(with: newString) {
        noOfCharacterInCard = 14
        return "diners"
    } else if predicateExpress.evaluate(with: newString) {
        noOfCharacterInCard = 15
        return "express"
    } else if predicateVisa.evaluate(with: newString) {
        noOfCharacterInCard = 16
        return "visa"
    } else if predicateMaster.evaluate(with: newString) {
        noOfCharacterInCard = 16
        return "master"
    } else if predicateDiscover.evaluate(with: newString) {
        noOfCharacterInCard = 16
        return "discover"
    } else if predicateJSB.evaluate(with: newString) {
        noOfCharacterInCard = 16
        return "jsb"
    } else  {
        noOfCharacterInCard = 16
        return "none"
    }
}

func removeSpecialCharsFromString(text: String) -> String
{
    let okayChars : Set<Character> =
        Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890".characters)
    return String(text.characters.filter {okayChars.contains($0) })
}

func getHiddenCardNo (cardNumber: String) -> String {
    
    var cardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
    cardNumber = cardNumber.replacingOccurrences(of: "-", with: "")
    
    let last4 = String(cardNumber.characters.suffix(4))
    
    var paymentMethodStr = ""
    var removedSpaceStr = paymentMethodStr.replacingOccurrences(of: " ", with: "")
    
    
    for _ in 0..<(cardNumber.characters.count - 4) {
        
        paymentMethodStr.append("*")
        
        if removedSpaceStr.characters.count % 4 == 0 {
            paymentMethodStr.append(" ")
        }
    }
    return paymentMethodStr + " " + last4
}

func formetSocial(textField:UITextField,string: String,range: NSRange) -> Bool
{
    let length = Int(getLength(textField.text!))
    
    let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
    let compSepByCharInSet = string.components(separatedBy: aSet)
    let numberFiltered = compSepByCharInSet.joined(separator: "")
    
    if string == numberFiltered {
        if length == 9 {
            if range.length == 0 {
                return false
            }
        }
        else if length == 3 {
            let num = formatNumber(mobileNumber: textField.text!)
            textField.text = "\(num)-"
            if range.length > 0 {
                textField.text = "\(num.substring(to: num.index(num.startIndex, offsetBy: 3)))"
            }
        } else if length == 5 {
            let num = formatNumber(mobileNumber: textField.text!)
            textField.text = "\(num.substring(to: num.index(num.startIndex, offsetBy: 3)))-\(num.substring(from: num.index(num.startIndex, offsetBy: 3)))-"
            if range.length > 0 {
                textField.text = "\(num.substring(to: num.index(num.startIndex, offsetBy: 3)))-\(num.substring(from: num.index(num.startIndex, offsetBy: 3)))"
            }
        }
        return true;
        
    } else {
        return string == numberFiltered
    }
    
}

//MARK: - Helper Methods for textfield phone number formating

func formatNumber( mobileNumber: String) -> String {
    var mobileNumber = mobileNumber
    mobileNumber = mobileNumber.replacingOccurrences(of: "(", with: "")
    mobileNumber = mobileNumber.replacingOccurrences(of: ")", with: "")
    mobileNumber = mobileNumber.replacingOccurrences(of: " ", with: "")
    mobileNumber = mobileNumber.replacingOccurrences(of: "-", with: "")
    mobileNumber = mobileNumber.replacingOccurrences(of: "+", with: "")
    print("\(mobileNumber)")
    let length = Int(mobileNumber.characters.count)
    if length > 10 {
        mobileNumber = mobileNumber.substring(from: mobileNumber.index(mobileNumber.startIndex, offsetBy: length - 10))
    }
    return mobileNumber
}

func getLength(_ mobileNumber: String) -> Int {
    var mobileNumber = mobileNumber
    
    mobileNumber = mobileNumber.replacingOccurrences(of: "(", with: "")
    mobileNumber = mobileNumber.replacingOccurrences(of: ")", with: "")
    mobileNumber = mobileNumber.replacingOccurrences(of: " ", with: "")
    mobileNumber = mobileNumber.replacingOccurrences(of: "-", with: "")
    mobileNumber = mobileNumber.replacingOccurrences(of: "+", with: "")
    let length = Int(mobileNumber.characters.count)
    return length
}

// MARK:- find which Status From Prescrption

func whichPrescrptionStatus(status: prescrptionStatus) -> String
{
    switch status
    {
    case .ACTIIVE:
        return "A"
        
    case .INACTIVE:
        return "I"
        
    case .UNPURCHSED:
        return "U"
        
    default:
        return ""
    }
}

extension Bool {
    
    init?(string: String) {
        switch string {
        case "True", "true", "yes", "1":
            self = true
        case "False", "false", "no", "0":
            self = false
        default:
            return nil
        }
    }
}


func getListOfCategoryServiceCall(_ showHud:Bool)   {
    if showHud {
        Utils.Show()
    }
    Alamofire.request(URL(string: fromURL(uri: ApiName.GetCategory))!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
        .responseJSON { response in
            Utils.HideHud()
            if let json = response.result.value as? Dictionary<String, Any> {
                if json[API_param.status] as? Int == 1 {
                    let data: [Dictionary<String, Any>] = (json[API_param.data] as? [Dictionary<String, Any>])!
                    appDelegate.arrCategory = data
                    appDelegate.arrCategoryWithAll = data
                    appDelegate.arrCategoryWithAll.insert(["category_id":"0", "name": "All", "category_keyword": "All"], at: 0)
                }else {
//                    Utils.showAlert("Error", message: "\(String(describing: json[API_param.message]!))", controller: appDelegate.window)
                }
            }
    }
}
