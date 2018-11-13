//
//  FRCommentTableViewCell.swift
//  Frinck
//
//  Created by sirez-ios on 05/04/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SDWebImage

class FRCommentTableViewCell: UITableViewCell {

    @IBOutlet var nameLable: UILabel!
    @IBOutlet var commentLable: UILabel!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var dateLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.layer.cornerRadius = userImage.frame.size.width/2
        userImage.layer.masksToBounds = true
    }

    func setData(dict : [String : Any]){
        
        // Store image
        var urlString = dict["ProfilePic"] as? String
        urlString = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlString!)
        userImage.sd_setImage(with:url , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
        
        let customerName = dict[kCustomerName] as? String
        nameLable.text = customerName
        
        let strDate = Utility.sharedInstance.getDateFromTimeStamp(timeStamp:  dict[kPostedTime] as! Double)
        self.dateLable.text = Utility.sharedInstance.relativePast(for: strDate)
        
        self.commentLable.text  = dict[kComment] as? String
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
