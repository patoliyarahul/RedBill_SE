//
//  OfferDetailVC.swift
//  RedBill
//
//  Created by Vipul Jikadra on 22/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import ImageSlideshow
import ObjectMapper
//----------------------------
// MARK: - Expand UITableViewCell
//----------------------------

class OfferCell: UITableViewCell {
    @IBOutlet weak var lblOfferDateTime: UILabel!
    @IBOutlet weak var lblOfferTitle: UILabel!
    @IBOutlet var btnCounterOffer: UIButton!
    @IBOutlet var btnACcept: UIButton!
    @IBOutlet var btnCounterOfferHeightConstarint: NSLayoutConstraint!
    @IBOutlet var detailViewHeightConstraint: NSLayoutConstraint!
    var showDetails:Bool = false;
    @IBOutlet var imgArrow: UIImageView!
    @IBOutlet weak var btnCancelOffer: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnCancelOffer.isHidden = true
        showDetails = false;
        btnCounterOffer.layer.borderColor = Color.buttonBorderColor.cgColor
        btnCancelOffer.layer.borderColor = Color.buttonBorderColor.cgColor
        detailViewHeightConstraint.constant = 0;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setshowDetails(_ showDetails: Bool) {
        self.showDetails = showDetails
        if showDetails {
            self.detailViewHeightConstraint.priority = 250
            self.imgArrow.image = #imageLiteral(resourceName: "up")
        } else {
            self.detailViewHeightConstraint.priority = 999
            self.imgArrow.image = #imageLiteral(resourceName: "Arrow-down - simple-line-icons")
        }
    }
}

// MARK: - Properties
class OfferDetailVC: UIViewController {
    @IBOutlet weak var slideShow: ImageSlideshow!
    @IBOutlet var tblHeightConstraint: NSLayoutConstraint! // 220
    @IBOutlet weak var tblOffer: UITableView!
    @IBOutlet var backScroll: UIScrollView!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductPrice: UILabel!
    @IBOutlet weak var lblOfferStatus: UILabel!
    @IBOutlet weak var lblPersonName: UILabel!
    @IBOutlet weak var viewCounterOffer: UIView!
    @IBOutlet weak var tfCounterAmount: DBTextField!
    @IBOutlet weak var lblHistory: UILabel!
    @IBOutlet weak var lblLine: UILabel!
    @IBOutlet weak var btnCloseCounter: UIButton!
    
    
    var expandedIndexPaths:NSMutableSet?
    var alamofireSource = [AlamofireSource]()
    let localSource = [ImageSource(imageString: "no_image")!]
    
    var manageOfferDataOb:ManageOfferDataOb?
    let service = Service()
    var offDeatailsOb: OfferDeatilsOb?
    var imagePath:String = ""
    var isComeAs:String?
    var offerPrice:String?
    
    var acceptedOfferDataOb: OfferDataOb?
    var order_Id: String?
    var donationOb: DonationDataOb?
}


// MARK: - ViewLife Cycle Method
extension OfferDetailVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        btnCloseCounter.tintColor = Color.buttonBorderColor
        self.addValidationToTextFiled()
        expandedIndexPaths = NSMutableSet.init()
        service.delegate = self
        configureTableView(tblOffer)
        self.getOfferDetails()
        tfCounterAmount.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.SetCustomNavigationBar()
        self.tblOffer.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tblOffer.removeObserver(self, forKeyPath: "contentSize")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize") {
            if (change?[.newKey]) != nil {
                if self.tblOffer.contentSize.height == 109 {
                    tblHeightConstraint.constant = 0
                } else {
                    tblHeightConstraint.constant = self.tblOffer.contentSize.height
                }
            }
        }
    }
}
//MARK: UITableView Delegate & Datasource

extension OfferDetailVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isComeAs == User.Buyer {
            guard offDeatailsOb?.buyer_data![0].offer_data != nil else {
                return 0
            }
            return (offDeatailsOb?.buyer_data![0].offer_data?.count)!
        } else {
            guard offDeatailsOb?.seller_data![0].offer_data != nil else {
                return 0
            }
            return (offDeatailsOb?.seller_data![0].offer_data?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfferCell") as! OfferCell
        cell.selectionStyle = .none
        cell.setshowDetails((expandedIndexPaths?.contains(indexPath))!)
        
        switch isComeAs! {
        case User.Buyer:
            let offerDetailsOb = offDeatailsOb?.buyer_data![0].offer_data![indexPath.row]
            
            cell.lblOfferDateTime.attributedText = addAttributes(text:(offerDetailsOb?.date)! + "\n" + (offerDetailsOb?.time)!, range: NSMakeRange(0, (offerDetailsOb?.date?.count)!), fontName: fontName.boldFontName, color: Color.textColor, fSize: 14)
            
            cell.lblOfferTitle.text = (offerDetailsOb?.text)!
            
            if offerDetailsOb?.activity == staus.Cancel || offDeatailsOb?.buyer_data![0].buyer_accept == true || offDeatailsOb?.buyer_data![0].buyer_cancel == true {
                
                if (offerDetailsOb?.status == staus.Cancled) {
                    cell.lblOfferTitle.text = Offer_Message.Offer_Canceled
                    cell.lblOfferTitle.textColor = Color.buttonBorderColor
                    
                }else if offerDetailsOb?.status == staus.Accepted {
                    cell.lblOfferTitle.text = "Offer of" + " $" + (offerDetailsOb?.offer_price)! + " " + (Offer_Message.Offer_Accepeted)
                    cell.lblOfferTitle.textColor = Color.textColor
                }
                cell.btnCounterOffer.isHidden = true
                cell.btnACcept.isHidden = true
                cell.btnCancelOffer.isHidden = true
                
            }else if offerDetailsOb?.activity == staus.Denny {
                cell.lblOfferTitle.text = Offer_Message.Offer_Decline
                cell.lblOfferTitle.textColor = Color.buttonBorderColor
                
                cell.btnCounterOffer.isHidden = true
                cell.btnACcept.isHidden = true
                cell.btnCancelOffer.isHidden = true
                
            }else if offerDetailsOb?.activity == "Cancel/Edit" {
                cell.btnCounterOffer.setTitle(staus.Cancel, for: .normal)
                cell.btnACcept.setTitle(staus.Edit, for: .normal)
                
            }else if offerDetailsOb?.activity == "Accept/Denny" {
                cell.btnCounterOffer.setTitle(staus.Accept, for: .normal)
                cell.btnACcept.setTitle(staus.Denny, for: .normal)
            }
            
            cell.btnCancelOffer.addActionblock({_ in
                let alertWithBlock = UIAlertController(title: MESSAGES.app_name, message: MESSAGES.cancel_offer, actions:.custom("Yes",.destructive),.custom("No",.default),style:.alert){ action -> Void in
                    if action == "Yes"
                    {
                        self.cancelOffer()
                    }
                }
                self.present(alertWithBlock, animated: true, completion: nil)
            }, for: .touchUpInside)
            
            cell.btnCounterOffer.addActionblock({_ in
                
                if cell.btnCounterOffer.titleLabel?.text == staus.Cancel {
                    let alertWithBlock = UIAlertController(title: MESSAGES.app_name, message: MESSAGES.cancel_offer, actions:.custom("Yes",.destructive),.custom("No",.default),style:.alert){ action -> Void in
                        if action == "Yes" {
                            self.cancelOffer()
                        }
                    }
                    self.present(alertWithBlock, animated: true, completion: nil)
                    return
                }
                else if  cell.btnCounterOffer.titleLabel?.text == staus.Accept {
                    // go to payment page for purchase offer
                    self.performSegue(withIdentifier: SegueIdentifire.offerDetailsPaymentSegue, sender: (offerDetailsOb?.offer_price!)!)
                }
            }, for: .touchUpInside)
            
            cell.btnACcept.addActionblock({_ in
                
                if cell.btnACcept.titleLabel?.text == staus.Denny {
                    self.denyOffer((offerDetailsOb?.offer_price!)!)
                } else {
                    self.performSegue(withIdentifier: SegueIdentifire.offerDetailsOfferEditSegue, sender: self.offDeatailsOb)
                }
            }, for: .touchUpInside)
            
            cell.setNeedsLayout()
            return cell
        case User.Seller:
            let offerDetailsOb = offDeatailsOb?.seller_data![0].offer_data![indexPath.row]
            
            cell.lblOfferDateTime.attributedText = addAttributes(text:(offerDetailsOb?.date)! + "\n" + (offerDetailsOb?.time)!, range: NSMakeRange(0, (offerDetailsOb?.date?.count)!), fontName: fontName.boldFontName, color: Color.textColor, fSize: 14)
            
//            cell.lblOfferTitle.text = "Offer of" + " $" + (offerDetailsOb?.offer_price)! + " " + (offerDetailsOb?.sent_receive)!
            cell.lblOfferTitle.text = (offerDetailsOb?.text)!

            if offerDetailsOb?.activity == staus.Cancel || offDeatailsOb?.seller_data![0].seller_accept == true || offDeatailsOb?.seller_data![0].seller_cancel == true {
                
                if (offerDetailsOb?.status == staus.Cancled) {
                    cell.lblOfferTitle.text = Offer_Message.Offer_Canceled
                    cell.lblOfferTitle.textColor = Color.buttonBorderColor
                }else if offerDetailsOb?.status == staus.Accepted {
                    cell.lblOfferTitle.text = "Offer of" + " $" + (offerDetailsOb?.offer_price)! + " " + (Offer_Message.Offer_Accepeted)
                    cell.lblOfferTitle.textColor = Color.textColor
                }
                cell.lblOfferTitle.textColor = offDeatailsOb?.seller_data![0].seller_cancel == true ? Color.buttonBorderColor : Color.textColor
                
                cell.btnCounterOffer.isHidden = true
                cell.btnACcept.isHidden = true
                cell.btnCancelOffer.isHidden = false
                
            }else if offerDetailsOb?.activity == staus.Denny {
                cell.lblOfferTitle.text = Offer_Message.Offer_Decline
                cell.lblOfferTitle.textColor = Color.buttonBorderColor
                
                cell.btnCounterOffer.isHidden = true
                cell.btnACcept.isHidden = true
                cell.btnCancelOffer.isHidden = false
                
            } else if offerDetailsOb?.activity == "Counter/Accept" {
                cell.btnCounterOffer.setTitle(staus.Counter, for: .normal)
                cell.btnACcept.setTitle(staus.Accept, for: .normal)
                
            } else if offerDetailsOb?.activity == "Sent" {
                cell.btnCounterOffer.isHidden = true
                cell.btnACcept.isHidden = true
                cell.btnCancelOffer.isHidden = false
            }
            
            cell.btnCancelOffer.addActionblock({_ in
                let alertWithBlock = UIAlertController(title: MESSAGES.app_name, message:MESSAGES.cancel_offer, actions:.custom("Yes",.destructive),.custom("No",.default),style:.alert){ action -> Void in
                    if action == "Yes" {
                        self.cancelOffer()
                    }
                }
                self.present(alertWithBlock, animated: true, completion: nil)
            }, for: .touchUpInside)
            
            cell.btnACcept.addActionblock({_ in
                let alertWithBlock = UIAlertController(title: MESSAGES.app_name, message: MESSAGES.accept_offer, actions:.custom("Yes",.destructive),.custom("No",.default),style:.alert){ action -> Void in
                    if action == "Yes" {
                        self.offerPrice = offerDetailsOb?.offer_price?.description
                        self.acceptedOfferDataOb = offerDetailsOb
                        self.acceptOffer()
                    }
                }
                self.present(alertWithBlock, animated: true, completion: nil)
            }, for: .touchUpInside)
            
            cell.btnCounterOffer.addActionblock({_ in
                if cell.btnCounterOffer.titleLabel?.text == staus.Counter {
                    UIView.animate(withDuration: 0.8, animations: {
                        self.viewCounterOffer.isHidden = false
                        self.tblOffer.isHidden = true
                        self.lblOfferStatus.isHidden = true
                        self.lblHistory.isHidden = true
                        self.lblPersonName.isHidden = true
                        self.lblLine.isHidden = true
                        self.view.layoutIfNeeded()
                    })
                }
            }, for: .touchUpInside)
            
            cell.setNeedsLayout()
            return cell
        default:
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch isComeAs! {
        case User.Buyer:
            if (offDeatailsOb?.seller_data![0].offer_data?.count)! > 1 && indexPath.row < 1{
                helperOb.toast(MESSAGES.not_edit_offer)
                return
            }
            
            if offDeatailsOb?.buyer_data![0].buyer_accept == true || offDeatailsOb?.buyer_data![0].buyer_cancel == true || offDeatailsOb?.buyer_data![0].buyer_denny == true {
                return
            }
        case User.Seller:
            let offerDetailsOb = offDeatailsOb?.seller_data![0].offer_data![indexPath.row]
            
            if offerDetailsOb?.status == staus.Cancled {
                helperOb.toast(MESSAGES.not_edit_offer)
                return
            }
            
            if  offDeatailsOb?.seller_data![0].seller_accept == true || offDeatailsOb?.seller_data![0].seller_cancel == true || offDeatailsOb?.seller_data![0].seller_denny == true {
                return
            }
            if (offDeatailsOb?.seller_data![0].offer_data?.count)! > 1 && indexPath.row < 1{
                helperOb.toast("You cann't edit older offer!")
                return
            }
            
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: false)
        if (self.expandedIndexPaths?.contains(indexPath))! {
            print(tableView.rectForRow(at: indexPath).size.height)
            self.expandedIndexPaths?.remove(indexPath)
            tableView.reloadRows(at: [indexPath], with: .none)
        } else {
            self.expandedIndexPaths?.add(indexPath)
            UIView.animate(withDuration: 0.4)
            {
                tableView.reloadRows(at: [indexPath], with: .fade)
                self.backScroll.contentOffset = CGPoint(x: 0, y: tableView.rectForRow(at: indexPath).origin.y)
                self.view.layoutIfNeeded()
            }
        }
    }
}
//MARK: Common Function
extension OfferDetailVC {
    func myTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
    func setSlidView() {
        self.slideShow.backgroundColor = UIColor.black
        self.slideShow.slideshowInterval = 10.0
        self.slideShow.pageControlPosition = PageControlPosition.insideScrollView
        self.slideShow.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        self.slideShow.pageControl.pageIndicatorTintColor = UIColor.black
        self.slideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        self.slideShow.activityIndicator = DefaultActivityIndicator()
        self.slideShow.currentPageChanged = { page in
        }
        
        self.slideShow.setImageInputs(alamofireSource.count > 0 ? alamofireSource : localSource)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        self.slideShow.addGestureRecognizer(recognizer)
    }
    
    @objc func didTap() {
        let fullScreenController = self.slideShow.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    func getOfferDetails() {
        Utils.Show()
        let data: [String: Any] = [API_param.OfferDetailsParams.Seller_Id: (manageOfferDataOb?.seller_id?.description)!,API_param.OfferDetailsParams.Buyer_Id: (manageOfferDataOb?.buyer_id?.description)!,
                                   API_param.OfferDetailsParams.Master_offer_id: (manageOfferDataOb?.master_offer_id?.description)!,
                                   API_param.OfferDetailsParams.Product_Id: (manageOfferDataOb?.product_id?.description)!]
        print("data -> \(data)")
        self.service.apiName = ApiName.OfferDetails
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.OfferDetails))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    func cancelOffer() {
        Utils.Show()
        let data: [String: Any] = [API_param.OfferDetailsParams.Seller_Id: (manageOfferDataOb?.seller_id?.description)!,
                                   API_param.OfferDetailsParams.Buyer_Id: (manageOfferDataOb?.buyer_id?.description)!,
                                   API_param.OfferDetailsParams.Master_offer_id: (manageOfferDataOb?.master_offer_id?.description)!,
                                   API_param.OfferDetailsParams.ProductId:(manageOfferDataOb?.product_id?.description)!]
        self.service.apiName = ApiName.cancelOffer
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.cancelOffer))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    func acceptOffer() {
        Utils.Show()
        let data: [String: Any] =
            [API_param.OfferDetailsParams.Seller_Id: (manageOfferDataOb?.seller_id?.description)!,
             API_param.OfferDetailsParams.Buyer_Id: (manageOfferDataOb?.buyer_id?.description)!,
             API_param.OfferDetailsParams.ProductId: (manageOfferDataOb?.product_id?.description)!,
             API_param.OfferDetailsParams.Master_offer_id: (manageOfferDataOb?.master_offer_id?.description)!,
             API_param.OfferDetailsParams.Offer_Price: (self.offerPrice)!]
        self.service.apiName = ApiName.acceptOffer
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.acceptOffer))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    func denyOffer(_ price: String) {
        Utils.Show()
        let data: [String: Any] = [API_param.OfferDetailsParams.Seller_Id: (manageOfferDataOb?.seller_id?.description)!,API_param.OfferDetailsParams.Buyer_Id: (manageOfferDataOb?.buyer_id?.description)!,
                                   API_param.OfferDetailsParams.Master_offer_id: (manageOfferDataOb?.master_offer_id?.description)!,
                                   API_param.OfferDetailsParams.Product_Id: (manageOfferDataOb?.product_id?.description)!,API_param.OfferDetailsParams.Offer_Price : price]
        self.service.apiName = ApiName.denyOffer
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.denyOffer))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    func setOfferDetails() {
        self.lblOfferStatus.attributedText = addAttributes(text: "Status " + whichOfferStatus(status: offerStatus(rawValue: (offDeatailsOb?.product_data?.status)!)!), range: NSMakeRange(0,7), fontName: fontName.boldFontName, color: Color.textColor, fSize: 14)
        self.lblProductName.text = offDeatailsOb?.product_data?.title
        self.lblProductPrice.text = "$" + (offDeatailsOb?.product_data?.price)!
        
        let buyerName = (self.offDeatailsOb?.buyer_data?[0].first_name)! + " " + (self.offDeatailsOb?.buyer_data?[0].last_name)!
        
        let sellerName = (self.offDeatailsOb?.seller_data?[0].first_name)! + " " + (self.offDeatailsOb?.seller_data?[0].last_name)!
        
        print("Buyer name -> \(buyerName)")
        print("sellerName -> \(sellerName)")
        
        self.lblPersonName.text = isComeAs == User.Buyer ? "with " + "\(sellerName)" : "with " + "\(buyerName)"
        //        self.lblPersonName.text = isComeAs == "Buyer" ? "with " + (self.offDeatailsOb?.buyer_data?[0].first_name)! + " " + (self.offDeatailsOb?.buyer_data?[0].last_name)! : "with " + (self.offDeatailsOb?.seller_data?[0].first_name)! + " " + (self.offDeatailsOb?.seller_data?[0].last_name)!
        if let arrImages = offDeatailsOb?.product_data?.images as? [String] {
            if arrImages.count >= 1 {
                for item in arrImages {
                    let url: String = "\(Constant.baseImagePath)\(item)"
                    alamofireSource.append(AlamofireSource(urlString: url)!)
                }
            }
        }
        setSlidView()
    }
    
    func addValidationToTextFiled() {
        tfCounterAmount.mendatoryMessage = MESSAGES.price_empty
        tfCounterAmount.addRegEx(regEx: Regx.price, withMessage: MESSAGES.price_valid)
    }
    @IBAction func btnCloseCounterClicked(_ sender: Any) {
        self.viewCounterOffer.isHidden = true
        self.tblOffer.isHidden = false
        self.lblOfferStatus.isHidden = false
        self.lblHistory.isHidden = false
        self.lblPersonName.isHidden = false
        self.lblLine.isHidden = false
        self.view.layoutIfNeeded()
    }
    
    @IBAction func btnSendOffer_Click(_ sender: Any) {
        self.view.endEditing(true)
        if tfCounterAmount.validate() {
            makeOffer_ServiceCall()
        }
    }
    
    func makeOffer_ServiceCall() {
        
        let price: Float = Float(tfCounterAmount.text!)!
        //        print(NSString(format: "%.2f", price))
        
        let data: [String: Any] = [API_param.Product.product_id: (offDeatailsOb?.product_data?.productid?.description)!,
                                   API_param.Product.price: NSString(format: "%.2f", price),
                                   API_param.Product.buyer_id: (manageOfferDataOb?.buyer_id?.description)!,
                                   API_param.Product.seller_id: (manageOfferDataOb?.seller_id?.description)!,
                                   API_param.Product.master_offer_id: (manageOfferDataOb?.master_offer_id?.description)!,
                                   API_param.Product.offer_type: "CO",
                                   DefaultValues.user_type:"S"]
        Utils.Show()
        self.service.apiName = ApiName.makeOffer
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.makeOffer))!, parameters: data,encodingType:"json",headers:nil)
        
    }
}

// MARK: - Navigation
extension OfferDetailVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifire.offerDetailsOfferEditSegue {
            let dvc = segue.destination as! ProductDetailVC
            dvc.offDeatailsOb = sender as? OfferDeatilsOb
            dvc.manageOfferDataOb = self.manageOfferDataOb
            dvc.isFrom = "OfferDetailsPage"
            dvc.offerDtailClassOb = self
            
        } else if segue.identifier == SegueIdentifire.offerDetailsPaymentSegue {
            let nav = segue.destination as! UINavigationController
            let viewController2 = myAccountStoryboard.instantiateViewController(withIdentifier: "MyCardsVC")
            nav.viewControllers.insert(viewController2, at: 0)
            let dv = nav.topViewController as! MyCardsVC
            dv.isForm = "OfferDetailsPage"
            dv.offerDtailClassOb = self
            dv.offDeatailsOb = self.offDeatailsOb
            dv.manageOfferDataOb = self.manageOfferDataOb
            dv.offerPrice = (sender as? String)!
        }
    }
    
    func moveToRoot() {
        let viewControllers: [UIViewController] = (self.navigationController?.viewControllers)!
        let vc = viewControllers[0] as! MyAccountVC
        vc.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Network Call Delegate 
extension OfferDetailVC : ServiceDelegate {
    internal func onFault(resultData:[String:Any]?,ServiceName:String) {
        Utils.HideHud()
        if resultData != nil {
            helperOb.toast(resultData![API_param.message] as! String)
        }
    }
    
    func onResult(resultData:Any?,ServiceName:String) {
        Utils.HideHud()
        if ServiceName.isEqual(ApiName.OfferDetails) {
            if let resultDict = resultData as? [String: Any] {
                if resultDict[API_param.status] as? Int == 1{
                    
                    offDeatailsOb = Mapper<OfferDeatilsOb>().map(JSON: resultDict)!
                    expandedIndexPaths = NSMutableSet.init()
                    tblOffer.reloadData()
                    setOfferDetails()
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        } else if ServiceName.isEqual(ApiName.cancelOffer) {
            if let resultDict = resultData as? [String: Any] {
                if resultDict[API_param.status] as? Int == 1 {
                    
                    helperOb.toast(resultDict[API_param.message] as! String)
                    expandedIndexPaths = NSMutableSet.init()
                    self.getOfferDetails()
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        } else if ServiceName.isEqual(ApiName.makeOffer) {
            if (resultData as? [String: Any]) != nil {
                if let resultDict = resultData as? [String: Any] {
                    if resultDict[API_param.status] as? Int == 1 {
                        helperOb.toast(resultDict[API_param.message] as! String)
                        //                        self.navigationController?.popViewController(animated: true)
                        let alertWithBlock = UIAlertController(title: "Counter Offer Sent", message: "The seller will \nbe notified of your offer.", actions:.custom("Ok",.default),style:.alert){ action -> Void in
                            if action == "Ok" {
                                UIView.animate(withDuration: 0.8, animations: {
                                    self.viewCounterOffer.isHidden = true
                                    self.tblOffer.isHidden = false
                                    self.lblOfferStatus.isHidden = false
                                    self.lblHistory.isHidden = false
                                    self.lblPersonName.isHidden = false
                                    self.lblLine.isHidden = false
                                    self.tfCounterAmount.text = ""
                                    self.view.layoutIfNeeded()
                                    self.getOfferDetails()
                                })
                            }
                        }
                        self.present(alertWithBlock, animated: true, completion: nil)
                    }else {
                        helperOb.toast(resultDict[API_param.message] as! String)
                    }
                }
            }
        } else if ServiceName.isEqual(ApiName.acceptOffer){
            if let resultDict = resultData as? [String: Any] {
                //                print("data --> \(resultDict)")
                
                if resultDict[API_param.status] as? Int == 1 {
                    helperOb.toast(resultDict[API_param.message] as! String)
                    moveToRoot()
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        } else if ServiceName.isEqual(ApiName.denyOffer) {
            if let resultDict = resultData as? [String: Any] {
                if resultDict[API_param.status] as? Int == 1 {
                    helperOb.toast(resultDict[API_param.message] as! String)
                    moveToRoot()
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
    }
}
