//
//  ConfirmPurchaseVC.swift
//  RedBill
//
//  Created by Vipul Jikadra on 28/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit

class ConfirmPurchaseVC: UIViewController {
    
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblcard: UILabel!
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    
    var offDeatailsOb:OfferDeatilsOb?
    var manageOfferDataOb:ManageOfferDataOb?
    var cardDetailsDataOb:CardDataOb?
    var offerPrice: String = ""
    let service = Service()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("offerPrice  ----> \(offerPrice)")
        
        service.delegate = self
        let number: String = (cardDetailsDataOb?.card_number?.description)!
        lblcard.text =  "Ending in " + number.suffix(4)
        imgCard.image = UIImage.init(named: identifyCreditCard(cardNumber: (cardDetailsDataOb?.card_number)!) + ".png")
        lblProductName.text = self.offDeatailsOb?.product_data?.title?.description
        lblPrice.text = "$ " + offerPrice
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ConfirmPurchaseVC
{
    @IBAction func btnPurchase_Clicked(_ sender: Any)
    {
        self.acceptOffer()
    }
    
    func acceptOffer() {
        Utils.Show()
        let data: [String: Any] =
            [API_param.OfferDetailsParams.Seller_Id: (manageOfferDataOb?.seller_id?.description)!,
             API_param.OfferDetailsParams.Buyer_Id: (manageOfferDataOb?.buyer_id?.description)!,
             API_param.OfferDetailsParams.ProductId: (manageOfferDataOb?.product_id?.description)!,
             API_param.OfferDetailsParams.Master_offer_id: (manageOfferDataOb?.master_offer_id?.description)!,
             API_param.OfferDetailsParams.Offer_Price: self.offerPrice]
        
        self.service.apiName = ApiName.acceptOffer
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.acceptOffer))!, parameters: data,encodingType:"json",headers:nil)
    }
}

//MARK: - Network Call Delegate 
extension ConfirmPurchaseVC : ServiceDelegate {
    internal func onFault(resultData:[String:Any]?,ServiceName:String) {
        Utils.HideHud()
        if resultData != nil {
            helperOb.toast(resultData![API_param.message] as! String)
        }
    }
    
    func onResult(resultData:Any?,ServiceName:String) {
        Utils.HideHud()
        if ServiceName.isEqual(ApiName.acceptOffer){
            if let resultDict = resultData as? [String: Any] {
                print("data --> \(resultDict)")
                
                if resultDict[API_param.status] as? Int == 1 {
                    let alertWithBlock = UIAlertController(title: "Purchase Successful", message: "We will be in contact with you to arrange the product delivery.  Thank you for using RedBill!", actions:.custom("Ok",.default),style:.alert){ action -> Void in
                        if action == "Ok" {
                            self.navigationController?.popViewController(animated: true)
                            self.navigationController?.dismiss(animated: true, completion: {
                                let vc = UIApplication.topViewController() as! OfferDetailVC
                                vc.moveToRoot()
                            })
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
