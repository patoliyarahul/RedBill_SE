//
//  LoginVC.swift
//  RedBill
//
//  Created by Rahul on 9/20/17.
//  Copyright © 2017 Rahul. All rights reserved.
//


import UIKit
import Alamofire

class LoginVC: UIViewController {
    
    @IBOutlet weak var txtEmail: DBTextField!
    @IBOutlet weak var txtPassword: DBTextField!
}

//MARK: LifeCycle
extension LoginVC {
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addValidationToTextFiled()
        
        txtEmail.text = ""
        txtPassword.text = ""

//        txtEmail.text = "jikadrajaydeep@gmail.com"
////        txtEmail.text = "patoliyarahul@gmail.com"
//        txtPassword.text = "123456789"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
}

//MARK: - Initialization Method
extension LoginVC {
    func addValidationToTextFiled() {
        txtEmail.mendatoryMessage = MESSAGES.email_empty
        txtPassword.mendatoryMessage = MESSAGES.pass_empty
        
        txtEmail.addRegEx(regEx: Regx.email, withMessage: MESSAGES.email_valid)
        txtPassword.addRegEx(regEx: Regx.pass, withMessage: MESSAGES.pass_valid)
    }
    //MARK: - WebService Methods
    func callService_login() {
       let params: Parameters = [API_param.Login.email : txtEmail.text!,
                                  API_param.Login.password: txtPassword.text!,
                                  API_param.Login.type: DefaultValues.device_type_val,
                                  API_param.Login.latitude: "",
                                  API_param.Login.longitude: "",
//                                  API_param.Login.fb_token: userInfo["id"]!,
                                  API_param.Login.login_type: "1", // 1 for Normal login
                                  API_param.Login.device_id: userDefault.value(forKey: DefaultValues.device_id) ?? ""]
        
        Utils.Show()
        Alamofire.request(URL(string: fromURL(uri: ApiName.post_login))!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                print(response.result.value as Any)   // result of response serialization
                Utils.HideHud()
                if let json = response.result.value as? Dictionary<String, Any> {
                    if json[API_param.status] as? Int == 1 {
                        let data: Dictionary<String, Any> = (json[API_param.data] as? Dictionary<String, Any>)!
//                        print("data --> \(data)")
                        
                        userDefault.set(true, forKey: Constant.kIsLoggedIn)
                        Utils.storeResponseToUserDefault(data as AnyObject)
                        
                        self.performSegue(withIdentifier: SegueIdentifire.LoginSegue, sender: self)
                    }else {
                        print("Message : \(String(describing: json[API_param.message]!))")
                        Utils.showAlert("Error", message: "\(String(describing: json[API_param.message]!))", controller: self)
                    }
                }
        }
    }
}

//MARK: - UIButton Action Methods
extension LoginVC {
    @IBAction func btn_LoginClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if txtEmail.validate() && txtPassword.validate() {
            callService_login()
        }
    }
}
