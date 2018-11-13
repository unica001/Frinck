//
//  RedeemOfferCell.swift
//  Frinck
//
//  Created by vineet patidar on 18/06/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SDWebImage

class RedeemOfferCell: UICollectionViewCell {
    @IBOutlet var offerImageView: UIImageView!
    @IBOutlet var expireLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    func setOfferData(dictionary : RedeemOfferListModel){
        
        expireLabel.text = "Required Points \(String(dictionary.requiredPoint))"
        priceLabel.text =   "Rs. " +  dictionary.price!

        
        // set image
        let urlString = dictionary.brandLogo
        let urlStrings = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
       let url = URL(string: urlStrings!)
        offerImageView.sd_setImage(with:url , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
    }
}

