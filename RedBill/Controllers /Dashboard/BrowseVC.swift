//
//  DashboardVC.swift
//  RedBill
//
//  Created by Rahul on 10/9/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

/*
 
 //MARK: - Initialization Method
 
 //MARK: - UIButton Action Methods
 
 //MARK: - TextfieldDelegate Methods
 
 //MARK: - WebService Methods
 
 
 */
import UIKit
import Alamofire

class BrowseVC: UIViewController {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var sideMenuTrailingEdge: NSLayoutConstraint!
    @IBOutlet weak var sideMenuContainer: UIView!
    @IBOutlet weak var viewNoItem: UIView!
    @IBOutlet weak var imgNoItem: UIImageView!
    @IBOutlet weak var lblNoItemText: UILabel!
    //    @IBOutlet weak var // gestureView: UIView!
    
    //MARK: - Variables
    
    var isSideMenu = true
    var selectedImage = UIImage()
    var arrItem    = [Dictionary<String, Any>]()
    var selectedIndex   = IndexPath(row: 0, section: 0)
    var imgPath: String = ""
    var selectedImageUrl = ""
    var refreshControl: UIRefreshControl!
}

//MARK: - LifeCycle
extension BrowseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "RedBill"))
        self.navigationController?.navigationBar.layer.zPosition = -1
        self.tabBarController?.navigationController?.isNavigationBarHidden = true
        
        self.searchView.setSearchFieldBackgroundImage(UIImage(named: "Rectangle1"), for: UIControlState.normal)
        let textFieldInsideSearchBar = self.searchView.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        //DBV For Side Menu
        sideMenuTrailingEdge.constant = -sideMenuContainer.frame.size.width
        
        getListOfItemServiceCall()
        
        // gestureView.alpha = 0
        isSideMenu = false
        self.view.layoutIfNeeded()
        addPullToRefresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.btnClose_Click(_:)), name: closeNotificationName, object: nil)
        
        let confirmAction = UIAlertController(title: "Welcome to RedBill.co!", message: "Post items to sell. \nBrowse items to buy. \nA percentage of each sale will go towards a goodwill cause selected by the seller of the sold item. ", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            //        // To get all categoy
            getListOfCategoryServiceCall(true)
        })
        confirmAction.addAction(okAction)
        self.present(confirmAction, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        
        // DBV if navigate thorough side menu and come back
        if isSideMenu {
            self.navigationController?.navigationBar.layer.zPosition = -1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func hideShowSideMenu(withCompletionHandler completionHandler: @escaping (() -> Void)) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            
            if self.isSideMenu {
                self.sideMenuTrailingEdge.constant = -self.sideMenuContainer.frame.size.width
                //   self.// gestureView.alpha = 0
            } else {
                self.sideMenuTrailingEdge.constant = 0
                self.navigationController?.navigationBar.layer.zPosition = -1
                //  self.// gestureView.alpha = 1
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
        myCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifire.detailSgue {
            let dvc = segue.destination as! ProductDetailVC
            dvc.dictData = sender as! Dictionary<String, Any>
            dvc.imagePath = imgPath
        }
    }
}

//MARK: - Helper Methods

extension BrowseVC {
    
    func addPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(BrowseVC.refresh), for: UIControlEvents.valueChanged)
        myCollectionView.addSubview(refreshControl)
    }
    
    func refresh() {
        print("refresh clicked")
        getListOfItemServiceCall()
    }
}

////MARK: - TabBarDelegate Method
//func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//    if tabBarController.selectedIndex == 2 {
//        getAllGalleryImages()
//    }
//}
//}

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
            if arrImages.count >= 1 {
                let url = self.imgPath + "\(String(describing: arrImages[0]))"
                Utils.downloadImage(url, imageView: cell.imgItem)
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
        if appDelegate.minValue > 0 {
            minP = "\(appDelegate.minValue)"
        }
        
        var maxP: String = ""
        if appDelegate.maxValue > 0 {
            maxP = "\(appDelegate.maxValue)"
        }        
        let params: Parameters = [API_param.Product.title: searchView.text!,
                                  API_param.Product.category_id: appDelegate.globalCatIndex,
                                  API_param.Product.min_price: minP,
                                  API_param.Product.max_price: maxP,
                                  API_param.Product.distance: appDelegate.distance,
                                  API_param.Product.limit: "100",
                                  API_param.Product.offset: "1",
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
                            self.searchView.text!.characters.count > 0 ? self.showNoItemView(1) : self.showNoItemView(0)
                        }else {
                            self.hideNoItemView()
                        }
                    }else {
                        Utils.showAlert("Error", message: "\(String(describing: json[API_param.message]!))", controller: self)
                    }
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
        getListOfItemServiceCall()
    }
}

//MARK: - UIButton Action Methods
extension BrowseVC {
    
    @IBAction func btnChatClicked(_ sender: Any) {
        print("this is chat button")
    }
    @IBAction func btnProfileClicked(_ sender: Any) {
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
