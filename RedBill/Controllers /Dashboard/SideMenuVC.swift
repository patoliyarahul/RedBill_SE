//
//  SideMenuVC.swift
//  RedBill
//
//  Created by Rahul on 10/16/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit

class SideMenuVC: UIViewController {
    
    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var txtMinPrice: TextFieldValidator!
    @IBOutlet weak var txtMaxPrice: TextFieldValidator!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var txtCategory: TextFieldValidator!
    
    let categoryPicker = UIPickerView()
    var index: Int = 0
}

extension SideMenuVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setText() {
        
        sliderView.maximumValue = 100.0
        sliderView.minimumValue = 0.0
        
        txtCategory.updateLengthValidationMsg(MESSAGES.category_empty)
        txtMinPrice.updateLengthValidationMsg(MESSAGES.minPice_empty)
        txtMaxPrice.updateLengthValidationMsg(MESSAGES.maxPice_empty)
        
        btnApply.layer.cornerRadius = 6.0
        btnApply.layer.borderWidth = 1.0
        self.view.layoutIfNeeded()
        
        //        txtMinPrice.text = "\(appDelegate.minValue)"
        //        txtMaxPrice.text = "\(appDelegate.maxValue)"
        txtCategory.text = ""
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.selectRow(appDelegate.globalCatIndex, inComponent: 0, animated: true)
        txtCategory.inputView = categoryPicker
        txtCategory.tintColor = UIColor(red: 241.0/255, green: 243.0/255, blue: 248.0/255, alpha: 1)
    }
    
    func resetText() {
        categoryPicker.selectRow(0, inComponent: 0, animated: true)
        txtMaxPrice.text = ""
        txtMinPrice.text = ""
        sliderView.value = 50.0
        txtCategory.text = ""
        index = 0
        
        appDelegate.globalCatIndex = index
        appDelegate.minValue = 0.0
        appDelegate.maxValue = 0.0
        NotificationCenter.default.post(name: closeNotificationName, object: nil)
    }
}

extension SideMenuVC {
    @IBAction func btnClose_click(_ sender: Any) {
        self.view.endEditing(true)
        NotificationCenter.default.post(name: closeNotificationName, object: nil)
    }
    
    @IBAction func btnResetClicked(_ sender: Any) {
        self.view.endEditing(true)
        resetText()
    }
    @IBAction func btnApplyClicked(_ sender: Any) {
        self.view.endEditing(true)
        
        let min: Float = txtMinPrice.text!.characters.count > 0 ? Float(txtMinPrice.text!)! : 0.0
        let max: Float = txtMaxPrice.text!.characters.count > 0 ? Float(txtMaxPrice.text!)! : 0.0
    
        if max >= min {
            appDelegate.globalCatIndex = index
            appDelegate.minValue = min
            appDelegate.maxValue = max
            NotificationCenter.default.post(name: closeNotificationName, object: nil)
            
        }else {
            Utils.showAlert("Error", message: MESSAGES.maxPice_inValid, controller: self)
        }
    }
}

extension SideMenuVC: UITextFieldDelegate {
    //Textfield delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { // return NO to not change text
        
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            return true
        case ".":
            let array = Array(textField.text!)
            var decimalCount:Int = 0
            for character in array {
                if character == "." {
                    decimalCount = decimalCount+1
                }
            }
            
            if decimalCount == 1 {
                return false
            } else {
                return true
            }
        default:
            let array = Array(string)
            if array.count == 0 {
                return true
            }
            return false
        }
    }
}
extension CALayer {
    var borderWidthIB: NSNumber {
        get {
            return NSNumber(value: Float(borderWidth))
        }
        set {
            borderWidth = CGFloat(newValue.floatValue)
        }
    }
    var borderColorIB: UIColor? {
        get {
            return borderColor != nil ? UIColor(cgColor: borderColor!) : nil
        }
        set {
            borderColor = newValue?.cgColor
        }
    }
    var cornerRadiusIB: NSNumber {
        get {
            return NSNumber(value: Float(cornerRadius))
        }
        set {
            cornerRadius = CGFloat(newValue.floatValue)
        }
    }
}

//MARK: - UIPickerDelegaet

extension SideMenuVC : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return appDelegate.arrCategoryWithAll.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return appDelegate.arrCategoryWithAll[row][API_param.Product.name] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtCategory.text = (appDelegate.arrCategoryWithAll[row][API_param.Product.name] as! String)
        index = row
    }
}
