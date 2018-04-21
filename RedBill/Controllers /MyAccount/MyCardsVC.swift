//
//  MyCardsVC.swift
//  RedBill
//
//  Created by Vipul Jikadra on 24/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper
//----------------------------
// MARK: - CardCell
//----------------------------
class CardCell: UITableViewCell
{
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var lblCardNumber: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    
    @IBOutlet weak var imgCheckWidthConstraint: NSLayoutConstraint!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        imgCheck.tintColor = Color.redColor
    }
}
//MARK: - Properties
class MyCardsVC: UIViewController
{
    @IBOutlet weak var btnClose: UIBarButtonItem!
    @IBOutlet weak var tblCards: UITableView!
    let service = Service()
    let refreshControl = { () -> UIRefreshControl in
        let refresher = UIRefreshControl()
        return refresher
    }()
    
    var savedCardOb:CardOb?
    var cardDetailsDataOb:CardDataOb?
    var isForm:String?
    var offerDtailClassOb:OfferDetailVC?
    var offerPrice: String = ""
    var offDeatailsOb:OfferDeatilsOb?
    var manageOfferDataOb:ManageOfferDataOb?
}
//MARK: - LifeCycle
extension MyCardsVC
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        service.delegate = self
        configureTableView(tblCards)
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tblCards.insertSubview(refreshControl, at: 0)
        getSavedCards()
        
        if isForm != "OfferDetailsPage"
        {
            self.navigationItem.setLeftBarButton(nil, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        navigationController?.navigationBar.ReSetCustomNavigationBar()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
//MARK: - UITableViewDelegate And Datasource Methods
extension MyCardsVC : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard savedCardOb?.data != nil else
        {
            return 0
        }
        return (savedCardOb?.data!.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! CardCell
        
        cell.tintColor = uiColorFromHex(rgbValue: 0x4A4A4A)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "detail"))
        
        let cardDetailsDataOb = savedCardOb?.data![indexPath.row]
        let number: String = (cardDetailsDataOb?.card_number?.description)!
        cell.lblCardNumber.text = "Ending in " + number.suffix(4)
        
        cell.imgCheckWidthConstraint.constant = cardDetailsDataOb?.is_default == "1" ? 23 : 0
        print(identifyCreditCard(cardNumber: number))
        cell.imgCard.image = UIImage.init(named: identifyCreditCard(cardNumber: number) + ".png")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        cardDetailsDataOb = savedCardOb?.data![indexPath.row]
        if isForm == "OfferDetailsPage"
        {
            self.performSegue(withIdentifier: SegueIdentifire.confirmPurchaseSegue, sender: self)
            return
        }
        self.performSegue(withIdentifier: SegueIdentifire.addPaymentCardSegue, sender: self)
    }
}
//MARK: Common Function
extension MyCardsVC
{
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == SegueIdentifire.addPaymentCardSegue
        {
            let dv = segue.destination as! AddPaymentCardVC
            dv.myCardOb = self
            dv.cardDetailsDataOb = self.cardDetailsDataOb
        }
        else if segue.identifier == SegueIdentifire.confirmPurchaseSegue
        {
            let dv = segue.destination as! ConfirmPurchaseVC
            dv.offDeatailsOb = self.offDeatailsOb
            dv.manageOfferDataOb = self.manageOfferDataOb
            dv.cardDetailsDataOb = self.cardDetailsDataOb
            dv.offerPrice = self.offerPrice
        }
    }
    func getSavedCards()
    {
        Utils.Show()
        let data: [String: Any] = [API_param.ManageOfferParams.User_Id: userDefault.value(forKey: API_param.Login.UserId)!]
        self.service.apiName = ApiName.getSavedCard
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.getSavedCard))!, parameters: data,encodingType:"json",headers:nil)
    }
    func refreshTableView()
    {
        self.getSavedCards()
    }
    @IBAction func btnSavedClicked(_ sender: Any)
    {
        cardDetailsDataOb = nil
    }
    @IBAction func btnClose_Click(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
//MARK: - Network Call Delegate 
extension MyCardsVC : ServiceDelegate
{
    internal func onFault(resultData:[String:Any]?,ServiceName:String)
    {
        Utils.HideHud()
        if resultData != nil
        {
           refreshControl.endRefreshing()
        }
    }
    
    func onResult(resultData:Any?,ServiceName:String) {
        Utils.HideHud()
        if ServiceName.isEqual(self.service.apiName){
            if let resultDict = resultData as? [String: Any]{
                if resultDict[API_param.status] as? Int == 1{
                    refreshControl.endRefreshing()
                    savedCardOb = Mapper<CardOb>().map(JSON: resultDict)!
                    reloadTableViewWithAnimation(myTableView: tblCards)
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
    }
}
