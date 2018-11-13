//
//  CheckInStatusCell.swift
//  Frinck
//
//  Created by vineet patidar on 22/05/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class CheckInStatusCell: UITableViewCell {
    @IBOutlet var checkMarkImage: UIImageView!
    @IBOutlet var textLable: UILabel!
    @IBOutlet var timeLable: UILabel!
    @IBOutlet var clockImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
