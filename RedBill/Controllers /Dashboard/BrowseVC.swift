//
//  DashboardVC.swift
//  RedBill
//
//  Created by Rahul on 10/9/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseAuth
import ObjectMapper

class BrowseVC: UIViewController
{
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var sideMenuTrailingEdge: NSLayoutConstraint!
    @IBOutlet weak var sideMenuContainer: UIView!
    @IBOutlet weak var viewNoItem: UIView!
    @IBOutlet weak var imgNoItem: UIImageView!
    @IBOutlet weak var lblNoItemText: UILabel!
    //    @IBOutlet weak var // gestureView: UIView!
    @IBOutlet weak var btnMyAccount: UIBarButtonItem!
    
    //MARK: - Variables
    
    var isSideMenu = true
    var selectedImage = UIImage()
    var arrItem    = [Dictionary<String, Any>]()
    var selectedIndex   = IndexPath(row: 0, section: 0)
    var imgPath: String = ""
    var selectedImageUrl = ""
    var refreshControl: UIRefreshControl!
    let service = Service()
    var donationWithProductOb: DonationWithProductData?
}

//MARK: - LifeCycle
extension BrowseVC
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        service.delegate = self
        
        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "RedBill"))
        self.navigationController?.navigationBar.layer.zPosition = -1
        self.tabBarController?.navigationController?.isNavigationBarHidden = true
        
        self.searchView.setSearchFieldBackgroundImage(UIImage(named: "Rectangle1"), for: UIControlState.normal)
        let textFieldInsideSearchBar = self.searchView.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        getListOfItemServiceCall()
        
        addPullToRefresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.btnClose_Click(_:)), name: closeNotificationName, object: nil)
        
        let confirmAction = UIAlertController(title: "Welcome to RedBill.co!", message: "Post items to sell. \nBrowse items to buy. \nA percentage of each sale will go towards a goodwill cause selected by the seller of the sold item. ", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            //        // To get all categoy
            getListOfCategoryServiceCall(true)
        })
        confirmAction.addAction(okAction)
        self.present(confirmAction, animated: true, completion: nil)
        
        signupOrLoginToFirebase()
        btnMyAccount.badgeString = "1"
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        if isSideMenu{
            self.navigationController?.navigationBar.layer.zPosition = -1
        }
        getListOfCategoryServiceCall(true)
        getBandgeData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sideMenuTrailingEdge.constant = -sideMenuContainer.frame.size.width
        isSideMenu = false
        self.view.layoutIfNeeded()
        self.getDonationData()
        
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    
    func hideShowSideMenu(withCompletionHandler completionHandler: @escaping (() -> Void)) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            
            if self.isSideMenu {
                self.sideMenuTrailingEdge.constant = -self.sideMenuContainer.frame.size.width
            } else {
                self.sideMenuTrailingEdge.constant = 0
                self.navigationController?.navigationBar.layer.zPosition = -1
            }
            self.view.layoutIfNeeded()
        }) { (bool : Bool) in
            self.isSideMenu = !self.isSideMenu
            if !self.isSideMenu {
                self.navigationController?.navigationBar.layer.zPosition = 0
                completionHandler()
            }
        }
    }
    
    func showNoItemView(_ index:Int) {
        viewNoItem.isHidden = false
        myCollectionView.isHidden = true
        
        if (index == 0) { // No Item
            imgNoItem.image = #imageLiteral(resourceName: "NoItem")
            lblNoItemText.text = "We’re sorry, but there are no listings available."
        } else { // No Search Item
            imgNoItem.image = #imageLiteral(resourceName: "searchbig")
            lblNoItemText.text = "Search Not Found."
        }
    }
    
    func hideNoItemView() {
        viewNoItem.isHidden = true
        myCollectionView.isHidden = false
        DispatchQueue.main.async {
            self.myCollectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == SegueIdentifire.detailSgue
        {
            let nvc = segue.destination as! UINavigationController  //dbv
            let dvc = nvc.viewControllers.first as! ProductDetailVC
            dvc.dictData = sender as! Dictionary<String, Any>
            dvc.imagePath = imgPath
            dvc.isFrom = ""
        }else if segue.identifier == SegueIdentifire.chatSegue {
            let dv = segue.destination as! ChatListVC
            dv.hidesBottomBarWhenPushed = true
        }else if segue.identifier == SegueIdentifire.donationSegue {
            let dvc = segue.destination as! TransctionCompleteVC
            dvc.donationWithProductOb = self.donationWithProductOb
        }
    }
}

//MARK: - Helper Methods

extension BrowseVC
{
    func addPullToRefresh()
    {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(BrowseVC.refresh), for: UIControlEvents.valueChanged)
        myCollectionView.addSubview(refreshControl)
    }
    
    func refresh()
    {
        print("refresh clicked")
        DispatchQueue.main.async {
            self.getListOfItemServiceCall()
        }
    }
    func signupOrLoginToFirebase() {
        if let email = userDefault.string(forKey: FUserParams.FUSER_EMAIL) {
            Auth.auth().signIn(withEmail: email, password: "123456") { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                    if err.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." {
                        Auth.auth().createUser(withEmail: email, password: "123456") { (user, error) in
                            if let err = error { // 3
                                print(err.localizedDescription)
                                return
                            }
                            Chat_Utils.updateFUserPersonalDetails()
                        }
                    } else {
                        return
                    }
                } else {
                    Chat_Utils.updateFUserPersonalDetails()
                }
            }
        }
    }
    
    func getDonationData() {
        Utils.Show()
        let data: [String: Any] = [API_param.Login.UserId: userDefault.string(forKey: API_param.Login.UserId)!]
        //        print("data -> \(data)")
        self.service.apiName = ApiName.get_product_donation
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.get_product_donation))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    func getBandgeData() {
        let params: Parameters = [API_param.Login.UserId: userDefault.string(forKey: API_param.Login.UserId)!]
        
        Alamofire.request(URL(string: fromURL(uri: ApiName.getOfferCount))!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                print(response.result.value as Any)   // result of response serialization
                Utils.HideHud()
                if let json = response.result.value as? Dictionary<String, Any> {
                    if json[API_param.status] as? Int == 1 {
                        print("data --> \(json)")
                        let data =  (json[API_param.data] as? String)!
                        print("count --> \(data)")
                        if data.count > 0 {
                            print("count --> \(data)")
                        }
                    }
                }else {
                    self.showNoItemView(0)
                    Utils.showAlert(MESSAGES.error, message: MESSAGES.no_internet, controller: self)
                }
        }
    }
}

//MARK: - UICollectionView Delegate & Datasource

extension BrowseVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! BrowseCell
        
        let dict = self.arrItem[indexPath.row] as Dictionary<String, Any>
        if let arrImages = dict[API_param.Product.images]! as? [String] {
            cell.imgItem.indexPath = indexPath as NSIndexPath
            if arrImages.count >= 1 {
                cell.imgItem.image = UIImage()
                if cell.imgItem.indexPath == (indexPath as NSIndexPath) {
                    let url = self.imgPath + "\(String(describing: arrImages[0]))"
                    Utils.downloadImage(url, imageView: cell.imgItem)
                }
            }else {
                cell.imgItem.image = #imageLiteral(resourceName: "no_image")
            }
        }
        cell.lblName.text = "\(String(describing: dict[API_param.Product.title]!))"
        cell.lblPrice.text = "$ \(String(describing: dict[API_param.Product.price]!))"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width - 21) / 2
        return CGSize(width: width, height: 200.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.isSideMenu ? hideShowSideMenu { } : ()
        selectedIndex = indexPath
        //        print("This is iamge is clicked ----> \(indexPath.row + 1 )")
        let dict = self.arrItem[indexPath.row] as Dictionary<String, Any>
        self.performSegue(withIdentifier: SegueIdentifire.detailSgue, sender: dict)
    }
}

extension BrowseVC {
    
    func getListOfItemServiceCall() {
        
        var minP: String = ""
        if appDelegate.minValue >= 0 {
            minP = "\(appDelegate.minValue)"
        }
        
        var maxP: String = ""
        if appDelegate.maxValue >= 0 {
            maxP = "\(appDelegate.maxValue)"
        }        
        let params: Parameters = [API_param.Product.title: searchView.text!,
                                  API_param.Product.category_id: appDelegate.globalCatIndex,
                                  API_param.Product.min_price: minP,
                                  API_param.Product.max_price: maxP,
                                  API_param.Product.distance: appDelegate.distance,
                                  API_param.Product.limit: "1000",
                                  API_param.Product.offset: "0",
                                  API_param.Product.created_by: userDefault.value(forKey: API_param.Login.UserId)!,
                                  ]
        Utils.Show()
        
        Alamofire.request(URL(string: fromURL(uri: ApiName.GetListing))!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                //                print(response.result.value as Any)   // result of response serialization
                Utils.HideHud()
                self.refreshControl.endRefreshing()
                if let json = response.result.value as? Dictionary<String, Any> {
                    if json[API_param.status] as? Int == 1 {
                        let data: [Dictionary<String, Any>] = (json[API_param.data] as? [Dictionary<String, Any>])!
                        //                        print("data --> \(data)")
                        self.arrItem = data
                        if let path = json[API_param.Product.image_path] {
                            self.imgPath = path as! String
                        }
                        
                        if self.arrItem.count == 0 {
                            self.searchView.text!.count > 0 ? self.showNoItemView(1) : self.showNoItemView(0)
                        }else {
                            self.hideNoItemView()
                        }
                    }else {
                        Utils.showAlert("Error", message: "\(String(describing: json[API_param.message]!))", controller: self)
                    }
                }else {
                    self.showNoItemView(0)
                    Utils.showAlert(MESSAGES.error, message: MESSAGES.no_internet, controller: self)
                }
        }
    }
}
//MARK: - UISearchBar Delegate Methods
extension BrowseVC:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //        getListOfItemServiceCall()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.getListOfItemServiceCall()
    }
}

//MARK: - UIButton Action Methods
extension BrowseVC {
    @IBAction func btnChatClicked(_ sender: Any)
    {
        print("this is chat button")
    }
    @IBAction func btnProfileClicked(_ sender: Any)
    {
        print("this is profile button")
    }
    
    @IBAction func tapGesture(_ sender: Any) {
        hideShowSideMenu { }
    }
    
    @IBAction func btnSideMenu_Click(_ sender: Any) {
        hideShowSideMenu { }
    }
    
    func btnClose_Click(_ sender: Any) {
        hideShowSideMenu { }
        getListOfItemServiceCall()
    }
}

//MARK: - Initialization Method
extension BrowseVC: ServiceDelegate {
    internal func onFault(resultData:[String:Any]?,ServiceName:String) {
        Utils.HideHud()
        if resultData != nil {
            helperOb.toast(resultData![API_param.message] as! String)
        }
    }
    
    func onResult(resultData:Any?,ServiceName:String) {
        Utils.HideHud()
        
        if ServiceName.isEqual(ApiName.get_product_donation) {
            if let resultDict = resultData as? [String: Any] {
                if resultDict[API_param.status] as? Int == 1 {
                    //                    print("data --> \(resultDict)")
                    let data: [Dictionary<String, Any>] = (resultDict[API_param.data] as? [Dictionary<String, Any>])!
                    if data.count > 0 {
                        if !Utils.isModal(UIApplication.topViewController()!){
                            self.donationWithProductOb = Mapper<DonationWithProductData>().map(JSON: resultDict)!
                            self.performSegue(withIdentifier: SegueIdentifire.donationSegue, sender: self)
                        }
                    }
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
    }
}
