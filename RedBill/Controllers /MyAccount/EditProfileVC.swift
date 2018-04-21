//
//  EditProfileVC.swift
//  Get Nue
//
//  Created by Patoliya Rahul on 6/6/17.
//  Copyright © 2017 Rahul Patoliya. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController {

    @IBOutlet weak var txtEmail: DBTextField!
    @IBOutlet weak var txtMobileNo: DBTextField!
    @IBOutlet weak var txtLastName: DBTextField!
    @IBOutlet weak var txtFirstName: DBTextField!
    
    let service = Service()

}

//MARK: LifeCycle

extension EditProfileVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        addValidationToTextFied()
        service.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - Methods

extension EditProfileVC {
    
    func loadData() {
        print("name -> \(userDefault.string(forKey: API_param.Signup.first_name)!)")
        
        txtFirstName.text = userDefault.string(forKey: API_param.Signup.first_name)
        txtLastName.text = userDefault.string(forKey: API_param.Signup.last_name)
        txtMobileNo.text = userDefault.string(forKey: API_param.Signup.phone)
        txtEmail.text = userDefault.string(forKey: API_param.Signup.email)
        txtEmail.isMendatory = false
    }
    
    func addValidationToTextFied() {

        txtFirstName.mendatoryMessage = MESSAGES.firstName_empty
        txtLastName.mendatoryMessage = MESSAGES.lastName_empty
        txtMobileNo.mendatoryMessage = MESSAGES.phone_empty

        txtMobileNo.addRegEx(regEx: Regx.phone, withMessage: MESSAGES.phone_valid)
    }
    
    func callService_edit_profile() {
        let data: [String: Any] = [API_param.Login.UserId : userDefault.string(forKey: API_param.Login.UserId)!,
                                    API_param.Signup.first_name: "\(txtFirstName.text!)",
                                    API_param.Signup.last_name: "\(txtLastName.text!)",
                                    API_param.Signup.email: "\(txtEmail.text!)",
                                    API_param.Signup.phone: "\(txtMobileNo.text!)"]

        self.service.apiName = ApiName.update_profile
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.update_profile))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    func deleteProfile() {
        let data: [String: Any] = [API_param.Login.UserId : userDefault.string(forKey: API_param.Login.UserId)!]
        
        self.service.apiName = ApiName.delete_profile
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.delete_profile))!, parameters: data,encodingType:"json",headers:nil)
    }
}

//MARK: - UIButton Action Methods

extension EditProfileVC {
    @IBAction func btnSaveClicked(_ sender: Any) {
        if txtFirstName.validate() && txtLastName.validate() && txtMobileNo.validate() {
            callService_edit_profile()
        }
    }
    
    @IBAction func btnDeleteAccountClicked(_ sender: Any) {
        
        let confirmDelete = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete your acoount?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
//            self.deleteProfile() //RK  change
            self.navigationController?.popToRootViewController(animated: true) //RK REMOVE IT
        })
        
        let cancelAction = UIAlertAction(title: staus.Cancel, style: .cancel, handler: { (alert) in})
        confirmDelete.addAction(okAction)
        confirmDelete.addAction(cancelAction)
        self.present(confirmDelete, animated: true, completion: nil)
    }
}

//MARK: - TextField Delegate
extension EditProfileVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtMobileNo {
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
        }else if textField == txtEmail {
            return false
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

extension EditProfileVC : ServiceDelegate
{
    internal func onFault(resultData:[String:Any]?,ServiceName:String)
    {
        Utils.HideHud()
        if resultData != nil
        {
            helperOb.toast(resultData![API_param.message] as! String)
        }
    }
    
    func onResult(resultData:Any?,ServiceName:String)
    {
        Utils.HideHud()
        if ServiceName.isEqual(ApiName.update_profile)
        {
            if let resultDict = resultData as? [String: Any]
            {
                if resultDict[API_param.status] as? Int == 1{
                    let data: Dictionary<String, Any> = (resultDict[API_param.data] as? Dictionary<String, Any>)!
//                    print("data --> \(data)")
                    Utils.storeResponseToUserDefault(data as AnyObject)
                    helperOb.toast(resultDict[API_param.message] as! String)
                    self.navigationController?.popViewController(animated: true)
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
        else if ServiceName.isEqual(ApiName.delete_profile)
        {
            if let resultDict = resultData as? [String: Any]
            {
                if resultDict[API_param.status] as? Int == 1{
                    helperOb.toast(resultDict[API_param.message] as! String)
                    self.navigationController?.popToRootViewController(animated: true)
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
    }
}
