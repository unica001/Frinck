//
//  CheckInCell.swift
//  Frinck
//
//  Created by vineet patidar on 17/05/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SDWebImage

class CheckInCell: UITableViewCell {

    @IBOutlet var storeImage: UIImageView!
    @IBOutlet var storeNameLable: UILabel!
    @IBOutlet var storeDistanceLable: UILabel!
    @IBOutlet var pointImage: UIImageView!
    @IBOutlet var checkInPointsLable: UILabel!
    @IBOutlet var nameLableHeight: NSLayoutConstraint!
    @IBOutlet var pointsLable: UILabel!
    @IBOutlet var viewPoints: UIView!
    
    @IBOutlet var lblViewExtraPoints: UILabel!
    @IBOutlet var lblViewPoints: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        storeImage.layer.cornerRadius = storeImage.frame.size.width/2
        storeImage.layer.masksToBounds  = true
        
        pointImage.layer.cornerRadius = pointImage.frame.size.width/2
        pointImage.layer.masksToBounds  = true
        
        pointsLable.layer.cornerRadius = pointsLable.frame.size.width/2
        pointsLable.layer.masksToBounds  = true
        
        lblViewPoints.layer.cornerRadius = lblViewPoints.frame.size.width/2
        lblViewPoints.layer.masksToBounds  = true
        
        lblViewExtraPoints.layer.cornerRadius = lblViewExtraPoints.frame.size.width/2
        lblViewExtraPoints.layer.masksToBounds  = true
    }
    
    func setData(dict : [String : Any]){
        // Store image
        var urlString = dict[kBrandLogo] as? String
        urlString = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlString!)
       storeImage.sd_setImage(with:url , placeholderImage: UIImage(named : "roundPlaceHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
      
        // Store Image
        
        let points : Int = dict["StoreCheckInPoint"] as? Int ?? 0
        let isCheckIn : Int = (dict[kIsCheckIn] as? Int)!
        let extraPoints = (dict["StoreCheckInExtraPoint"] as? Int)!

        let storeName = dict[kStoreName] as? String
        storeNameLable.text = storeName
        storeDistanceLable.text = (dict[kStoreDistance] as? String)! + " away"
        checkInPointsLable.adjustsFontSizeToFitWidth = true
        if  String(isCheckIn) == "1" {
            checkInPointsLable.text = "Checked-in for\n \( points) points"
            pointsLable.isHidden = true
            viewPoints.isHidden = true
            pointImage.image = UIImage(named: "checking")
        } else {
            checkInPointsLable.text = "Check-in for\n \( points) points"
            if extraPoints == 0 {
                pointsLable.isHidden = false
                pointsLable.text = "\(points)"
                viewPoints.isHidden = true
            } else {
                pointsLable.isHidden = true
                viewPoints.isHidden = false
                lblViewPoints.text = "\(points)"
                lblViewExtraPoints.text = String(extraPoints)
            }
            
            pointImage.image = UIImage(named: "")
        }
        
        let height = Float((storeName?.height(withConstrainedWidth: ScreenSize.width - 147, font: UIFont(name: kFontTextRegularBold, size: 13)!))!+5)
        nameLableHeight.constant = CGFloat(height)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
