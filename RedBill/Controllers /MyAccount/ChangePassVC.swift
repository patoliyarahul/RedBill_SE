//
//  ChangePassVC.swift
//  Get Nue
//
//  Created by Patoliya Rahul on 6/7/17.
//  Copyright © 2017 Rahul Patoliya. All rights reserved.
//

import UIKit
import Alamofire

class ChangePassVC: UIViewController {
    
    @IBOutlet weak var txtOldPassword: DBTextField!
    @IBOutlet weak var txtNewPass: DBTextField!
    @IBOutlet weak var txtConfirmPass: DBTextField!

    let service = Service()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addValidationToTextFied()
        service.delegate = self
    }
}

//MARK: - Methods

extension ChangePassVC {
    //MARK: - Initialization Method
    func addValidationToTextFied() {
        
        txtOldPassword.mendatoryMessage = MESSAGES.old_Pass_empty
        txtNewPass.mendatoryMessage = MESSAGES.new_Pass_empty
        txtConfirmPass.mendatoryMessage = MESSAGES.confirm_Pass_empty
        txtConfirmPass.addConfirmValidation(to: txtNewPass, withMessage:MESSAGES.confirm_Pass_nomatch)
        
        txtOldPassword.addRegEx(regEx: Regx.pass, withMessage: MESSAGES.pass_valid)
        txtNewPass.addRegEx(regEx: Regx.pass, withMessage: MESSAGES.pass_valid)
        txtConfirmPass.addRegEx(regEx: Regx.pass, withMessage: MESSAGES.pass_valid)
    }
    
    func callService_ResetPas() {
        let data: [String: Any] = [API_param.Login.UserId : userDefault.string(forKey: API_param.Login.UserId)!,
                                   "txt_currentpassword": "\(txtOldPassword.text!)",
                                    "txt_newpassword": "\(txtNewPass.text!)"]
        
        self.service.apiName = ApiName.change_pass
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.change_pass))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    @IBAction func btnChangePassClicked(_ sender: Any) {
        if txtOldPassword.validate() && txtNewPass.validate() && txtConfirmPass.validate() {
            callService_ResetPas()
        }
    }
}

//MARK: - UIRequestManagerDelegate

extension ChangePassVC : ServiceDelegate
{
    internal func onFault(resultData:[String:Any]?,ServiceName:String) {
        Utils.HideHud()
        if resultData != nil
        {
            helperOb.toast(resultData![API_param.message] as! String)
        }
    }
    
    func onResult(resultData:Any?,ServiceName:String)
    {
        Utils.HideHud()
        if ServiceName.isEqual(ApiName.change_pass) {
            if let resultDict = resultData as? [String: Any] {
                if resultDict[API_param.status] as? Int == 1{
                    helperOb.toast(resultDict[API_param.message] as! String)
                    self.navigationController?.popViewController(animated: true)
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
    }
}
