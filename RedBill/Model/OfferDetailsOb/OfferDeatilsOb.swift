//
//  OfferDeatilsOb.swift
//  RedBill
//
//  Created by Vipul Jikadra on 24/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper

class OfferDeatilsOb: Mappable
{
    var status: Bool?
    var product_data: OfferProductDetailsOb?
    var seller_data: [SellerOfferDataOb]?
    var buyer_data: [BuyerOfferDataOb]?
    
    required init?(map: Map)
    {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map)
    {
        status              <- map["status"]
        product_data        <- map["product_data"]
        seller_data         <- map["seller_data"]
        buyer_data          <- map["buyer_data"]
    }
}
