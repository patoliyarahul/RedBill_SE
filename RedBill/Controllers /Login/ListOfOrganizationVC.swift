//
//  ListOfOrganizationVC.swift
//  RedBill
//
//  Created by Rahul on 9/21/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import Alamofire
import Mixpanel

class ListOfOrganizationVC: UIViewController {
    var previousParam: Parameters = [:]
    var newParam: Parameters = [:]
    
    @IBOutlet weak var viewOrganization: UIView!
}

//MARK: LifeCycle

extension ListOfOrganizationVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("parmaerer---> \(previousParam)")
        viewOrganization.layer.borderWidth = 1
        viewOrganization.layer.borderColor =  uiColorFromHex(rgbValue: 0x979797).cgColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ListOfOrganizationVC {
    func call_service_Signup() {
        Utils.Show()
        for (key, value) in previousParam {
            self.newParam[String(key)] = String(describing: value)
        }
        newParam[API_param.Signup.organization] = fixOrganizationID
        newParam[API_param.Signup.device_id] = userDefault.value(forKey:
            DefaultValues.device_id) ?? "123456789"
        Alamofire.request(URL(string: fromURL(uri: ApiName.signup))!, method: .post, parameters: newParam, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                print(response.result.value as Any)
                Utils.HideHud()
                if let json = response.result.value as? Dictionary<String, Any> {
                    if json[API_param.status] as? Int == 1 {
                        let data: Dictionary<String, Any> = (json[API_param.data] as? Dictionary<String, Any>)!
                        
                        appDelegate.cardParam = [:]
                        userDefault.set(true, forKey: Constant.kIsLoggedIn)
                        Utils.storeResponseToUserDefault(data as AnyObject)
                        
                        // Mixpanel
                        let mixpanel = Mixpanel.mainInstance()
                        mixpanel.createAlias(userDefault.value(forKey: API_param.Login.UserId)! as! String,
                                             distinctId: mixpanel.distinctId);
                        // To create a user profile, you must call identify
                        mixpanel.identify(distinctId: mixpanel.distinctId)
                        // Mixpanel
                        
                        self.performSegue(withIdentifier: SegueIdentifire.LoginSegue, sender: self)
                    }else {
                        Utils.showAlert("Error", message: "\(String(describing: json[API_param.message]!))", controller: self)
                    }
                }
        }
    }
}

extension ListOfOrganizationVC {
    @IBAction func btnContinueClicked(_ sender: Any) {
        self.view.endEditing(true)
        call_service_Signup()
    }
}

