//
//  OfferHistoryVC.swift
//  RedBill
//
//  Created by Rahul on 1/20/18.
//  Copyright © 2018 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper

class OfferHistoryVC: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    let service = Service()
    var ProductOb: ProductHistoryDataOb?

    let refreshControl = { () -> UIRefreshControl in
        let refresher = UIRefreshControl()
        return refresher
    }()
}

//MARK: - LifeCycle 
extension OfferHistoryVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        service.delegate = self
        configureTableView(tblView)
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tblView.insertSubview(refreshControl, at: 0)
        getProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.ReSetCustomNavigationBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Navigation 
extension OfferHistoryVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}

//MARK: - UITableViewDelegate And Datasource Methods 
extension OfferHistoryVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section
        {
        case 0:
            guard ProductOb?.sell_product?.isEmpty == false else {
                return 1
            }
            return (ProductOb?.sell_product?.count)!
            
        case 1:
            guard ProductOb?.buy_product?.isEmpty == false else {
                return 1
            }
            return (ProductOb?.buy_product?.count)!
            
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    //    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
    //    {
    //        return 54
    //    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Sold Product"
        case 1:
            return "Bought Product"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyAccountCell
        
        cell.tintColor = uiColorFromHex(rgbValue: 0x4A4A4A)
        cell.selectionStyle = .none
//        cell.accessoryType = .disclosureIndicator
//        cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "detail"))
        
        switch indexPath.section {
        case 0:
            
            if (ProductOb != nil && (ProductOb?.sell_product?.count)! > 0) {
                let sellProductOb = ProductOb?.sell_product![indexPath.row]
                cell.lblTittle.text = sellProductOb?.title?.description.replacingOccurrences(of: "<[^>]+>\r\n", with: "", options:.regularExpression, range: nil)
                
                cell.lblPrice.text = "Selling Price: \((sellProductOb?.order_price?.description)!)"
                cell.lblDonation.text = "Donate: \((sellProductOb?.organiz_donation?.description)!)"
                
                return cell

            }
            cell.lblTittle.text = MESSAGES.NO_PRODUCT
            return cell
        case 1:
            if (ProductOb != nil && (ProductOb?.buy_product?.count)! > 0) {
                let buyProductOb = ProductOb?.buy_product![indexPath.row]
                cell.lblTittle.text = buyProductOb?.title?.description.replacingOccurrences(of: "<[^>]+>\r\n", with: "", options:.regularExpression, range: nil)
                cell.lblPrice.text = "Buying Price: \((buyProductOb?.order_price?.description)!)"
                cell.lblDonation.text = "Donate: \((buyProductOb?.organiz_donation?.description)!)"
                return cell
            }
            cell.lblTittle.text = MESSAGES.NO_PRODUCT
            return cell
        default:
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
//MARK: Network Call Method 
extension OfferHistoryVC
{
    func getProducts()
    {
        Utils.Show()
        let data: [String: Any] = [API_param.ManageOfferParams.User_Id: userDefault.value(forKey: API_param.Login.UserId)!]
        self.service.apiName = ApiName.offerHistory
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.offerHistory))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    func refreshTableView()
    {
        self.getProducts()
    }
}
//MARK: - Network Call Delegate 
extension OfferHistoryVC : ServiceDelegate
{
    internal func onFault(resultData:[String:Any]?,ServiceName:String)
    {
        Utils.HideHud()
        if resultData != nil
        {
            helperOb.toast(resultData![API_param.message] as! String)
        }
    }
    
    func onResult(resultData:Any?,ServiceName:String)
    {
        Utils.HideHud()
        if ServiceName.isEqual(ApiName.offerHistory)
        {
            if let resultDict = resultData as? [String: Any] {
                if resultDict[API_param.status] as? Int == 1{
                    refreshControl.endRefreshing()
                    ProductOb = Mapper<ProductHistoryDataOb>().map(JSON: resultDict)!
                    reloadTableViewWithAnimation(myTableView: tblView)
                    
                    if ProductOb?.buy_product != nil || ProductOb?.sell_product != nil
                    {
                        tblView.isHidden = false
                    }
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
    }
}

