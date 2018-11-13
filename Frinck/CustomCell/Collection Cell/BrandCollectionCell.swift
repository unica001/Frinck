//
//  BrandCollectionCell.swift
//  Frinck
//
//  Created by vineet patidar on 02/04/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SDWebImage
class BrandCollectionCell: UICollectionViewCell {
    @IBOutlet var brandImageView: UIImageView!
    @IBOutlet var favouriteButton: UIButton!
    
    func setInitialData(dictionary : Dictionary<String, Any>){
        
        let urlString = dictionary[kBrandLogo] as? String
        let url = URL(string: urlString!)
        brandImageView.sd_setImage(with:url , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)

    }
    
    
}
