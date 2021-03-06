//
//  CellOffer.swift
//  Frinck
//
//  Created by meenakshi on 6/6/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SDWebImage

class CellOffer: UICollectionViewCell {

    @IBOutlet weak var imgOffer: UIImageView!
    @IBOutlet weak var lblExpire: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    
    @IBOutlet var lblOffer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setOfferData(dictInfo: SavedOfferModel) {
        let urlStrings = dictInfo.image?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlStrings!)
        imgOffer.sd_setImage(with:url , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
        lblOffer.text = dictInfo.title
        
        // Expire date
        
//        let dateFormate1 = DateFormatter()
//        dateFormate1.dateFormat = "yyyy-dd-mm"
//
//        let dateString : String = (dictInfo.validFrom)!
//        
//        let date  =  dateFormate1.date(from: dateString)!
//        
//        let dateFormate = DateFormatter()
//        dateFormate.dateFormat = "dd MMM yyyy"
        lblExpire.text =  dictInfo.validFrom
    }
    
}
