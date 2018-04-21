//
//  ManageOfferDataOb.swift
//  RedBill
//
//  Created by Vipul Jikadra on 23/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper

class ManageOfferDataOb: Mappable
{
    var offer_type: String?
    var message: String?
    var product_title: String?
    var product_id : String?
    var offer_id : String?
    var buyer_id : String?
    var seller_id : String?
    var master_offer_id : String?
    var offer_status : String?

    required convenience init?(map: Map)
    {
       self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        offer_type                    <- map["offer_type"]
        message                       <- map["message"]
        product_title                 <- map["product_title"]
        product_id                    <- map["product_id"]
        offer_id                      <- map["offer_id"]
        buyer_id                      <- map["buyer_id"]
        seller_id                     <- map["seller_id"]
        master_offer_id               <- map["master_offer_id"]
        offer_status                  <- map["offer_status"]
    }
}
