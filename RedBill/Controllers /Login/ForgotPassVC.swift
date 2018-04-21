//
//  ForgotPassVC.swift
//  RedBill
//
//  Created by Rahul on 9/20/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import Alamofire

class ForgotPassVC: UIViewController {
    @IBOutlet weak var txtEmail: DBTextField!
}

//MARK: LifeCycle
extension ForgotPassVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        addValidationToTextFiled()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - Initialization Method
extension ForgotPassVC {
    
    func addValidationToTextFiled() {
        txtEmail.mendatoryMessage = MESSAGES.email_empty
        txtEmail.addRegEx(regEx: Regx.email, withMessage: MESSAGES.email_valid)
    }
    
    //MARK: - WebService Methods
    func callService_forgotPass() {
        let params: Parameters = [API_param.Login.email : txtEmail.text!]
        Utils.Show()
        
        Alamofire.request(URL(string: fromURL(uri: ApiName.forgot_password))!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                //                print(response.result.value as Any)   // result of response serialization
                Utils.HideHud()
                if let json = response.result.value as? Dictionary<String, Any> {
                    if json[API_param.status] as? Int == 1 {
                        
                        let confirmAction = UIAlertController(title: "Success", message: "\(String(describing: json[API_param.message]!))", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                            self.navigationController?.popViewController(animated: true)
                        })
                        confirmAction.addAction(okAction)
                        self.present(confirmAction, animated: true, completion: nil)
                        
                    }else {
                        Utils.showAlert("Error", message: "\(String(describing: json[API_param.message]!))", controller: self)
                    }
                }
        }
    }
}

//MARK: - UIButton Action Methods
extension ForgotPassVC {
    @IBAction func btnResetPassClicked(_ sender: Any) {
        self.view.endEditing(true)
        if txtEmail.validate() {
            callService_forgotPass()
        }
    }
}
