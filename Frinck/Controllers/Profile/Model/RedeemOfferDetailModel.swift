//
//  RedeemOfferDetailModel.swift
//  Frinck
//
//  Created by vineet patidar on 12/07/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import ObjectMapper

class RedeemOfferDetailModel: NSObject,Mappable,Codable {
  
    var offerList : [RedeemOfferListModel]!
    var maxPoint : NSInteger!
    var pointPirceValue : Float!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        offerList <- map[kredeemOffer]
        maxPoint <- map[kmaxPoint]
        pointPirceValue <- map[kpointPirceValue]
    }
}
