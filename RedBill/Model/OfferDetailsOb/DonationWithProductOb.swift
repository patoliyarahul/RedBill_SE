//
//  DonationWithProduct.swift
//  RedBill
//
//  Created by Rahul on 1/20/18.
//  Copyright © 2018 Rahul. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class DonationWithProductOb: Mappable {
    var buyer_id: String?
    var buyer_name: String?
    var order_id: String?
    var order_price: String?
    var organization_id: String?
    var organization_name: String?
    var product_id: String?
    var product_title: String?
    var seller_id: String?
    var seller_name: String?
    var seller_order_price: String?

    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map) {
        buyer_id                     <- map["buyer_id"]
        buyer_name                   <- map["buyer_name"]
        order_id                     <- map["order_id"]
        order_price                  <- map["order_price"]
        organization_id              <- map["organization_id"]
        organization_name            <- map["organization_name"]
        product_id                   <- map["product_id"]
        product_title                <- map["product_title"]
        seller_id                    <- map["seller_id"]
        seller_name                  <- map["seller_name"]
        seller_order_price                  <- map["seller_order_price"]
    }
}
