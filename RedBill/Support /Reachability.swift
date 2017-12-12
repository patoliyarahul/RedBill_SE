//
//  ReachabilityManager.swift
//  Allo Boulangerie
//
//  Created by Dharmesh Vaghani on 01/04/16.
//  Copyright © 2016 Dharmesh Vaghani. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class ReachabilityManager: NSObject {
    fileprivate var _useClosures:Bool = false
    fileprivate var _isReachability:Bool = false
    fileprivate var _reachabiltyNetworkType :String?
    
    
    static let sharedInstance: ReachabilityManager = {
        let instance = ReachabilityManager()
        return instance
    }()
    
    override init() {
        super.init()
        _ = isReachability
    }
    
    var isReachability:Bool {
        get {
            if (_isReachability == false) {
                
                let manager = NetworkReachabilityManager(host: "www.google.com")
                manager?.listener = { status in 
                    
                    print("Network Status Changed: \(status)")
                    print("network reachable \(manager!.isReachable)")
                    
                    self._isReachability = (manager?.isReachable)!
                }
                manager?.startListening()
            }
            
            return _isReachability
        }
    }
    var reachabiltyNetworkType:String {
        get {return _reachabiltyNetworkType! }
    }    
}
