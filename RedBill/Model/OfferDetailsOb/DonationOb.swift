//
//  DanationOb.swift
//  RedBill
//
//  Created by Rahul on 1/20/18.
//  Copyright © 2018 Rahul. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class DonationOb: Mappable {
    var seller_order_price: Double?
    var order_price: String?
    var order_id: Int?
    var organization_id: Int?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map) {
        seller_order_price           <- map["seller_order_price"]
        order_price                  <- map["order_price"]
        order_id                     <- map["order_id"]
        organization_id              <- map["organization_id"]
    }
}
