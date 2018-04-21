//
//  TransctionCompleteVC.swift
//  RedBill
//
//  Created by Vipul Jikadra on 24/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit

class TransctionCompleteVC: UIViewController {
    
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblTotalWithHeld: UILabel!
    @IBOutlet weak var txtAmount: DBTextField!
    @IBOutlet weak var lblTittle: UILabel!
    
    let service = Service()
    var donationOb: DonationDataOb?
    var donationWithProductOb: DonationWithProductData?
    
    var order_Id: String = ""
    var seller_order_price: String = ""
    
    var offerPrice: Double = 0.0
    var perValue: Double = 0.0
}

//MARK: - LifeCycle
extension TransctionCompleteVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        service.delegate = self
        addValidationToTextFiled()
        setData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - Initialization Method
extension TransctionCompleteVC {
    func setData() {
        
        if donationWithProductOb != nil  {
            offerPrice = ((donationWithProductOb?.data![0].order_price?.description)! as NSString).doubleValue
            order_Id = (donationWithProductOb?.data![0].order_id?.description)!
            seller_order_price = (donationWithProductOb?.data![0].seller_order_price?.description)!
            lblTittle.text = "Product: \((donationWithProductOb?.data![0].product_title?.description)!)"
        }else {
//            offerPrice = ((donationOb?.order_data?.order_price?.description)! as NSString).doubleValue
//            
//            if donationOb?.order_data?.order_id != nil{
//                order_Id = (donationOb?.order_data?.order_id?.description)!
//            }else{
//                //show order_Id
//            }
//            seller_order_price = (donationOb?.order_data?.seller_order_price?.description)!
//            lblTittle.text = ""
        }
        
        perValue = (offerPrice * Double(DefaultValues.percentage)!) / 100
        
        lblTotal.text = "You will receive a total of $ \(offerPrice)!"
        lblTotalWithHeld.text = "Redbill.co holds " + DefaultValues.percentage + "% of all transactions. \n Total withheld: $\(perValue)"
    }
    
    func addValidationToTextFiled() {
        txtAmount.mendatoryMessage = MESSAGES.price_empty
        txtAmount.addRegEx(regEx: Regx.price, withMessage: MESSAGES.price_valid)
    }
    
    func postDonation() {
        
        let donationPrice: Double = Double(txtAmount.text!)!
        
        Utils.Show()
        let data: [String: Any] = [API_param.OfferDetailsParams.Order_Id: self.order_Id,
                                   API_param.OfferDetailsParams.Order_price: offerPrice,
                                   API_param.OfferDetailsParams.Organization_id: "1",
                                   API_param.OfferDetailsParams.Seller_order_price: seller_order_price,
                                   API_param.OfferDetailsParams.DonationPrice : "\(donationPrice)"]
        
        print("data -> \(data)")
        self.service.apiName = ApiName.sellerOrganizationDonation
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.sellerOrganizationDonation))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    func moveToRoot() {
        let viewControllers: [UIViewController] = (self.navigationController?.viewControllers)!
        let vc = viewControllers[0] as! MyAccountVC
        vc.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UIButton Action Methods
extension TransctionCompleteVC {
    @IBAction func btnDonationClicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)//RK

        if txtAmount.validate() {
            let donationPrice: Double = Double(txtAmount.text!)!
            if donationPrice > (offerPrice - perValue) {
                helperOb.toast("You can not donate more that what you get!")
            }else {
                postDonation()
            }
        }
    }
}

//MARK: - Initialization Method
extension TransctionCompleteVC: ServiceDelegate {
    internal func onFault(resultData:[String:Any]?,ServiceName:String) {
        Utils.HideHud()
        if resultData != nil {
            helperOb.toast(resultData![API_param.message] as! String)
        }
    }
    
    func onResult(resultData:Any?,ServiceName:String) {
        Utils.HideHud()
        if ServiceName.isEqual(ApiName.sellerOrganizationDonation) {
            if let resultDict = resultData as? [String: Any] {
//                print("data --> \(resultDict)")
                if resultDict[API_param.status] as? Int == 1 {
                    
                    let alertWithBlock = UIAlertController(title: MESSAGES.app_name, message: MESSAGES.donation_succes, actions:.custom("Ok",.default),style:.alert){ action -> Void in
                        if action == "Ok" {
                            if self.donationWithProductOb != nil  {
                                self.dismiss(animated: true, completion: nil)
                            }else {
                                self.moveToRoot()
                            }
                        }
                    }
                    self.present(alertWithBlock, animated: true, completion: nil)
                    
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
    }
}


