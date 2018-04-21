//
//  CardOb.swift
//  RedBill
//
//  Created by Vipul Jikadra on 25/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper

class CardOb: Mappable
{
    var status: Bool?
    var data:[CardDataOb]?
    var message:String?
    
    required init?(map: Map)
    {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map)
    {
        status              <- map["status"]
        data                <- map["data"]
        message             <- map["message"]
    }
}
