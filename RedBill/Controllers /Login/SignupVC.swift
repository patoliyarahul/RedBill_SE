//
//  SignupVC.swift
//  RedBill
//
//  Created by Rahul on 9/20/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import Alamofire
import Mixpanel

class SignupVC: UIViewController {
    @IBOutlet weak var txtFName: DBTextField!
    @IBOutlet weak var txtLName: DBTextField!
    @IBOutlet weak var txtEmail: DBTextField!
    @IBOutlet weak var txtPassword: DBTextField!
    @IBOutlet weak var txtPhone: DBTextField!
    let service = Service()
}

//MARK: LifeCycle
extension SignupVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        addValidationToTextFiled()
        service.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
        if segue.identifier == SegueIdentifire.Payment {
            let params: Parameters = [API_param.Signup.first_name : txtFName.text!,
                                      API_param.Signup.last_name: txtLName.text!,
                                      API_param.Signup.email: txtEmail.text!,
                                      API_param.Signup.password: txtPassword.text!,
                                      API_param.Signup.phone: txtPhone.text!]
            let dv = segue.destination as! AddPaymentVC
            dv.previousParam = params
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SignupVC {
    
    func addValidationToTextFiled() {
        txtEmail.mendatoryMessage = MESSAGES.email_empty
        txtPassword.mendatoryMessage = MESSAGES.pass_empty
        txtFName.mendatoryMessage = MESSAGES.firstName_empty
        txtLName.mendatoryMessage = MESSAGES.lastName_empty
        txtPhone.mendatoryMessage = MESSAGES.phone_empty
        
        txtEmail.addRegEx(regEx: Regx.email, withMessage: MESSAGES.email_valid)
        txtPassword.addRegEx(regEx: Regx.pass, withMessage: MESSAGES.pass_valid)
        txtFName.addRegEx(regEx: Regx.firstName, withMessage: MESSAGES.firstName_valid)
        txtLName.addRegEx(regEx: Regx.lastName, withMessage: MESSAGES.lastName_valid)
        txtPhone.addRegEx(regEx: Regx.phone, withMessage: MESSAGES.phone_valid)
    }
    
    //MARK: - WebService Methods
    func call_check_email() {
        let data: [String: Any] = [API_param.Signup.email: "\(txtEmail.text!)"]
        self.service.apiName = ApiName.check_email
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.check_email))!, parameters: data,encodingType:"json",headers:nil)
    }
}

//MARK: - UIButton Action Methods
extension SignupVC {
    @IBAction func btnContinueClicked(_ sender: Any) {
        self.view.endEditing(true)
        if txtFName.validate() && txtLName.validate() && txtEmail.validate() && txtPassword.validate() && txtPhone.validate() {
            call_check_email()
        }
    }
}

//MARK: - TextField Delegate
extension SignupVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtPhone {
            let length = Int(self.getLength(textField.text!))
            
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            if string == numberFiltered {
                if length == 10 {
                    if range.length == 0 {
                        return false
                    }
                }
                else if length == 3 {
                    let num = self.formatNumber(mobileNumber: textField.text!)
                    textField.text = "\(num)-"
                    if range.length > 0 {
                        textField.text = "\(num.substring(to: num.index(num.startIndex, offsetBy: 3)))"
                    }
                } else if length == 6 {
                    let num = self.formatNumber(mobileNumber: textField.text!)
                    textField.text = "\(num.substring(to: num.index(num.startIndex, offsetBy: 3)))-\(num.substring(from: num.index(num.startIndex, offsetBy: 3)))-"
                    if range.length > 0 {
                        textField.text = "\(num.substring(to: num.index(num.startIndex, offsetBy: 3)))-\(num.substring(from: num.index(num.startIndex, offsetBy: 3)))"
                    }
                }
                return true;
                
            } else {
                return string == numberFiltered
            }
        }else {
            return true
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
        let length = Int(mobileNumber.count)
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
        let length = Int(mobileNumber.count)
        return length
    }
}

extension SignupVC : ServiceDelegate {
    internal func onFault(resultData:[String:Any]?,ServiceName:String) {
        Utils.HideHud()
        if resultData != nil {
            helperOb.toast(resultData![API_param.message] as! String)
        }
    }
    
    func onResult(resultData:Any?,ServiceName:String) {
        Utils.HideHud()
        if ServiceName.isEqual(ApiName.check_email) {
            if let resultDict = resultData as? [String: Any] {
                if resultDict[API_param.status] as? Int == 1 {
                    let alertWithBlock = UIAlertController(title: MESSAGES.error, message: "This email is already in use!", actions:.custom("OK",.destructive),style:.alert){ action -> Void in
                        Mixpanel.mainInstance().track(event: "Signup New user",
                                                      properties: nil)
                    }
                    self.present(alertWithBlock, animated: true, completion: nil)
               }else {
                    self.performSegue(withIdentifier: SegueIdentifire.Payment, sender: self)
                }
            }
        }
    }
}
