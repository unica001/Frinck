//
//  FROfferDetailedTableViewCell.swift
//  Frinck
//
//  Created by sirez-ios on 09/04/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class FROfferDetailedTableViewCell: UITableViewCell {
    @IBOutlet var logoImage: UIImageView!
    
    @IBOutlet var subTitleHeight: NSLayoutConstraint!
    @IBOutlet var subTitleLable: UILabel!
    @IBOutlet var headerLableHeight: NSLayoutConstraint!
    @IBOutlet var headerLable: UILabel!
    @IBOutlet var headerLableTop: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // online
    func setOnlineData(dict: [String : Any], index : NSInteger){
        
        if dict.count == 0 {
            return
        }
        
        if let title = dict["onlineUrl"] as? String {
            subTitleHeight.constant =  title.height(withConstrainedWidth: ScreenSize.width - 70, font: UIFont(name: kFontTextRegular, size: 14)!)
            subTitleLable.text = title
        }
        headerLable.text = dict[kOfferType] as? String
        
        logoImage.image = UIImage(named: "offline")
        subTitleLable.textColor = kRedColor
        
      /*  if  index == 0 {
            headerLable.text = "Expires on"
            if let strdate = dict["validTo"] as? String {
                print(strdate)
                subTitleLable.text = convetDateIntoString(date: (dict["validTo"] as! String))
            }
            logoImage.image = UIImage(named: "time")
        }
        else if  index == 1 {
            
            if let title = dict["onlineUrl"] as? String {
            subTitleHeight.constant =  title.height(withConstrainedWidth: ScreenSize.width - 70, font: UIFont(name: "SFUIText-Regular", size: 14)!)
                subTitleLable.text = title
            }
            headerLable.text = dict[kOfferType] as? String
            
            logoImage.image = UIImage(named: "offline")
            subTitleLable.textColor = kRedColor
        }
        else if  index == 2 {
            
            let title = dict["description"] as? String
            
            headerLable.isHidden = true
            subTitleLable.text =  title
            logoImage.image = UIImage(named: "text")
            headerLableHeight.constant = 0
            subTitleHeight.constant =  title!.height(withConstrainedWidth: ScreenSize.width - 70, font: UIFont(name: "SFUIText-Regular", size: 14)!)
        }*/
        
    }
    
    // offline
    
    func setOfflineData(dict: [String : Any], index : NSInteger){
        
        if dict.count == 0 {
            return
        }
        if  index == 0 {
            headerLable.text = "Expires on"
            if let strdate = dict["validTo"] as? String {
                print(strdate)
            } else if let date = dict["validTo"] as? Date {
                print(date)
            }
            subTitleLable.text = convetDateIntoString(date: (dict["validTo"] as? String)!)
            
            logoImage.image = UIImage(named: "time")
        }
        else if  index == 1 {
    
            headerLable.text = "Offline"
            subTitleLable.text = ""
            headerLableTop.constant = 15
            logoImage.image = UIImage(named: "offline")
        }
        else if  index == 2 {
            
            let title = dict["description"] as? String ?? ""
            if title != "" {
                headerLable.isHidden = true
                subTitleLable.text =  title
                logoImage.image = UIImage(named: "text")
                headerLableHeight.constant = 0
                subTitleHeight.constant =  title.height(withConstrainedWidth: ScreenSize.width - 70, font: UIFont(name: kFontTextRegular, size: 14)!)
            } else {
                headerLable.text =  dict["offerOnStore"] as? String
                subTitleLable.text =  ""
                logoImage.image = UIImage(named: "Allstore")
                headerLableTop.constant = 40
            }    
        }
        else if  index == 3 {
            headerLable.text =  dict["offerOnStore"] as? String
            subTitleLable.text =  ""
            logoImage.image = UIImage(named: "Allstore")            
            headerLableTop.constant = 15
        }
    }
}
