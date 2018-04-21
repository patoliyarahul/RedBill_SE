//
//  MyProductsVC.swift
//  RedBill
//
//  Created by Vipul Jikadra on 26/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper

//MARK: - Properties 
class MyProductsVC: UIViewController
{
    @IBOutlet weak var tblView: UITableView!
    var arrData = [Dictionary<String, Any>]()
    let service = Service()
    var ProductOb:MyProductOb?
    
    let refreshControl = { () -> UIRefreshControl in
        let refresher = UIRefreshControl()
        return refresher
    }()
    var productDetailsOb:OfferProductDetailsOb?
    var isComeAs:String?
}

//MARK: - LifeCycle 
extension MyProductsVC
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        service.delegate = self
        configureTableView(tblView)
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tblView.insertSubview(refreshControl, at: 0)
        getProducts()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        navigationController?.navigationBar.ReSetCustomNavigationBar()
        getProducts()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Navigation 
extension MyProductsVC
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == SegueIdentifire.productOfferSegue
        {
            let dv = segue.destination as! ManageOfferVC
            dv.productDetailsOb = self.productDetailsOb
            dv.isComeAs = self.isComeAs
        }
    }
}
//MARK: - UITableViewDelegate And Datasource Methods 
extension MyProductsVC : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
        case 0:
            guard ProductOb?.sell_product?.isEmpty == false else
            {
                return 1
            }
            return (ProductOb?.sell_product?.count)!
            
        case 1:
            guard ProductOb?.buy_product?.isEmpty == false else
            {
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
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
        case 0:
            return "Products for Sale"
        case 1:
            return "Products for Purchase"
        default:
            return ""
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyAccountCell
        
        cell.tintColor = uiColorFromHex(rgbValue: 0x4A4A4A)
        cell.selectionStyle = .none
        
        switch indexPath.section
        {
        case 0:
            guard ProductOb?.sell_product?.count == 0 else
            {
                cell.accessoryType = .disclosureIndicator
                cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "detail"))

                let sellProductOb = ProductOb?.sell_product![indexPath.row]
                cell.lblTittle.text = sellProductOb?.title?.description.replacingOccurrences(of: "<[^>]+>\r\n", with: "", options:.regularExpression, range: nil)
                
                cell.indexPath = indexPath as NSIndexPath
                if cell.indexPath == (indexPath as NSIndexPath) {
                    if sellProductOb?.product_view != nil && Int((sellProductOb?.product_view)!)! > 0 {
                        cell.lblTittle.font = UIFont(name: "Proxima Nova Bold", size: 22)
                        cell.lblTittle.textColor = uiColorFromHex(rgbValue: 0x6464FF)
                    }else {
                        cell.lblTittle.font = UIFont(name: "Proxima Nova Regular", size: 18)
                        cell.lblTittle.textColor = uiColorFromHex(rgbValue: 0x4A4A4A)
                    }
                }
                return cell
            }
            cell.lblTittle.text = MESSAGES.NO_PRODUCT
            cell.lblTittle.font = UIFont(name: "Proxima Nova Regular", size: 18)
            cell.lblTittle.textColor = uiColorFromHex(rgbValue: 0x4A4A4A)
            cell.accessoryType = .none
            return cell
        case 1:
            guard ProductOb?.buy_product?.count == 0 else
            {
                cell.accessoryType = .disclosureIndicator
                cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "detail"))

                let buyProductOb = ProductOb?.buy_product![indexPath.row]
                cell.lblTittle.text = buyProductOb?.title?.description.replacingOccurrences(of: "<[^>]+>\r\n", with: "", options:.regularExpression, range: nil)
                cell.indexPath = indexPath as NSIndexPath
                if cell.indexPath == (indexPath as NSIndexPath) {
                    if buyProductOb?.product_view != nil && Int((buyProductOb?.product_view)!)! > 0 {
                        cell.lblTittle.font = UIFont(name: "Proxima Nova Bold", size: 22)
                        cell.lblTittle.textColor = uiColorFromHex(rgbValue: 0x6464FF)
                    }else {
                        cell.lblTittle.font = UIFont(name: "Proxima Nova Regular", size: 18)
                        cell.lblTittle.textColor = uiColorFromHex(rgbValue: 0x4A4A4A)
                    }
                }
                return cell
            }
            cell.accessoryType = .none
            cell.lblTittle.text = MESSAGES.NO_PRODUCT
            cell.lblTittle.font = UIFont(name: "Proxima Nova Regular", size: 18)
            cell.lblTittle.textColor = uiColorFromHex(rgbValue: 0x4A4A4A)
            return cell
        default:
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        switch indexPath.section
        {
        case 0:
            guard ProductOb?.sell_product?.count != 0 else
            {
                return
            }
            isComeAs = User.Seller
            productDetailsOb = ProductOb?.sell_product![indexPath.row] != nil ? ProductOb?.sell_product![indexPath.row] : nil
        case 1:
            guard ProductOb?.buy_product?.count != 0 else
            {
                return
            }
            isComeAs = User.Buyer
            productDetailsOb = ProductOb?.buy_product![indexPath.row] != nil ? ProductOb?.buy_product![indexPath.row] : nil
        default:
            return
        }
        self.performSegue(withIdentifier: SegueIdentifire.productOfferSegue, sender: self)
    }
}
//MARK: Network Call Method 
extension MyProductsVC
{
    func getProducts()
    {
        Utils.Show()
        let data: [String: Any] = [API_param.ManageOfferParams.User_Id: userDefault.value(forKey: API_param.Login.UserId)!]
        self.service.apiName = ApiName.myProductList
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.myProductList))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    func refreshTableView()
    {
        self.getProducts()
    }
}
//MARK: - Network Call Delegate 
extension MyProductsVC : ServiceDelegate
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
        if ServiceName.isEqual(self.service.apiName)
        {
            if let resultDict = resultData as? [String: Any] {
                if resultDict[API_param.status] as? Int == 1{
                    refreshControl.endRefreshing()
                    ProductOb = Mapper<MyProductOb>().map(JSON: resultDict)!
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
