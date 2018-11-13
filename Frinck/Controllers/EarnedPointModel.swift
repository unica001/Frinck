//
//  EarnedPointModel.swift
//  Frinck
//
//  Created by Meenkashi on 7/31/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import ObjectMapper

class EarnedPointModel: NSObject, Mappable, Codable {

    var Id: Int?
    var Point: Int?
    var PointGetBy: String?
    var pointGetTime: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        Id <- map["Id"]
        Point <- map["Point"]
        PointGetBy <- map["PointGetBy"]
        pointGetTime <- map["pointGetTime"]
    }
    
}
