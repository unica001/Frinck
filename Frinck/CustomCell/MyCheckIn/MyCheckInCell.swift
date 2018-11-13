//
//  MyCheckInCell.swift
//  Frinck
//
//  Created by vineet patidar on 21/05/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SDWebImage

class MyCheckInCell: UITableViewCell {

    @IBOutlet var storeImage: UIImageView!
    @IBOutlet var storeNameLable: UILabel!
    @IBOutlet var storeDistanceLable: UILabel!
    @IBOutlet var postStoryButton: UIButton!
    @IBOutlet var dateLable: UILabel!
    @IBOutlet var nameLableHeight: NSLayoutConstraint!

    @IBOutlet var expireLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        storeImage.layer.cornerRadius = storeImage.frame.size.width/2
        storeImage.layer.masksToBounds  = true
    }
    
    func setData(dict : [String : Any]){
        
        // Store image
        var urlString = dict[kBrandLogo] as? String
        urlString = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlString!)
        storeImage.sd_setImage(with:url , placeholderImage: UIImage(named : "roundPlaceHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
        
        // Store Image
        storeDistanceLable.text = dict[kStoreDistance] as? String
       dateLable.text = dict[kcheckinDate] as? String
        
        let storeName = dict[kStoreName] as? String
        storeNameLable.text = storeName
//        let height = Float((storeName?.height(withConstrainedWidth: ScreenSize.width - 240, font: UIFont(name: kFontTextRegularBold, size: 13)!))!+5)
//        nameLableHeight.constant = CGFloat(height)
        
        let isExpire : Int = (dict[kIsExpire] as? Int)!

        if  isExpire != 1 {
            postStoryButton.isHidden = false
            expireLable.isHidden = true
        } else {
            postStoryButton.isHidden = true
            expireLable.isHidden = false
            expireLable.text = "Time expired for Posting Story"
        }
        
    
    }

  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
