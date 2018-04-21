//
//  ProductHistoryDataOb.swift
//  RedBill
//
//  Created by Rahul on 1/20/18.
//  Copyright © 2018 Rahul. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class ProductHistoryDataOb: Mappable {
    var status: Bool?
    var sell_product:[ProductHistory]?
    var buy_product:[ProductHistory]?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map) {
        status              <- map["status"]
        sell_product        <- map["sell_product"]
        buy_product         <- map["buy_product"]
    }
}
