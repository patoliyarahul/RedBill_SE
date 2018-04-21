//
//  HomeVC.swift
//  RedBill
//
//  Created by Rahul on 9/20/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import AVFoundation
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
import ObjectMapper

class HomeVC: UIViewController {
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    let service = Service()

    @IBOutlet weak var imgSplash: UIImageView!
}
//MARK: LifeCycle

extension HomeVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.navRefrence = self.navigationController
        // to play video
        let urlPath = Bundle.main.url(forResource: "Redbill", withExtension: ".mov")
        service.delegate = self

        avPlayer = AVPlayer(url: urlPath!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .black
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notificaion:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
        if userDefault.bool(forKey: Constant.kIsLoggedIn) == true {
            self.performSegue(withIdentifier: SegueIdentifire.homeSegue, sender: self) // dbv added block and removed animation from segue in storyboard for logged in segue.
            return
        }
        imgSplash.isHidden = true
    }
    
    func playerItemDidReachEnd(notificaion: Notification) {
        let p: AVPlayerItem = notificaion.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.play()
        paused = false
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        avPlayer.pause()
        paused = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        imgSplash.isHidden = true
        self.navigationController?.isNavigationBarHidden = false //dbv added this line.... reason if this screen appears after log in navigaiton bar is hidden...
        self.navigationController?.navigationBar.SetCustomNavigationBar()
        self.navigationController?.navigationBar.layer.zPosition = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnFb_Click(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        print("Logging In")
        facebookLogin.logIn(withReadPermissions: ["email", "public_profile"], from: self, handler:{(facebookResult, facebookError) -> Void in
            if facebookError != nil {
                let message = (facebookError?.localizedDescription)!
                
                let alertController = UIAlertController(title: "Facebook Login Error", message: message, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
                
            } else if (facebookResult?.isCancelled)! { print("Facebook login was cancelled.")
                let alertController = UIAlertController(title: "Facebook Login Cancelled", message: "", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let fbloginresult : FBSDKLoginManagerLoginResult = facebookResult!
                
                let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(large)"])
                let _ = request?.start(completionHandler: { (connection, result, error) in
                    guard let userInfo = result as? [String: Any] else { return } //handle the error
                    
                    self.callService_login(userInfo)
                    
                    //The url is nested 3 layers deep into the result so it's pretty messy
                    if (((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String) != nil {
                        //Download image from imageURL
                    }
                })
                
                if(fbloginresult.grantedPermissions.contains("email")) {
                    if((FBSDKAccessToken.current()) != nil){
                        //                        let params = ["access_token" : fbloginresult.token.tokenString!]
                        //                        let finalUrl = URL(string: URLs.baseUrl.appending(URLs.userBase).appending(ActionNames.fbLoginAction).appending(URLs.urlKey))
                        //                        self.service.apiName = ActionNames.fbLoginAction
                        //                        self.service.callPostURL(url: finalUrl!, parameters: params, encodingType: "default", headers: [:])
                    }
                }
            }
        });
    }
    
    //MARK: - WebService Methods
    func callService_login(_ userInfo:[String: Any]) {
        var email = ""
        if (userInfo["email"] as? String) != nil {
            email = userInfo["email"]! as! String
        }
        
        var firstName = ""
        if (userInfo["first_name"] as? String) != nil {
            firstName = userInfo["first_name"]! as! String
        }
        
        var lastName = ""
        if (userInfo["last_name"] as? String) != nil {
            lastName = userInfo["last_name"]! as! String
        }
        
        var phone = ""
        if (userInfo["phone"] as? String) != nil {
            phone = userInfo["phone"]! as! String
        }
        
        Utils.Show()

        let data: [String: Any] = [API_param.Login.email : email,
                                   API_param.Login.password: "",
                                   API_param.Login.type: DefaultValues.device_type_val,
                                   API_param.Login.latitude: "",
                                   API_param.Login.longitude: "",
                                   API_param.Login.first_name: firstName,
                                   API_param.Login.last_name: lastName,
                                   API_param.Login.phone: phone,
                                   API_param.Login.fb_token: userInfo["id"]!,
                                   API_param.Login.login_type: "2", // 2 for FB
            API_param.Login.device_id: userDefault.value(forKey: DefaultValues.device_id) ?? ""]
        self.service.apiName = ApiName.post_login
        self.service.callPostURL(url:URL(string: Constant.URL_PREFIX.appending(ApiName.post_login))!, parameters: data,encodingType:"json",headers:nil)
    }
}


//MARK: - Network Call Delegate 
extension HomeVC : ServiceDelegate
{
    internal func onFault(resultData:[String:Any]?,ServiceName:String)
    {
        Utils.HideHud()
        if resultData != nil
        {
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
                    
//                    let data: Dictionary<String, Any> = (json[API_param.data] as? Dictionary<String, Any>)!
                    print("data --> \(String(describing: resultDict[API_param.data]))")
                    
                    userDefault.set(true, forKey: Constant.kIsLoggedIn)
                    Utils.storeResponseToUserDefault(resultDict[API_param.data] as AnyObject)
                    
                    self.performSegue(withIdentifier: SegueIdentifire.homeSegue, sender: self) // dbv added block and removed animation from segue in storyboard for logged in segue.
                }else {
                    helperOb.toast(resultDict[API_param.message] as! String)
                }
            }
        }
    }
}
