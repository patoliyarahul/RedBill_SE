//
//  SupportVC.swift
//  Get Nue
//
//  Created by Patoliya Rahul on 5/8/17.
//  Copyright © 2017 Rahul Patoliya. All rights reserved.
//

import UIKit
import Alamofire

class SupportVC: UIViewController {
    
    let service = Service()
    
    @IBOutlet  var txtName: DBTextField!
    @IBOutlet  var txtEmail: DBTextField!
    @IBOutlet  var txtNote: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addValidationToTextField()
        service.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addValidationToTextField() {
        txtName.mendatoryMessage = MESSAGES.first_empty
        txtEmail.mendatoryMessage = MESSAGES.email_empty
        txtEmail.addRegEx(regEx: Regx.email, withMessage: MESSAGES.email_valid)
    }
    
    func callContactSupportService() {
        Utils.Show()
        let data: [String: Any] = ["email": "\(txtEmail.text!)",
            "name"    : "\(txtName.text!)",
            API_param.message : "\(txtNote.text!)",
            "subject"     : "From \(String(describing: userDefault.string(forKey: API_param.Signup.first_name))) \(String(describing: userDefault.string(forKey: API_param.Signup.last_name)))"]
        self.service.apiName = ApiName.support
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.support))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    //MARK: - UIButton Action Methods
    @IBAction func btnSendMessage_Click(_ sender: Any) {
        if txtName.validate() && txtEmail.validate() {
            
            if txtNote.text.count == 0 {
                helperOb.toast("Please enter message!")
            }else {
                callContactSupportService()
            }
        }
    }
}

//MARK: - Network Call Delegate 
extension SupportVC : ServiceDelegate {
    internal func onFault(resultData:[String:Any]?,ServiceName:String) {
        Utils.HideHud()
        if resultData != nil {
        }
    }
    
    func onResult(resultData:Any?,ServiceName:String) {
        Utils.HideHud()
        if ServiceName.isEqual(ApiName.support) {
            if let resultDict = resultData as? [String: Any] {
                if resultDict[API_param.status] as? Int == 1{
                    let alertController = UIAlertController(title: "Message Sent Successfully", message: "We will contact you soon.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                        self.txtEmail.text   = ""
                        self.txtName.text    = ""
                        self.txtNote.text    = ""
                        self.navigationController?.popViewController(animated: true)
                    })
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
    }
}
