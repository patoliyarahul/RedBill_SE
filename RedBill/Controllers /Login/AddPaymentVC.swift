//
//  AddPaymentVC.swift
//  RedBill
//
//  Created by Rahul on 9/20/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import Alamofire

class AddPaymentVC: UIViewController {
    
    var previousParam: Parameters = [:]
    var newParam: Parameters = [:]
    
    let datePicker = MonthYearPickerView()
    
    @IBOutlet weak var txtCardNo: DBTextField!
    @IBOutlet weak var txtCVV: DBTextField!
    @IBOutlet weak var txtExpirDate: DBTextField!
    @IBOutlet weak var txtZip: DBTextField!
    
}

//MARK: LifeCycle
extension AddPaymentVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addValidationToTextFiled()
        addPicker()
        
        print("previousParam ---> \(previousParam)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
        if segue.identifier == SegueIdentifire.Organization {
            
            for (key, value) in previousParam {
                self.newParam[String(key)] = String(describing: value)
            }
            
            newParam[API_param.Signup.card_number] = txtCardNo.text!
            newParam[API_param.Signup.cvv] = txtCVV.text!
            newParam[API_param.Signup.expiry_date] = txtExpirDate.text!
            newParam[API_param.Signup.billing_zip_code] = txtZip.text!
            
            let dv = segue.destination as! ListOfOrganizationVC
            dv.previousParam = newParam
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - Initialization Method
extension AddPaymentVC {
    func addValidationToTextFiled() {
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
            self.txtExpirDate.text = String(format: "%d/%@", month,String(String(year).characters.suffix(2)))
        }
        datePicker.commonSetup()
        datePicker.pickerView(datePicker, didSelectRow: datePicker.currentMonth, inComponent: 0)
    }
}

//MARK: - UIButton Action Methods
extension AddPaymentVC {
    @IBAction func cardChanged(_ sender: Any) {
        if txtCardNo.text!.characters.count > 3 {
            
            let cardName: String = identifyCreditCard(cardNumber: txtCardNo.text!)
            txtCardNo.text! = txtCardNo.text!.replacingOccurrences(of: "-", with: "")
            
            if (cardName == "express") {
                if txtCardNo.text!.characters.count <= 15 {
                    var newCard: String = ""
                    var ii: Int = 0
                    for i in 0..<txtCardNo.text!.characters.count {
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
                if txtCardNo.text!.characters.count <= 16 {
                    var newCard: String = ""
                    var ii: Int = 0
                    for i in 0..<txtCardNo.text!.characters.count {
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
                if txtCardNo.text!.characters.count <= 16 {
                    var newCard: String = ""
                    var ii: Int = 0
                    for i in 0..<txtCardNo.text!.characters.count {
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
    
    @IBAction func btnSaveClicked(_ sender: Any) {
        self.view.endEditing(true)
        if txtCardNo.validate() && txtCVV.validate() && txtZip.validate() && txtExpirDate.validate() {
            self.performSegue(withIdentifier: SegueIdentifire.Organization, sender: self)
        }
    }
}

//MARK: - TextField Delegate
extension AddPaymentVC : UITextFieldDelegate {
    
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
            
            let newLength : Int = textField.text!.characters.count + string.characters.count - range.length
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
            
            let newLength : Int = textField.text!.characters.count + string.characters.count - range.length
            if (newLength > 4) {
                result =  false
            }
            return result
        }else if(txtExpirDate == textField){
            return false
        }else if(txtZip == textField){
            
            var result : Bool = true
            
            let newLength = textField.text!.characters.count + string.characters.count - range.length
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
