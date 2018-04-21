//
//  ManageOfferVC.swift
//  RedBill
//
//  Created by Rahul on 11/9/17.
//  Copyright © 2017 Rahul. All rights reserved.
//
import UIKit
import ObjectMapper
//MARK: - Properties
class ManageOfferVC: UIViewController
{
    @IBOutlet weak var tblView: UITableView!
    var arrData = [Dictionary<String, Any>]()
    let service = Service()
    var manageOfferOb:ManageOfferOb?
    
    let refreshControl = { () -> UIRefreshControl in
        let refresher = UIRefreshControl()
        return refresher
    }()
    var manageOfferDataOb:ManageOfferDataOb?
    var productDetailsOb:OfferProductDetailsOb?
    
    var isComeAs:String?
}

//MARK: - LifeCycle
extension ManageOfferVC
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        service.delegate = self
        configureTableView(tblView)
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tblView.insertSubview(refreshControl, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        getOffer()
        navigationController?.navigationBar.ReSetCustomNavigationBar()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Navigation
extension ManageOfferVC
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == SegueIdentifire.offerDetailSegue
        {
            let dv = segue.destination as! OfferDetailVC
            dv.manageOfferDataOb = self.manageOfferDataOb
            dv.isComeAs = self.isComeAs
        }
    }
}
//MARK: - UITableViewDelegate And Datasource Methods
extension ManageOfferVC : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard manageOfferOb?.data?.isEmpty == false else
        {
            return 1
        }
        return (manageOfferOb?.data?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyAccountCell
        
        cell.tintColor = uiColorFromHex(rgbValue: 0x4A4A4A)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "detail"))
        
        guard manageOfferOb == nil else
        {
            if (manageOfferOb?.data?.isEmpty)!
            {
                cell.lblTittle.text = "No Offer Available"
                cell.lblDscription.text = ""
                cell.imgView.image = UIImage.init(named: "")
                cell.lblStatus.isHidden = true
                return cell
            }
            let manageOfferDataOb = manageOfferOb?.data![indexPath.row]
            cell.lblTittle.text = manageOfferDataOb?.product_title
            
            if (manageOfferDataOb?.message?.contains("Offer Sent"))!{
                cell.lblDscription.textColor = uiColorFromHex(rgbValue: 0xF57223)
                cell.imgView.image = #imageLiteral(resourceName: "up_arrow")
                cell.lblStatus.textColor = uiColorFromHex(rgbValue: 0xF57223)
                
            }else if (manageOfferDataOb?.message?.contains("Cancled"))!{
                cell.lblDscription.textColor = uiColorFromHex(rgbValue: 0x4A4A4A)
                cell.imgView.isHidden = true
            }else if (manageOfferDataOb?.message?.contains("Offer Received"))!{
                cell.lblDscription.textColor = uiColorFromHex(rgbValue: 0x00B4B2)
                cell.imgView.image = #imageLiteral(resourceName: "down_arrow")
                cell.lblStatus.textColor = uiColorFromHex(rgbValue: 0x00B4B2)
            }
            
            cell.lblStatus.text = manageOfferDataOb?.offer_status
            
            if manageOfferDataOb?.offer_status == staus.Cancled || manageOfferDataOb?.offer_status == staus.Denny {
                cell.lblStatus.textColor = uiColorFromHex(rgbValue: 0x9B9B9B)
                cell.lblDscription.textColor = uiColorFromHex(rgbValue: 0x4A4A4A)
                cell.imgView.isHidden = true
                
            }else if manageOfferDataOb?.offer_status == staus.Accepted {
                cell.lblStatus.textColor = uiColorFromHex(rgbValue: 0xF57223)
                cell.lblDscription.textColor = uiColorFromHex(rgbValue: 0xF57223)
                cell.imgView.isHidden = true
            }
            
            cell.lblDscription.text = manageOfferDataOb?.message?.replacingOccurrences(of: "\r\n", with: "")
            return cell
        }
        cell.lblTittle.text = "No Offer Available"
        cell.lblDscription.text = ""
        cell.imgView.image = UIImage.init(named: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard manageOfferOb?.data?.count != 0 else
        {
            return
        }
        manageOfferDataOb = manageOfferOb?.data![indexPath.row]
        self.performSegue(withIdentifier: SegueIdentifire.offerDetailSegue, sender: self)
    }
}
//MARK: Network Call Method
extension ManageOfferVC
{
    func getOffer()
    {
        Utils.Show()
        let data: [String: Any] = [API_param.ManageOfferParams.User_Id: userDefault.value(forKey: API_param.Login.UserId)!,
                                   API_param.ManageOfferParams.Product_Id: (productDetailsOb?.productid?.description)!]
        self.service.apiName = ApiName.manageOffer
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.manageOffer))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    func updateView(manageOfferOb: ManageOfferOb) {
//        Utils.Show()

        for manageOfferDataOb in manageOfferOb.data! {
            let data: [String: Any] = [API_param.updateProductView.Buyer_Id: (manageOfferDataOb.buyer_id?.description)!,
                                       API_param.updateProductView.Seller_Id: (manageOfferDataOb.seller_id?.description)!,
                                       API_param.updateProductView.Product_Id: (manageOfferDataOb.product_id?.description)!]
            self.service.apiName = ApiName.updateProductView
            self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.updateProductView))!, parameters: data,encodingType:"json",headers:nil)
        }
    }
    
    func refreshTableView()
    {
        self.getOffer()
    }
}
//MARK: - Network Call Delegate 
extension ManageOfferVC : ServiceDelegate
{
    internal func onFault(resultData:[String:Any]?,ServiceName:String)
    {
        Utils.HideHud()
        if resultData != nil
        {
            refreshControl.endRefreshing()
            var loginObject : ManageOfferObError
            loginObject = Mapper<ManageOfferObError>().map(JSON: resultData!)!
            helperOb.toast(loginObject.message!)
        }
    }
    
    func onResult(resultData:Any?,ServiceName:String)
    {
        Utils.HideHud()
        if ServiceName.isEqual(ApiName.manageOffer) {
            if let resultDict = resultData as? [String: Any] {
                if resultDict[API_param.status] as? Int == 1{
                    refreshControl.endRefreshing()
                    manageOfferOb = Mapper<ManageOfferOb>().map(JSON: resultDict)!
                    tblView.reloadData()
                    tblView.isHidden = false
                    updateView(manageOfferOb: manageOfferOb!)
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }else if ServiceName.isEqual(ApiName.updateProductView) {
            if let resultDict = resultData as? [String: Any] {
                if resultDict[API_param.status] as? Int == 1{
                    print("updated")
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
    }
}
