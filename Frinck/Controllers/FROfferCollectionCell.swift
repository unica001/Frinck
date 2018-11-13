//
//  FROfferCollectionCell.swift
//  Frinck
//
//  Created by vineet patidar on 02/04/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SDWebImage

class FROfferCollectionCell: UICollectionViewCell {
    @IBOutlet var offerImageView: UIImageView!
    @IBOutlet var btnThree: UIButton!
    
    func setOfferData(dictionary : Dictionary<String, Any>){
        btnThree.layer.cornerRadius = btnThree.frame.size.height/2
        btnThree.layer.masksToBounds = true
        let urlString = dictionary["image"] as? String
        let urlStrings = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlStrings!)
        offerImageView.sd_setImage(with:url , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
    }
}
