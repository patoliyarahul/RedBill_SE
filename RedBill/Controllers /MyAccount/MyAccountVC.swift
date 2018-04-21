//
//  MyAccountVC.swift
//  RedBill
//
//  Created by Rahul on 11/9/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit

class MyAccountVC: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    
    var arrData = ["My Offers","Transaction History","Payment Methods","Settings"]
    var arrImages = ["offer","history","credit-card","Setting"]
    let service = Service()
}

//MARK: - LifeCycle
extension MyAccountVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        service.delegate = self

        tblView.tableFooterView = UIView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let backItem = UIBarButtonItem()
//        backItem.title = ""
//        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
}

//MARK: - Initialization Method
extension MyAccountVC {
    
    func callService_logout() {
        let data: [String: Any] = [API_param.Login.UserId : userDefault.string(forKey: API_param.Login.UserId)!,
                                   API_param.Login.device_id: userDefault.value(forKey: DefaultValues.device_id) ?? "1"]
        //we need to pass blank if no da device id
        self.service.apiName = ApiName.logout
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.logout))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    func moveToRoot() {
        self.navigationController?.dismiss(animated: true, completion: {
            let viewControllers: [UIViewController] = (appDelegate.navRefrence?.viewControllers)!
            print("Navigation ===",viewControllers)
            for aViewController in viewControllers {
                if aViewController is HomeVC {
                    userDefault.set(false, forKey: Constant.kIsLoggedIn)
                    self.tabBarController?.navigationController?.isNavigationBarHidden = true
                    appDelegate.navRefrence?.popToViewController(aViewController, animated: true)
                }
            }
        })
    }
}

//MARK: - UIButton Action Methods
extension MyAccountVC {
    @IBAction func btnCloseClicked(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnLogoutClicked(_ sender: Any)
    {
        callService_logout()
    }
}


//MARK: - UITableViewDelegate And Datasource Methods
extension MyAccountVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyAccountCell
        
        cell.lblTittle.text = arrData[indexPath.row]
        cell.imgView.image = UIImage(named: arrImages[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row
        {
        case 0:
            self.performSegue(withIdentifier: SegueIdentifire.manageProductSegue, sender: nil)
            break
        case 1:
            self.performSegue(withIdentifier: SegueIdentifire.historySegue, sender: nil)
            break
        case 2:
            self.performSegue(withIdentifier: SegueIdentifire.myCardsSegue, sender: nil)
            break
        case 3:
            self.performSegue(withIdentifier: SegueIdentifire.settingSegue, sender: nil)
            break
        default:
            break
        }
        print("This row is clicked --> \(indexPath.row+1)")
    }
}


extension MyAccountVC : ServiceDelegate
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
        if ServiceName.isEqual(ApiName.logout)
        {
            if let resultDict = resultData as? [String: Any]
            {
                if resultDict[API_param.status] as? Int == 1{
                    self.moveToRoot()
//                    print("data --> \(resultDict)")
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
    }
}

