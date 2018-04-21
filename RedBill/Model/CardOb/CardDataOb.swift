//
//  CardDataOb.swift
//  RedBill
//
//  Created by Vipul Jikadra on 25/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper

class CardDataOb: Mappable
{
    var user_id: String?
    var card_id: String?
    var card_number: String?
    var cvv: String?
    var expiry_date: String?
    var zip_code: String?
    var is_default: String?
    
    required init?(map: Map)
    {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map)
    {
        user_id                <- map["user_id"]
        card_id                <- map["card_id"]
        card_number            <- map["card_number"]
        cvv                    <- map["cvv"]
        expiry_date            <- map["expiry_date"]
        zip_code               <- map["zip_code"]
        is_default             <- map["is_default"]
    }
}
