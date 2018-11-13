//
//  MyPurchaseOfferCell.swift
//  Frinck
//
//  Created by Meenkashi on 7/30/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SDWebImage

class MyPurchaseOfferCell: UICollectionViewCell {
    
    @IBOutlet var lblRupees: UILabel!
    @IBOutlet var lblQuantity: UILabel!
    @IBOutlet var imgOffer: UIImageView!
    
    func setOfferData(dict : [String : Any]){
        // set image
        let urlString = dict["BrandLogo"] as! String
        let urlStrings = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlStrings!)
        imgOffer.sd_setImage(with:url , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
        
        lblQuantity.text = "Qty \(String(describing: dict["Qty"]!))"
        lblRupees.text = "Rs. \(dict["Price"]!)"
    }
}
