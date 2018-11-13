//
//  PostListModel.swift
//  Frinck
//
//  Created by meenakshi on 6/6/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import Foundation
import ObjectMapper

class PostListModel: NSObject, Codable, Mappable {
    
    var brandName: String?
    var brandId: Int?
    var customerName: String?
    var profilePic: String?
    var postedTime: Double?
    var storeId: Int?
    var storeName: String?
    var storeAddress: String?
    var title: String?
    var desc: String?
    var mediaUrl: String?
    var meditaType: String?
    var isReadMore: String?
    var isShowComment: String?
    var storyId: Int?
    var viewCount: Int?
    var CustomerId: Int?
    var IsView: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        brandName <- map["BrandName"]
        brandId <- map["BrandId"]
        customerName <- map["CustomerName"]
        profilePic <- map["ProfilePic"]
        postedTime <- map["PostedTime"]
        storeId <- map["StoreId"]
        storyId <- map["StoryId"]
        viewCount <- map["ViewCount"]
        storeName <- map["StoreName"]
        storeAddress <- map["StoreAddress"]
        title <- map["Title"]
        desc <- map["Description"]
        mediaUrl <- map["MediaUrl"]
        meditaType <- map["MediaType"]
        isReadMore <- map["isReadMore"]
        isShowComment <- map["isShowComment"]
        CustomerId <- map["CustomerId"]
        IsView <- map["IsView"]
    }
    
}
