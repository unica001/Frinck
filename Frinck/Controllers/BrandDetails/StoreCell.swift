//
//  StoreCell.swift
//  Frinck
//
//  Created by vineet patidar on 08/05/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class StoreCell: UITableViewCell {

    @IBOutlet var storeNameLable: UILabel!
      @IBOutlet var storeDistanceLabel: UILabel!
      @IBOutlet var checkInPoinsLable: UILabel!
      @IBOutlet var addressLable: UILabel!
    
    @IBOutlet var storeNameLableHeight: NSLayoutConstraint!
    @IBOutlet var addressLableHeight: NSLayoutConstraint!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func setStoreData (dict : Dictionary<String, Any>){
        
        checkInPoinsLable.text = "Check-in for\n\(dict["StoreCheckInPoint"]!) Points"
        var title : String = dict[kStoreName] as! String
        storeNameLableHeight.constant =  title.height(withConstrainedWidth: ScreenSize.width - 160, font: UIFont(name: kFontTextSemibold, size: 14)!)+5
        storeNameLable.text = title
        
        title = dict[kStoreAddress] as! String
        addressLableHeight.constant =  title.height(withConstrainedWidth: ScreenSize.width - 160, font: UIFont(name: kFontTextRegular, size: 13)!)+5
        addressLable.text = title
        storeDistanceLabel.adjustsFontSizeToFitWidth = true
        storeDistanceLabel.text = "\(String(describing: dict[kStoreDistance]!)) away"
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
