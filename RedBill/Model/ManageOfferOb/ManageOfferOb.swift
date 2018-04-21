//
//  ManageOfferOb.swift
//  RedBill
//
//  Created by Vipul Jikadra on 23/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper

class ManageOfferOb: Mappable
{
    var status: Bool?
    var data: [ManageOfferDataOb]?
    var message: String?
    
    required init?(map: Map)
    {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map) {
        status              <- map["status"]
        data                <- map["data"]
        message             <- map["message"]
    }
}
class ManageOfferObError: Mappable {
    
    var message : String?
    var status : Int?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    // Mappable
    func mapping(map: Map) {
        
        message              <- map["message"]
        status               <- map["status"]
        
    }
}
