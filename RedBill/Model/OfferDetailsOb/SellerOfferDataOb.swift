//
//  OfferDetailsDataOb.swift
//  RedBill
//
//  Created by Vipul Jikadra on 24/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper
class SellerOfferDataOb: Mappable
{
    var first_name: String?
    var last_name: String?
    var seller_id: String?
    var seller_accept: Bool?
    var seller_cancel: Bool?
    var seller_denny: Bool?
    var master_offer_id: String?

    var offer_data: [OfferDataOb]?

    required init?(map: Map)
    {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map) {
        first_name              <- map["first_name"]
        last_name               <- map["last_name"]
        seller_id               <- map["seller_id"]
        seller_accept           <- map["seller_accept"]
        seller_cancel           <- map["seller_cancel"]
        seller_denny            <- map["seller_denny"]
        master_offer_id         <- map["master_offer_id"]
        offer_data              <- map["offer_data"]
    }
}
