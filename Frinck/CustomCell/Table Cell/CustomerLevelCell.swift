//
//  CustomerLevelCell.swift
//  Frinck
//
//  Created by Meenkashi on 6/19/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class CustomerLevelCell: UITableViewCell {

    @IBOutlet var imgLevel: UIImageView!
    @IBOutlet var lblLevel: UILabel!
    @IBOutlet var lblPoints: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
