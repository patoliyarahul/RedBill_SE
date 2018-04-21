//
//  BuyerOfferDataOb.swift
//  RedBill
//
//  Created by Vipul Jikadra on 27/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper

class BuyerOfferDataOb: Mappable
{
    var first_name: String?
    var last_name: String?
    var buyer_id: String?
    var buyer_cancel: Bool?
    var buyer_accept: Bool?
    var buyer_denny: Bool?
    
    var offer_data: [OfferDataOb]?
    
    required init?(map: Map)
    {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map) {
        first_name              <- map["first_name"]
        last_name               <- map["last_name"]
        buyer_id                <- map["buyer_id"]
        buyer_cancel            <- map["buyer_cancel"]
        buyer_accept            <- map["buyer_accept"]
        buyer_denny            <- map["buyer_denny"]
        offer_data              <- map["offer_data"]
    }
}
