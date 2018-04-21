//
//  OfferProductDetailsOb.swift
//  RedBill
//
//  Created by Vipul Jikadra on 24/12/17.
//  Copyright © 2017 Rahul. All rights reserved.
//

import UIKit
import ObjectMapper
class OfferProductDetailsOb: Mappable
{
    var productid: String?
    var title: String?
    var description: String?
    var category_name: String?
    var category_keyword: String?
    var category_id: String?
    var price: String?
    var status: String?
    var created_on: String?
    var images:[String?] = []
    var master_offer_id: String?
    var product_view: String?
    
    required init?(map: Map)
    {
        mapping(map: map)
    }
    
    // Mappable
    func mapping(map: Map)
    {
        productid              <- map["product_id"] //productid
        title                  <- map["title"]
        description            <- map["description"]
        category_name          <- map["category_name"]
        category_keyword       <- map["category_keyword"]
        price                  <- map["price"]
        status                 <- map["status"]
        created_on             <- map["created_on"]
        images                 <- map["images"]
        master_offer_id        <- map["master_offer_id"]
        product_view           <- map["product_view"]
    }

}
