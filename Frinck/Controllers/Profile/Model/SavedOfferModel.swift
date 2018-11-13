//
//  SavedOfferModel.swift
//  Frinck
//
//  Created by Meenkashi on 6/25/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import ObjectMapper

class SavedOfferModel: NSObject, Mappable, Codable {

    var offerId: Int?
    var title: String?
    var image: String?
    var validFrom: String?
    var validTo: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        offerId <- map["offerId"]
        title <- map["title"]
        image <- map["image"]
        validFrom <- map["validFrom"]
        validTo <- map["validTo"]
    }
}
