//
//  MyProductOb.swift
//  RedBill
//
//  Created by Vipul Jikadra on 26/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper

class MyProductOb: Mappable
{
    var status: Bool?
    var sell_product:[OfferProductDetailsOb]?
    var buy_product:[OfferProductDetailsOb]?
    
    required init?(map: Map)
    {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map)
    {
        status              <- map["status"]
        sell_product        <- map["sell_product"]
        buy_product         <- map["buy_product"]
    }
}

