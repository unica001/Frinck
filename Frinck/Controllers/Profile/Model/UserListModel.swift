//
//  UserListModel.swift
//  Frinck
//
//  Created by meenakshi on 6/4/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import Foundation
import ObjectMapper

class UserListModel: NSObject, Codable, Mappable {
    
    var CustomerId: Int?
    var CustomerUserName: String?
    var CustomerName: String?
    var imageUrl: String?
    var isFollow: String?
    var isBlock: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        CustomerId <- map["CustomerId"]
        CustomerUserName <- map["CustomerUserName"]
        CustomerName <- map["CustomerName"]
        imageUrl <- map["imageUrl"]
        isFollow <- map["isFollow"]
        isBlock <- map["isBlock"]
    }
}
