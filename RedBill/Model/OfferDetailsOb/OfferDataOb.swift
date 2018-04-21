//
//  OfferDataOb.swift
//  RedBill
//
//  Created by Vipul Jikadra on 26/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper
class OfferDataOb: Mappable
{
    var type: String?
    var sent_receive: String?
    var activity: String?
    var product_id: String?
    var offer_price: String?
    var offer_type: String?
    var status: String?
    var offer_sent_receive: String?
    var date: String?
    var time: String?
    var text: String?

    
    required init?(map: Map)
    {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map) {
        type                    <- map["type"]
        product_id              <- map["product_id"]
        activity                <- map["activity"]
        sent_receive            <- map["sent_receive"]
        offer_price             <- map["offer_price"]
        offer_type              <- map["offer_type"]
        status                  <- map["status"]
        offer_sent_receive      <- map["offer_sent_receive"]
        date                    <- map["date"]
        time                    <- map["time"]
        text                    <- map["text"]
    }
}
