//
//  ManageVC.swift
//  RedBill
//
//  Created by Rahul on 10/13/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import Alamofire

class ManageVC: UIViewController {
    
    @IBOutlet weak var viewNoItem: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    var arrData = [Dictionary<String,Any>]()
    var refreshControl = UIRefreshControl()
    var imgPath: String = ""
    
    var pic: UIImage = UIImage()
    var isFromCamera: Bool = false

    @IBAction func closeClicked(_ sender: Any) {
        
    }
    
    @IBAction func closeFire(_ sender: Any)
    {
        print("close clicked")
    }
    
}

//MARK: - LifeCycle
extension ManageVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.layer.zPosition = -1
        self.tabBarController?.navigationController?.isNavigationBarHidden = true
        
        tblView.tableFooterView = UIView()
        //        tblView.rowHeight = UITableViewAutomaticDimension
        //        tblView.estimatedRowHeight = 80.0
        self.view.layoutIfNeeded()
        
        viewNoItem.isHidden = false
        tblView.isHidden = true
        getListOfItemServiceCall()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tblView.addSubview(refreshControl) // not required when using UITableViewController
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: refreshManage, object: nil)
        
        isFromCamera ? btnAddNavClicked() : ()
        // To get all categoy
        getListOfCategoryServiceCall(true)
    }
    
    func refresh() {
        getListOfItemServiceCall()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed

        if segue.identifier == SegueIdentifire.itemDetailSegue {
            let dv = segue.destination as! ItemDetailVC
            dv.dict = sender as! Dictionary<String, Any>
            dv.imagePath = self.imgPath
        }else if segue.identifier == SegueIdentifire.createItemSegue {
            let dv = segue.destination as! UINavigationController
            let sdv: ManageListingVC = dv.viewControllers[0] as! ManageListingVC
            sdv.isFromCamera = true
            sdv.pic = self.pic
        }
    }
}

//MARK: - Initialization Method
extension ManageVC {
    
    func showTableView() {
        viewNoItem.isHidden = true
        tblView.isHidden = false
        tblView.reloadData()
        self.refreshControl.endRefreshing()
    }
}

//MARK: - UIButton Action Methods
extension ManageVC {
    @IBAction func btnAddItemClicked(_ sender: Any) {
        self.performSegue(withIdentifier: SegueIdentifire.createItemSegue, sender: nil)
    }
    
    func btnAddNavClicked() {
        print("nav button clicked")
        isFromCamera = !isFromCamera
        self.performSegue(withIdentifier: SegueIdentifire.createItemSegue, sender: nil)
    }
}

//MARK: - UITableViewDelegate & Datasource Methods
extension ManageVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListingTableViewCell
        
        let dict: Dictionary<String, Any> = arrData[indexPath.row]
        
        cell.lblTitle.text = dict[API_param.Product.title] as? String
        
        let status = dict[API_param.Product.status] as! String
        
        switch status {
        case "A":
            cell.lblStatus.text = "ACTIVE"
            cell.lblStatus.textColor = uiColorFromHex(rgbValue: 0x00B4B2)
        case "S":
            cell.lblStatus.text = "SOLD"
            cell.lblStatus.textColor = uiColorFromHex(rgbValue: 0xEA1917)
        case "D":
            cell.lblStatus.text = "CANCELED"
            cell.lblStatus.textColor = uiColorFromHex(rgbValue: 0x9B9B9B)
        default:
            cell.lblStatus.text = "ACTIVE"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = arrData[indexPath.row]
        let status = dict[API_param.Product.status] as! String
        status != "S" ? self.performSegue(withIdentifier: SegueIdentifire.itemDetailSegue, sender: dict) : ()
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableViewAutomaticDimension
    //    }
    //
    //    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableViewAutomaticDimension
    //    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //MARK:- Fade transition Animation
        cell.alpha = 0
        UIView.animate(withDuration: 0.33) {
            cell.alpha = 1
        }
        
        //MARK:- Curl transition Animation
        // cell.layer.transform = CATransform3DScale(CATransform3DIdentity, -1, 1, 1)
        
        // UIView.animate(withDuration: 0.4) {
        //  cell.layer.transform = CATransform3DIdentity
        //}
        
        //MARK:- Frame Translation Animation
        //cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, -cell.frame.width, 1, 1)
        
        // UIView.animate(withDuration: 0.33) {
        //  cell.layer.transform = CATransform3DIdentity
        // }
    }
    
}


//MARK: - WebService Methods
extension ManageVC {
    
    func getListOfItemServiceCall() {
        
        let params: Parameters = [API_param.Product.mylist: "1",
                                  API_param.Product.created_by: userDefault.value(forKey: API_param.Login.UserId)!]
        Utils.Show()
        
        Alamofire.request(URL(string: fromURL(uri: ApiName.GetListing))!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                                print(response.result.value as Any)   // result of response serialization
                Utils.HideHud()
                if let json = response.result.value as? Dictionary<String, Any> {
                    if json[API_param.status] as? Int == 1 {
                        let data: [Dictionary<String, Any>] = (json[API_param.data] as? [Dictionary<String, Any>])!
//                        print("data --> \(data)")
                        self.arrData = data
                        if let path = json[API_param.Product.image_path] {
                            self.imgPath = path as! String
                        }
                        if self.arrData.count == 0 {
                            self.viewNoItem.isHidden = false
                            self.tblView.isHidden = true
                        }else {
                            self.showTableView()
                        }
                    }else {
                        //                        need to check params
                        //                        print("Message : \(String(describing: json[API_param.message]!))")
                        Utils.showAlert("Error", message: "\(String(describing: json[API_param.message]!))", controller: self)
                    }
                }
        }
    }
}
