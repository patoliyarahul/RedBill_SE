//
//  DonationDataOb.swift
//  RedBill
//
//  Created by Rahul on 1/20/18.
//  Copyright © 2018 Rahul. All rights reserved.
//

import Foundation
import ObjectMapper

class DonationDataOb: Mappable {
    var status: Bool?
    var order_data: DonationOb?
    var message: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map) {
        status              <- map["status"]
        order_data          <- map["order_data"]
        message             <- map["message"]
    }
}
