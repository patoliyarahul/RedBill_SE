//
//  SettingViewController.swift
//  Get Nue
//
//  Created by Rahul Patoliya on 21/04/17.
//  Copyright © 2017 Rahul Patoliya. All rights reserved.
//

import UIKit
import Alamofire

//MARK: - IBOutlet & Variables

class SettingViewController: UIViewController {
    
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var switchNotification: UISwitch!

    let service = Service()

}

//MARK: LifeCycle

extension SettingViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        service.delegate = self
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        lblVersion.text = "Version: \(version) & Build: \(build)"
        
        switchNotification.isOn = userDefault.bool(forKey: API_param.pushNotification)
        switchNotification.addTarget(self, action: #selector(SettingViewController.switchIsChanged(mySwitch:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setNavigationProperties()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
//        resetNavigationProperties()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - Methods

extension SettingViewController {
    
    func callServiceToUpdateNotification(isOn : Bool) {
        let data: [String: Any] = [API_param.Login.UserId : userDefault.string(forKey: API_param.Login.UserId)!,
                                   API_param.pushNotification: isOn]
        self.service.apiName = ApiName.change_push
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.change_push))!, parameters: data,encodingType:"json",headers:nil)
    }
    
    func setNavigationProperties() {
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = uiColorFromHex(rgbValue: 0x287089)
        
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : uiColorFromHex(rgbValue: 0x287089), NSFontAttributeName :  UIFont(name: "Gotham Medium", size: 14)!]
        
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.navigationController?.navigationBar.layer.shadowRadius = 2.0;
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.2;
    }
    
    func resetNavigationProperties() {
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white

        self.navigationController?.navigationBar.titleTextAttributes = nil
    }
}

//MARK: - UIButton Action Methods

extension SettingViewController {
    
    func switchIsChanged(mySwitch: UISwitch) {
        callServiceToUpdateNotification(isOn: switchNotification.isOn)
    }
}

//MARK: - RequestManager Delegate

extension SettingViewController : ServiceDelegate
{
    internal func onFault(resultData:[String:Any]?,ServiceName:String) {
        Utils.HideHud()
        if resultData != nil
        {
            helperOb.toast(resultData![API_param.message] as! String)
        }
    }
    
    func onResult(resultData:Any?,ServiceName:String)
    {
        Utils.HideHud()
        if ServiceName.isEqual(ApiName.change_push) {
            if let resultDict = resultData as? [String: Any] {
                if resultDict[API_param.status] as? Int == 1{
                    helperOb.toast(resultDict[API_param.message] as! String)
                    userDefault.set(switchNotification.isOn, forKey: API_param.pushNotification)
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
    }
}
