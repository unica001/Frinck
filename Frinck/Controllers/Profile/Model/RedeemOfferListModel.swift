import Foundation
import ObjectMapper

class RedeemOfferListModel: NSObject,Mappable,Codable {
    
    var voucherId: Int?
    var brandName: String?
    var brandLogo: String?
    var price: String?
    var requiredPoint: Int!
    var customerTotalPoint : Int!

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        voucherId <- map[kVoucherId]
        brandName <- map[kBrandName]
        brandLogo <- map [kBrandLogo]
        price <- map [kPrice]
        requiredPoint <- map [kRequiredPoint]
        customerTotalPoint <- map [kCustomerTotalPoint]
    }
}
