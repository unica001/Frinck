//
//  MyTransactionListModel.swift
//  Frinck
//
//  Created by vineet patidar on 13/07/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import ObjectMapper

class MyTransactionListModel: NSObject,Mappable,Codable {
   
    var transactionID : String!
    var price : String!
    var pointUsed : Int?
    var amountPaid : String!
    var purchaseTime : NSInteger!
    var  brandLogo : String!
    
    required init?(map: Map) {
        
    }
    
     func mapping(map: Map) {
        
        transactionID <- map[kTransactionId]
        price <- map [kPrice]
        pointUsed <- map["PointUsed"]
        amountPaid <- map[kPaidAmount]
        purchaseTime <- map[kPurchasedTime]
        brandLogo <- map[kBrandLogo]
    }
    

}
