//
//  DonationWithProductData.swift
//  RedBill
//
//  Created by Rahul on 1/20/18.
//  Copyright © 2018 Rahul. All rights reserved.
//

import Foundation
import ObjectMapper

class DonationWithProductData: Mappable {
    var status: Bool?
    var data: [DonationWithProductOb]?
    var message: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map) {
        status              <- map["status"]
        data                <- map["data"]
        message             <- map["message"]
    }
}
