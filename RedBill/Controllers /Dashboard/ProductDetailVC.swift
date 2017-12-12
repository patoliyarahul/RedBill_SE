//
//  ProductDetailVC.swift
//  RedBill
//
//  Created by Rahul on 10/18/17.
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
    
    var dictData = Dictionary<String, Any>()
    var imagePath:String = ""
    
    var alamofireSource = [AlamofireSource]()
    let localSource = [ImageSource(imageString: "no_image")!]
}

//MARK: - LifeCycle
extension ProductDetailVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewPrice.isHidden = true
        viewDescription.isHidden = false
        addValidationToTextFiled()
        //        print("daya---->\(dictData)")
        setText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showView(_ view: UIView) {
        if view == viewPrice {
            viewPrice.isHidden = false
            viewDescription.isHidden = true
            btnSubmite.setTitle("Send Offer", for: .normal)
        }
    }
}

//MARK: - Initialization Method
extension ProductDetailVC {
    
    func addValidationToTextFiled() {
        txtPrice.mendatoryMessage = MESSAGES.price_empty
        txtPrice.addRegEx(regEx: Regx.price, withMessage: MESSAGES.price_valid)
    }
    
    func setText() {
        if let arrImages = dictData[API_param.Product.images]! as? [String] {
            if arrImages.count >= 1 {
                for item in arrImages {
                    let url: String = "\(self.imagePath)\(item)"
                    alamofireSource.append(AlamofireSource(urlString: url)!)
                }
            }
        }
        
        lblTitle.text = "\(dictData[API_param.Product.title]!)"
        lblPrice.text = "$ \(dictData[API_param.Product.price]!)"
        txtDescription.text = "\(dictData[API_param.Product.description]!)"
        
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
}

//MARK: - UIButton Action Methods
extension ProductDetailVC {
    @IBAction func btnCloseClicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func btnContactSellerClicked(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func btnSubmitClicked(_ sender: Any) {
        self.view.endEditing(true)
        if viewPrice.isHidden {
            showView(viewPrice)
        }else {
            if txtPrice.validate() {
                
                if Float(txtPrice.text!)! > Float("\(dictData[API_param.Product.price]!)")! {
                    let confirmAction = UIAlertController(title: "Warning!", message: "Your offer is greater then seller has post, do you still want to continue?", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                        self.makeOffer_ServiceCall()
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
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
        
        let params: Parameters = [API_param.Product.product_id: dictData[API_param.Product.product_id]!,
                                  API_param.Product.price: NSString(format: "%.2f", price),
                                  API_param.Product.buyer_id: userDefault.value(forKey: API_param.Login.UserId)!]
        Utils.Show()
        
        Alamofire.request(URL(string: fromURL(uri: ApiName.makeOffer))!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                print(response.result.value as Any)   // result of response serialization
                Utils.HideHud()
                if let json = response.result.value as? Dictionary<String, Any> {
                    if json[API_param.status] as? Int == 1 {
                        
                        let confirmAction = UIAlertController(title: "Offer Sent!", message: "Your offer has been sent \nto the seller. Please visit your \nMy Account > Offer to view status.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                            self.dismiss(animated: true, completion: nil)
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
