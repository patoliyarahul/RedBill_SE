//
//  AddPaymentVC.swift
//  RedBill
//
//  Created by Vipul Jikadra on 25/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
//MARK: Properites
class AddPaymentCardVC: UIViewController {
    let datePicker = MonthYearPickerView()
    
    @IBOutlet weak var txtCardNo: DBTextField!
    @IBOutlet weak var txtCVV: DBTextField!
    @IBOutlet weak var txtExpirDate: DBTextField!
    @IBOutlet weak var txtZip: DBTextField!
    @IBOutlet weak var btnDefault: UIButton!
    let service = Service()
    var myCardOb:MyCardsVC?
    var cardDetailsDataOb:CardDataOb?
}
//MARK: View Life Cycle Method
extension AddPaymentCardVC
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addValidationToTextFiled()
        service.delegate = self
        addPicker()
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        guard cardDetailsDataOb != nil else
        {
           return
        }
        self.title = "Edit Payment Method"
        txtCardNo.text = cardDetailsDataOb?.card_number
        txtCVV.text = cardDetailsDataOb?.cvv
        txtExpirDate.text = cardDetailsDataOb?.expiry_date
        txtZip.text = cardDetailsDataOb?.zip_code
        btnDefault.setImage(cardDetailsDataOb?.is_default == "1" ? #imageLiteral(resourceName: "checked") : #imageLiteral(resourceName: "unchecked"), for: .normal)
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
//MARK: Common Function
extension AddPaymentCardVC
{
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
   
    }
    
    @IBAction func isDefault_Clicked(_ sender: Any)
    {
        btnDefault.isSelected = !btnDefault.isSelected
        btnDefault.setImage(btnDefault.isSelected == true ? #imageLiteral(resourceName: "checked") : #imageLiteral(resourceName: "unchecked"), for: .normal)
    }
}
//MARK: - Initialization Method
extension AddPaymentCardVC
{
    func addValidationToTextFiled()
    {
        txtCardNo.mendatoryMessage = MESSAGES.card_empty
        txtCVV.mendatoryMessage = MESSAGES.cvv_empty
        txtExpirDate.mendatoryMessage = MESSAGES.date_empty
        txtZip.mendatoryMessage = MESSAGES.zip_valid
        
        txtCVV.addRegEx(regEx: Regx.CVV, withMessage: MESSAGES.cvv_valid)
        txtZip.addRegEx(regEx: Regx.ZIPCode, withMessage: MESSAGES.zip_valid)
        txtCardNo.addRegEx(regEx: Regx.card, withMessage: MESSAGES.card_valid)
        
    }
    
    func addPicker() {
        txtExpirDate.inputView = datePicker
        datePicker.onDateSelected = { (month: Int, year: Int) in
            self.txtExpirDate.text = String(format: "%d/%@", month,String(String(year).suffix(2)))
        }
        datePicker.commonSetup()
        datePicker.pickerView(datePicker, didSelectRow: datePicker.currentMonth, inComponent: 0)
    }
}

//MARK: - UIButton Action Methods
extension AddPaymentCardVC
{
    @IBAction func cardChanged(_ sender: Any)
    {
        if txtCardNo.text!.count > 3 {
            
            let cardName: String = identifyCreditCard(cardNumber: txtCardNo.text!)
            txtCardNo.text! = txtCardNo.text!.replacingOccurrences(of: "-", with: "")
            
            if (cardName == "express") {
                if txtCardNo.text!.count <= 15 {
                    var newCard: String = ""
                    var ii: Int = 0
                    for i in 0..<txtCardNo.text!.count {
                        if (i == 4 && i > 0) || (i == 10 && i > 0) {
                            if i == 4 && i > 0 {
                                if ii < 3 {
                                    newCard = "\(newCard)-\(txtCardNo.text![txtCardNo.text!.index(txtCardNo.text!.startIndex, offsetBy: i)])"
                                    ii += 1
                                }
                                else if ii == 3 {
                                    newCard = "\(newCard)\(txtCardNo.text![txtCardNo.text!.index(txtCardNo.text!.startIndex, offsetBy: i)])"
                                    ii += 1
                                }
                            }
                            else if i == 10 && i > 0 {
                                if ii < 3 {
                                    newCard = "\(newCard)-\(txtCardNo.text![txtCardNo.text!.index(txtCardNo.text!.startIndex, offsetBy: i)])"
                                    ii += 1
                                }
                                else if ii == 3 {
                                    newCard = "\(newCard)\(txtCardNo.text![txtCardNo.text!.index(txtCardNo.text!.startIndex, offsetBy: i)])"
                                    ii += 1
                                }
                            }
                        }
                        else {
                            newCard = "\(newCard)\(txtCardNo.text![txtCardNo.text!.index(txtCardNo.text!.startIndex, offsetBy: i)])"
                        }
                    }
                    txtCardNo.text! = newCard
                }
                
            }else if (cardName == "diners") {
                if txtCardNo.text!.count <= 16 {
                    var newCard: String = ""
                    var ii: Int = 0
                    for i in 0..<txtCardNo.text!.count {
                        if i % 4 == 0 && i > 0 {
                            if ii < 3 {
                                newCard = "\(newCard)-\(txtCardNo.text![txtCardNo.text!.index(txtCardNo.text!.startIndex, offsetBy: i)])"
                                ii += 1
                            }
                            else if ii == 3 {
                                newCard = "\(newCard)\(txtCardNo.text![txtCardNo.text!.index(txtCardNo.text!.startIndex, offsetBy: i)])"
                                ii += 1
                            }
                        }
                        else {
                            newCard = "\(newCard)\(txtCardNo.text![txtCardNo.text!.index(txtCardNo.text!.startIndex, offsetBy: i)])"
                        }
                    }
                    txtCardNo.text! = newCard
                }
                
            }else  {
                if txtCardNo.text!.count <= 16 {
                    var newCard: String = ""
                    var ii: Int = 0
                    for i in 0..<txtCardNo.text!.count {
                        if i % 4 == 0 && i > 0 {
                            if ii < 3 {
                                newCard = "\(newCard)-\(txtCardNo.text![txtCardNo.text!.index(txtCardNo.text!.startIndex, offsetBy: i)])"
                                ii += 1
                            }
                            else if ii == 3 {
                                newCard = "\(newCard)\(txtCardNo.text![txtCardNo.text!.index(txtCardNo.text!.startIndex, offsetBy: i)])"
                                ii += 1
                            }
                        }
                        else {
                            newCard = "\(newCard)\(txtCardNo.text![txtCardNo.text!.index(txtCardNo.text!.startIndex, offsetBy: i)])"
                        }
                    }
                    txtCardNo.text! = newCard
                }
            }
        }
    }
    
    @IBAction func btnSaveClicked(_ sender: Any)
    {
        self.view.endEditing(true)
        if txtCardNo.validate() && txtCVV.validate() && txtZip.validate() && txtExpirDate.validate()
        {
            Utils.Show()
            var data: [String: Any] = [API_param.AddCardParams.User_Id: userDefault.value(forKey: API_param.Login.UserId)!,
                                       API_param.AddCardParams.Card_Number: txtCardNo.text!,
                                       API_param.AddCardParams.Cvv: txtCVV.text!,
                                       API_param.AddCardParams.Is_Default: btnDefault.currentImage == #imageLiteral(resourceName: "checked") ? "1" : "0",
                                       API_param.AddCardParams.Expiry_Date: txtExpirDate.text!,
                                       API_param.AddCardParams.Zip_Code: txtZip.text!]
            if cardDetailsDataOb != nil
            {
                // Update Card Details
                data[API_param.AddCardParams.Card_Id] = cardDetailsDataOb?.card_id!
                self.service.apiName = ApiName.updatePaymentCard
                self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.updatePaymentCard))!, parameters: data,encodingType:"json",headers:nil)
                return
            }
            // Add Card Details
            self.service.apiName = ApiName.addPaymentCard
            self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.addPaymentCard))!, parameters: data,encodingType:"json",headers:nil)
        }
    }
}

//MARK: - TextField Delegate
extension AddPaymentCardVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    //MARK: - TextfieldDelegate Methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (txtCardNo == textField) {
            
            var result : Bool = true
            let aSet = NSCharacterSet(charactersIn:"0123456789-").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            if string != numberFiltered {
                result = false
            }
            
            let newLength : Int = textField.text!.count + string.count - range.length
            if (newLength > 19) {
                result =  false
            }
            return result
        }else if (txtCVV == textField) {
            
            var result : Bool = true
            let aSet = NSCharacterSet(charactersIn:"0123456789-").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            if string != numberFiltered {
                result = false
            }
            
            let newLength : Int = textField.text!.count + string.count - range.length
            if (newLength > 4) {
                result =  false
            }
            return result
        }else if(txtExpirDate == textField){
            return false
        }else if(txtZip == textField){
            
            var result : Bool = true
            
            let newLength = textField.text!.count + string.count - range.length
            if newLength > 5 {
                result = false
            }
            
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if (string != numberFiltered) {
                result = false
            }
            return result
        }
        return true
    }
}
//MARK: - Network Call Delegate 
extension AddPaymentCardVC : ServiceDelegate
{
    internal func onFault(resultData:[String:Any]?,ServiceName:String)
    {
        Utils.HideHud()
        if resultData != nil
        {
//            helperOb.toast(resultDict[API_param.message] as! String)
        }
    }
    
    func onResult(resultData:Any?,ServiceName:String)
    {
        Utils.HideHud()
        if ServiceName.isEqual(ApiName.addPaymentCard)
        {
            if let resultDict = resultData as? [String: Any]
            {
                if resultDict[API_param.status] as? Int == 1{
                    myCardOb?.getSavedCards()
                    helperOb.toast(resultDict[API_param.message] as! String)
                    self.navigationController?.popViewController(animated: true)
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
        else if ServiceName.isEqual(ApiName.updatePaymentCard)
        {
            if let resultDict = resultData as? [String: Any]
            {
                if resultDict[API_param.status] as? Int == 1{
                    myCardOb?.getSavedCards()
                    helperOb.toast(resultDict[API_param.message] as! String)
                    self.navigationController?.popViewController(animated: true)
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
    }
}
