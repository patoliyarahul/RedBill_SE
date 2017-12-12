//
//  ManageListingVC.swift
//  RedBill
//
//  Created by Rahul on 10/24/17.
//  Copyright © 2017 Rahul. All rights reserved.
//


/*
 //MARK: - LifeCycle
 
 //MARK: - Initialization Method
 
 //MARK: - UIButton Action Methods
 
 //MARK: - TextfieldDelegate Methods
 
 //MARK: - WebService Methods
 */

import UIKit
import Alamofire

class ManageListingVC: UIViewController {
    var dict = Dictionary<String, Any> ()
    var isEdit: Bool = false
    
    var imagePath: String = ""
    var pic: UIImage = UIImage()
    var isFromCamera: Bool = false
    
    let categoryPicker = UIPickerView()
    var arrImage = [Any]()
    
    var index:Int = -1
    let defaultComment = "Add your description here."
    var status = ""
    
    @IBOutlet weak var btnEditStatus: UIButton!
    @IBOutlet weak var cnstrRemoveButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var txtCategory: TextFieldValidator!
    @IBOutlet weak var txtTitle: TextFieldValidator!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtPrice: TextFieldValidator!
    @IBOutlet weak var collectionPhoto: UICollectionView!
    @IBOutlet weak var btnSubmite: UIButton!
    
    
    //    var isBeingPresented: Bool
}

//MARK: - LifeCycle
extension ManageListingVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("first")
        if isEdit {
            self.navigationItem.title = "Update Listing"
            status = dict[API_param.Product.status] as! String
        }else {
            self.navigationItem.title = "Create Listing"
            self.cnstrRemoveButtonHeight.constant = 0
            self.view.updateConstraintsIfNeeded()
            self.view.layoutIfNeeded()
        }
        
        txtCategory.updateLengthValidationMsg(MESSAGES.card_empty)
        txtTitle.updateLengthValidationMsg(MESSAGES.title_empty)
        txtPrice.updateLengthValidationMsg(MESSAGES.price_empty)
        
        txtPrice.addRegx(Regx.price, withMsg: MESSAGES.price_valid)
        txtTitle.addRegx(Regx.title, withMsg: MESSAGES.title_valid)
        
        setText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("first")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

//MARK: - Initialization Method
extension ManageListingVC {
    func setText() {
        
        setPickerData()
        
        if isEdit {
            txtDescription.textColor = uiColorFromHex(rgbValue: 0x5E5E5E)

            txtTitle.text = (dict[API_param.Product.title] as! String)
            txtPrice.text =  (dict[API_param.Product.price] as! String)
            txtDescription.text =  dict[API_param.Product.description] as! String
            btnSubmite.setTitle("Save", for: .normal)
            
            self.arrImage = dict[API_param.Product.images]! as! [Any]
            self.collectionPhoto.reloadData()
            switch status {
            case "A":
                btnEditStatus.setTitle("Remove Listing", for: .normal)
                btnEditStatus.setTitleColor(uiColorFromHex(rgbValue: 0xEA1917), for: .normal)
            case "D":
                btnEditStatus.setTitle("Enable Lisitng", for: .normal)
                btnEditStatus.setTitleColor(uiColorFromHex(rgbValue: 0x00B4B2), for: .normal)
            default:
                btnEditStatus.setTitle("Remove Listing", for: .normal)
                btnEditStatus.setTitleColor(uiColorFromHex(rgbValue: 0xEA1917), for: .normal)
            }
        }else {
            txtDescription.textColor = UIColor.lightGray
            
            if isFromCamera {
                self.arrImage.append(pic)
                self.collectionPhoto.reloadData()
            }
        }
    }
    
    func setPickerData() {
        func indexOfCategory(_ id: Int) -> Int {
            
            let k = appDelegate.arrCategory as Array
            let indexK = k.index {
                if let dic = $0 as? Dictionary<String,AnyObject> {
                    let value = dic["category_id"]  as? String
                    if Int(value!)! == id  {
                        return true
                    }
                }
                return false
            }
            return indexK!
        }
        
        
        if appDelegate.arrCategory.count > 0 {
            if self.isEdit {
                let index = Int(dict[API_param.Product.category_id] as! String)
                let indexOf = indexOfCategory(index!)
                indexOf > 5000 ? setPicker(0) : setPicker(indexOf)
                self.index = index!
            }else {
                self.setPicker(index)
            }
        }else {
            Utils.showAlert("Error", message: "There is no category avaialble!", controller: self)
        }
    }
    
    func setPicker(_ index:Int) {
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.selectRow(index, inComponent: 0, animated: true)
        txtCategory.inputView = categoryPicker
        txtCategory.tintColor = UIColor(red: 241.0/255, green: 243.0/255, blue: 248.0/255, alpha: 1)
        
        index >= 0 ? txtCategory.text = (appDelegate.arrCategory[index][API_param.Product.name] as! String) : ()
    }
}

//MARK: - UIButton Action Methods
extension ManageListingVC {
    @IBAction func btnAddPhotoClicked(_ sender: Any) {
        self.view.endEditing(true)
        if self.arrImage.count >= 5 {
            Utils.showAlert("Error", message: "You can only add 5 images!", controller: self)
            
        }else {
            let actionSheet = UIAlertController(title: "Add Photos", message: "", preferredStyle: .actionSheet)
            let takePhotoAction = UIAlertAction(title: "Take a Photo", style: .default, handler: { action in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera;
                    imagePicker.allowsEditing = false
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            let uploadPhotoAction = UIAlertAction(title: "Upload Photo", style: .default, handler: { action in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary;
                    imagePicker.allowsEditing = false
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            actionSheet.addAction(takePhotoAction)
            actionSheet.addAction(uploadPhotoAction)
            actionSheet.addAction(cancelAction)
            
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func btnCloseCollectionClicked(_ sender: Any) {
        let btn: UIButton = sender as! UIButton
        print("image -> \(btn.tag)")
        if self.arrImage.count > btn.tag {
            self.arrImage.remove(at: btn.tag)
            self.collectionPhoto.reloadData()
        }
    }
    
    @IBAction func btnEditStatusClicked(_ sender: Any) {
        print("status changed")
        
        let actionSheet = UIAlertController(title: "Warning!", message: "Are you sure you want to remove the listing?", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: status == "A" ? "Remove Lisitng" : "Enable Lisitng", style: .default, handler: { action in
            
            let changeStatus = self.status == "A" ? "D" : "A"
            updateStatus_Service(changeStatus)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(action1)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
        func updateStatus_Service(_ statusCode: String){
            
            let params: Parameters = [API_param.Product.product_id : "\(dict[API_param.Product.product_id]!)",
                API_param.Product.status: statusCode] // RK
            
            Utils.Show()
            
            Alamofire.request(URL(string: fromURL(uri: ApiName.UpdateListingStatus))!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    //                print(response.result.value as Any)   // result of response serialization
                    Utils.HideHud()
                    if let json = response.result.value as? Dictionary<String, Any> {
                        if json[API_param.status] as? Int == 1 {
                            let confirmAction = UIAlertController(title: "Listing Updated", message: "Your listing is now updated.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                                NotificationCenter.default.post(name: refreshManage, object: nil)
                                self.navigationController?.popToRootViewController(animated: true)
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
    
    @IBAction func btnSubmiteClicked(_ sender: Any) {
        if self.index < 0 {
            Utils.showAlert("Error", message: MESSAGES.category_empty, controller: self)
            return
        }
        
        if txtTitle.validate() && txtPrice.validate() && txtCategory.validate(){
            
            let comment = txtDescription.text == defaultComment ? "" : txtDescription.text!
            
            let parameters: Parameters = [
                API_param.Product.title : txtTitle.text!,
                API_param.Product.category_id : "\(self.index)",
                API_param.Product.description : comment,
                API_param.Product.price : NSString(format: "%.2f", Float(txtPrice.text!)!),
                API_param.Product.created_by : userDefault.value(forKey: API_param.Login.UserId)!]
            Utils.Show()
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                
                for (key,value) in parameters {
                    multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                }
                
                self.isEdit ? multipartFormData.append((self.dict[API_param.Product.product_id]! as! String).data(using: .utf8)!, withName: API_param.Product.product_id) : ()
                
                var arrUpdatedImages = [String]()
                for image in self.arrImage {
                    if image is String {
                        arrUpdatedImages.append(image as! String)
                    }else {
                        let img:UIImage = image as! UIImage
                        let imageData = UIImageJPEGRepresentation(img,0.3)
                        multipartFormData.append(imageData!, withName: "listing_image[]", fileName: "\(Date().timeIntervalSince1970).jpg",mimeType: "image/jpeg")
                    }
                }
                let arrString: String = arrUpdatedImages.joined(separator: ",")
                arrUpdatedImages.count > 0 ? multipartFormData.append(arrString.data(using: .utf8)!, withName: "update_listing_image") : ()
                
            }, to:URL(string: fromURL(uri: isEdit ? ApiName.UpdateListing : ApiName.CreateListing))!)
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print(response.result)
                        Utils.HideHud()
                        if let json = response.result.value as? Dictionary<String, Any> {
                            if json[API_param.status] as? Int == 1 {
                                print("data --> \(json)")
                                
                                let msg = self.isEdit ? "Your listing is now updated." : "Your listing is now available \nfor purchase.  You can continue \nediting the listing until it is sold."
                                
                                let confirmAction = UIAlertController(title: self.isEdit ? "Listing Updated" : "Listing Created", message: msg, preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                                    NotificationCenter.default.post(name: refreshManage, object: nil)
                                    if self.isEdit {
                                        self.navigationController?.popToRootViewController(animated: true)
                                    }else {
                                    self.dismiss(animated: true, completion: nil)
                                    }
                                })
                                confirmAction.addAction(okAction)
                                self.present(confirmAction, animated: true, completion: nil)
                                
                            }else {
                                Utils.showAlert("Error", message: "\(String(describing: json[API_param.message]!))", controller: self)
                            }
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        }
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        if Utils.isModal(self) {
            self.dismiss(animated: true) {}
        }else {
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: - TextfieldDelegate Methods
extension ManageListingVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    //MARK: - TextfieldDelegate Methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var result : Bool = true
        let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        if string != numberFiltered {
            result = false
        }
        return result
    }
}

//MARK: - UITextView Delegaet

extension ManageListingVC : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = uiColorFromHex(rgbValue: 0x5E5E5E)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = defaultComment
            textView.textColor = UIColor.lightGray
        }
    }
}

//MARK: - UICollectionView Delegate & Datasource
extension ManageListingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.arrImage.count == 0 {
            return 1
        }else {
            return self.arrImage.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell
        
        if self.arrImage.count == 0 {
            cell.btnClose.isHidden = true
        }else {
            cell.btnClose.isHidden = false }
        
        cell.btnClose.tag = indexPath.row
        cell.btnClose.addTarget(self, action: #selector(self.btnCloseCollectionClicked(_:)), for: .touchUpInside)
        if self.arrImage.count == 0 {
            cell.imgView.image = #imageLiteral(resourceName: "noimage")
        }else {
            let img = self.arrImage[indexPath.row]
            if img is String {
                let url = self.imagePath + "\(img)"
                Utils.downloadImage(url, imageView: cell.imgView)
            } else {
                cell.imgView.image = self.arrImage[indexPath.row] as? UIImage
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 95, height: 95)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        selectedIndex = indexPath
        //        self.view.endEditing(true)
        print("This is iamge is clicked ----> \(indexPath.row + 1 )")
        //        let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        //        let dict = arrItem[indexPath.row]
        //        self.performSegue(withIdentifier: SegueIdentifire.detailSgue, sender: dict)
    }
}

extension ManageListingVC : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return appDelegate.arrCategory.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return appDelegate.arrCategory[row][API_param.Product.name] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.index = Int((appDelegate.arrCategory[row][API_param.Product.category_id] as! String))!
        txtCategory.text = (appDelegate.arrCategory[row][API_param.Product.name] as! String)
    }
}

//MARK: - UIImagePickerControllerDelegate
extension ManageListingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            self.arrImage.append(editedImage)
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.arrImage.append(originalImage)
        }
        self.collectionPhoto.reloadData()
        
        dismiss(animated: true, completion: {})
    }
}
