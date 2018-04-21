//
//  ProductDetailVC.swift
//  RedBill
//
//  Created by Rahul on 10/18/17.
//  Copyright © 2017 Rahul. All rights reserved.
//


import UIKit
import ImageSlideshow
import Alamofire

class ProductDetailVC: UIViewController {
    
    @IBOutlet weak var slideShow: ImageSlideshow!
    @IBOutlet weak var btnSubmite: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtPrice: DBTextField!
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var viewPrice: UIView!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var btnContactSeller: UIButton!
    
    var dictData = Dictionary<String, Any>()
    var imagePath:String = ""
    
    var alamofireSource = [AlamofireSource]()
    let localSource = [ImageSource(imageString: "no_image")!]
    var isFrom:String?
    var offDeatailsOb:OfferDeatilsOb?
    var manageOfferDataOb:ManageOfferDataOb?
    var offerDtailClassOb:OfferDetailVC?
}

//MARK: - LifeCycle
extension ProductDetailVC
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        viewPrice.isHidden = true
        viewDescription.isHidden = false
        addValidationToTextFiled()
        print("daya---->\(dictData)")
        setText()
        
        txtPrice.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        
    }
    override func viewWillAppear(_ animated: Bool) {  // dbv added navigation bar in storyboard as need to push chatview from here.......... and hide navigation bar on view will appear
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func showView(_ view: UIView)
    {
        if view == viewPrice {
            viewPrice.isHidden = false
            viewDescription.isHidden = true
            btnSubmite.setTitle("Send Offer", for: .normal)
        }
    }
}

//MARK: - Initialization Method
extension ProductDetailVC
{
    func addValidationToTextFiled()
    {
        txtPrice.mendatoryMessage = MESSAGES.price_empty
        txtPrice.addRegEx(regEx: Regx.price, withMessage: MESSAGES.price_valid)
    }
    
    func setText() {
        
        if isFrom == "OfferDetailsPage"
        {
            btnContactSeller.isHidden = true
            showView(viewPrice)
            
            if let arrImages = offDeatailsOb?.product_data?.images as? [String]
            {
                if arrImages.count >= 1
                {
                    for item in arrImages
                    {
                        let url: String = "\(Constant.baseImagePath)\(item)"
                        alamofireSource.append(AlamofireSource(urlString: url)!)
                    }
                }
            }
            lblTitle.text = offDeatailsOb?.product_data?.title!
            //            lblPrice.text = "$" + (offDeatailsOb?.product_data?.price?.description)!
            lblPrice.text = (offDeatailsOb?.product_data?.price?.description)!
            txtDescription.text = offDeatailsOb?.product_data?.description!
            lblCategory.text = offDeatailsOb?.product_data?.category_name!
            btnSubmite.setTitle("Update an Offer", for: .normal)
        }
        else
        {
            btnContactSeller.isHidden = false
            if let arrImages = dictData[API_param.Product.images]! as? [String] {
                if arrImages.count >= 1 {
                    for item in arrImages {
                        let url: String = "\(self.imagePath)\(item)"
                        alamofireSource.append(AlamofireSource(urlString: url)!)
                    }
                }
            }
            lblTitle.text = "\(dictData[API_param.Product.title]!)"
            //            lblPrice.text = "$ \(dictData[API_param.Product.price]!)"
            lblPrice.text = "$ \(dictData[API_param.Product.price]!)"
            txtDescription.text = "\(dictData[API_param.Product.description]!)"
            //            txtDescription.text = "\(String(describing: offDeatailsOb?.product_data?.description!))"
            lblCategory.text = "\(dictData[API_param.Product.category_name]!)"
            
        }
        setSlidView()
    }
    
    func setSlidView() {
        self.slideShow.backgroundColor = UIColor.black
        self.slideShow.slideshowInterval = 10.0
        self.slideShow.pageControlPosition = PageControlPosition.insideScrollView
        self.slideShow.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        self.slideShow.pageControl.pageIndicatorTintColor = UIColor.black
        self.slideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        self.slideShow.activityIndicator = DefaultActivityIndicator()
        self.slideShow.currentPageChanged = { page in
            //            print("current page:", page)
        }
        
        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        self.slideShow.setImageInputs(alamofireSource.count > 0 ? alamofireSource : localSource)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        self.slideShow.addGestureRecognizer(recognizer)
    }
    
    @objc func didTap() {
        let fullScreenController = self.slideShow.presentFullScreenController(from: self)
        // set the activity indicator for fullasreen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    func myTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
}

//MARK: - UIButton Action Methods
extension ProductDetailVC
{
    @IBAction func btnCloseClicked(_ sender: Any)
    {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func btnContactSellerClicked(_ sender: Any)
    {
        self.view.endEditing(true)
        Chat_Utils.startPrivateChat(email: "\(dictData[API_param.Product.seller_email]!)") { (recent : Recent) in
            let storyboard = UIStoryboard(name: "Browse", bundle: nil)
            let chatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            
            chatViewController.recent = recent
            
            self.show(chatViewController, sender: self)
        }
    }
    
    @IBAction func btnSubmitClicked(_ sender: Any)
    {
        self.view.endEditing(true)
        if viewPrice.isHidden
        {
            showView(viewPrice)
        }
        else
        {
            let confirmAction = UIAlertController(title: "Warning!", message: "Make sure you meet in person with the seller and inspect the item before submitting an offer.  Please use chat feature to inquire about the item.", preferredStyle: .alert)
            let sendOffer = UIAlertAction(title: "Send Offer", style: .default, handler: { (alert) in
                self.sendRequest()
            })
            let okAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (alert) in
            })
            confirmAction.addAction(sendOffer)
            confirmAction.addAction(okAction)
            self.present(confirmAction, animated: true, completion: nil)
        }
    }
    
    func sendRequest() {
        if txtPrice.validate()
        {
            print("txtPrice.text---> \(String(describing: txtPrice.text))")
            print("isFrom---> \(String(describing: isFrom))")
            print("offDeatailsOb?.product_data?.price?.description---> \(String(describing: offDeatailsOb?.product_data?.price?.description))")
            
            if Float(txtPrice.text!)! > (isFrom!.isEqual("OfferDetailsPage") ? ((offDeatailsOb?.product_data?.price?.description)! as NSString).floatValue : Float("\(dictData[API_param.Product.price]!)")!)
            {
                let confirmAction = UIAlertController(title: "Warning!", message: "You offer is greater than what the seller is requesting, do you wish to continue?", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    self.makeOffer_ServiceCall()
                })
                let cancelAction = UIAlertAction(title: staus.Cancel, style: .cancel, handler: { (alert) in
                })
                confirmAction.addAction(okAction)
                confirmAction.addAction(cancelAction)
                
                self.present(confirmAction, animated: true, completion: nil)
            }else {
                makeOffer_ServiceCall()
            }
        }
    }
    
}

//MARK: - TextfieldDelegate Methods
extension ProductDetailVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    //MARK: - TextfieldDelegate Methods
    
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

extension ProductDetailVC {
    
    func makeOffer_ServiceCall() {
        
        let price: Float = Float(txtPrice.text!)!
        //        print(NSString(format: "%.2f", price))
        
        if isFrom == "OfferDetailsPage"
        {
            let params: Parameters = [API_param.UpdateOfferParams.Offer_Id: (manageOfferDataOb?.offer_id?.description)!,
                                      API_param.UpdateOfferParams.Offer_Price: NSString(format: "%.2f", price)]
            Utils.Show()
            
            Alamofire.request(URL(string: fromURL(uri: ApiName.updateOffer))!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    print(response.result.value as Any)   // result of response serialization
                    Utils.HideHud()
                    if let json = response.result.value as? Dictionary<String, Any>
                    {
                        if json[API_param.status] as? Int == 1
                        {
                            let confirmAction = UIAlertController(title: "Offer Updated!", message: "Your offer has been updated successfully.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                                self.dismiss(animated: true, completion: nil)
                                self.offerDtailClassOb?.getOfferDetails()
                            })
                            confirmAction.addAction(okAction)
                            self.present(confirmAction, animated: true, completion: nil)
                        }
                        else
                        {
                            Utils.showAlert("Error", message: "\(String(describing: json[API_param.message]!))", controller: self)
                        }
                    }
            }
        }
        else
        {
            let params: Parameters = [API_param.Product.product_id: dictData[API_param.Product.product_id]!,
                                      API_param.Product.price: NSString(format: "%.2f", price),
                                      API_param.Product.buyer_id: userDefault.value(forKey: API_param.Login.UserId)!,
                                      API_param.Product.seller_id: dictData[API_param.Product.seller_id]!,
                                      API_param.Product.master_offer_id:"0",
                                      API_param.Product.offer_type: "O",
                                      DefaultValues.user_type:"B"]
            Utils.Show()
            Alamofire.request(URL(string: fromURL(uri: ApiName.makeOffer))!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    print(response.result.value as Any)   // result of response serialization
                    Utils.HideHud()
                    if let json = response.result.value as? Dictionary<String, Any>
                    {
                        if json[API_param.status] as? Int == 1
                        {
                            let confirmAction = UIAlertController(title: "Offer Sent!", message: "Your offer has been sent.\nPlease visit your \nMy Account > Offer to view status.", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                                self.dismiss(animated: true, completion: nil)
                            })
                            confirmAction.addAction(okAction)
                            self.present(confirmAction, animated: true, completion: nil)
                        }
                        else
                        {
                            Utils.showAlert("Error", message: "\(String(describing: json[API_param.message]!))", controller: self)
                        }
                    }
            }
        }
        
    }
}
