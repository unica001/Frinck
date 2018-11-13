//
//  FRSignupTableViewCell.swift
//  Frinck
//
//  Created by sirez-ios on 29/03/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class FRSignupTableViewCell: UITableViewCell
{
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var countryCodeLabelWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        //Do reset here
//        contentTextField.text = ""
//        iconImageView.image = nil
//
//        this.iconImageView?.image = nil
//        this.contentTextField?.text = ""
//
//    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
}
