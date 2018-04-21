//
//  ProductHistory.swift
//  RedBill
//
//  Created by Rahul on 1/20/18.
//  Copyright © 2018 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper
class ProductHistory: Mappable {
    var product_id: String?
    var title: String?
    var order_id: String?
    var order_price: String?
    var seller_order_price: String?
    var organiz_donation: String?
    var created_on: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map) {
        product_id               <- map["product_id"]
        title                    <- map["title"]
        order_id                 <- map["order_id"]
        order_price              <- map["order_price"]
        seller_order_price       <- map["seller_order_price"]
        organiz_donation         <- map["organiz_donation"]
        created_on               <- map["created_on"]
    }
}

