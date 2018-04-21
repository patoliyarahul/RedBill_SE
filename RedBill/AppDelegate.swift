//
//  AppDelegate.swift
//  RedBill
//
//  Created by Rahul on 9/18/17.
//  Copyright © 2017 Rahul. All rights reserved.
//


import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import CoreLocation
import Mixpanel
import Firebase
import Alamofire
import FBSDKCoreKit
//import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,CLLocationManagerDelegate {
    
    var window: UIWindow?
    var arrCategory = [Dictionary<String,Any>]()
    var arrCategoryWithAll = [Dictionary<String,Any>]()
    var globalCatIndex: Int = 0
    var minValue: Float = -1
    var maxValue: Float = -1
    var distance: Float = 0.0
    var navRefrence:UINavigationController?
    var cardParam: Parameters = [:]

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        IQKeyboardManager.sharedManager().enable = true
        FirebaseApp.configure() //dbv firebase chat
        
        // facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        //
        
        Mixpanel.initialize(token: "9763ac8714b31c21f121a934a3ce9619")
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            showNewRequestView(userInfo: notification as NSDictionary)
        } else {
            registerForPushNotifications(application: application)
        }
        
        #if (arch(i386) || arch(x86_64)) && os(iOS) //dbv added for simulator
            userDefault.set("1234567890123456", forKey:DefaultValues.device_id)
        #endif
        
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // open chat view if notification is for chat
    
    //dbv call this method based on notification result if it is for chat.........
    func showChatView(userInfo : NSDictionary) {
        
        if let senderEmail = userInfo["email"] as? String, !(UIApplication.topViewController() is ChatViewController) {
            Chat_Utils.startPrivateChat(email: senderEmail, completionHandler: { (recent: Recent) in
                let storyboard = UIStoryboard(name: "Browse", bundle: nil)
                let nav = storyboard.instantiateViewController(withIdentifier: "ChatNav") as! UINavigationController
                
                let chatViewController = nav.viewControllers[0] as! ChatViewController
                
                chatViewController.recent = recent
                
                chatViewController.isFromNotif = true
                
                self.window?.makeKeyAndVisible()
                self.window?.rootViewController?.show(nav, sender: nil)
                
            })
        }
    }
    
    //MARK: - Pushnotification
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //Handle the notification
        debugPrint("willPresent")
        debugPrint("notification---->",notification.request.content.userInfo)
        
        showNewRequestView(userInfo: notification.request.content.userInfo as NSDictionary)
        completionHandler([.alert, .badge, .sound]) // new
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //Handle the notification
        debugPrint("didReceive")
        debugPrint("response------>",response.notification.request.content.userInfo)
        
        UIApplication.shared.applicationIconBadgeNumber += 1
        
        let userInfo = response.notification.request.content.userInfo
        print("tempDict ---> \(userInfo)")
        if let tempDict = userInfo["aps"] as? NSDictionary  {
            if "\(tempDict["push_type"]!)" == "1" {  // 1 is for chat
                showChatView(userInfo: tempDict)
            }
        }
        
        completionHandler() // new
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        showNewRequestView(userInfo: userInfo as NSDictionary)
        //        print(userInfo)
    }
    
    func showNewRequestView(userInfo : NSDictionary) {
        if let tempDict = userInfo["aps"] as? NSDictionary {
            if let dict = tempDict["data"] as? [Dictionary<String, Any>] {
                if dict.count > 0 {
                    //                    print(dict)
                    //                    appDelegate.isNotificationView = true
                    //                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    //                    var vc = AppointmentDetailVC()
                    //                    vc = storyboard.instantiateViewController(withIdentifier: "AppointmentDetailVC") as! AppointmentDetailVC
                    //                    vc.dictData = dict[0]
                    //                    UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func registerForPushNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                if (granted){
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                    })
                }else {
                    //Do stuff if unsuccessful...
                    print("push notification registrastion unsuccessful.")
                    debugPrint("push notification registrastion unsuccessful.")
                }
            })
        }else { //If user is not on iOS 10 use the old methods we've been using
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let token = String(format: "%@", deviceToken as CVarArg)
            .trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
            .replacingOccurrences(of: " ", with: "")
        debugPrint("Token :",token)
        userDefault.set(token, forKey:DefaultValues.device_id)
        
        var uuid = UIDevice.current.identifierForVendor?.uuidString
        uuid = uuid?.replacingOccurrences(of: "-", with: "")
        userDefault.set(uuid, forKey: DefaultValues.uuid)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        //Handle the notification
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        //Handle the notification
    }
    
    struct Platform {
        static let isSimulator: Bool = {
            var isSim = false
            #if arch(i386) || arch(x86_64)
                isSim = true
            #endif
            return isSim
        }()
    }
}


extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
