//
//  FRFavouriteBrandsCollectionViewCell.swift
//  Frinck
//
//  Created by sirez-ios on 26/04/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SDWebImage

class FRFavouriteBrandsCollectionViewCell: UICollectionViewCell
{
    @IBOutlet var brandImageView: UIImageView!
    @IBOutlet var favouriteButton: UIButton!
    
    func setFavouritBrandData(dictionary : Dictionary<String, Any>)
    {
        
        var urlString = dictionary[kBrandLogo] as? String
        urlString = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlString!)

        brandImageView.sd_setImage(with:url , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
    }
}
