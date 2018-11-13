//
//  MoreCollectionViewCell.swift
//  Frinck
//
//  Created by vineet patidar on 05/06/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class MoreCollectionViewCell: UICollectionViewCell {
  
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var moreLabel: UILabel!
   
    func setInitialData(dictionary : Dictionary<String, Any>, isMoreView : Bool){
        
        if isMoreView == true {
            // make Roundup image
            self.imageview.layer.cornerRadius = self.imageview.frame.size.width/2
            self.imageview.layer.masksToBounds = true
        }
 
        self.imageview.image = dictionary["moreImage"] as? UIImage
        self.moreLabel.text = dictionary["moreText"] as? String
        
    }
}
