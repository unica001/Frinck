//
//  CellInfo.swift
//  Frinck
//
//  Created by meenakshi on 5/29/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class CellInfo: UITableViewCell {

    @IBOutlet weak var txtInfo: UITextField!
    @IBOutlet weak var imgInfo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureInfoCell(dict: InfoStruct, isEdit : Bool) {
        imgInfo.image = dict.image
        txtInfo.isUserInteractionEnabled = isEdit
        txtInfo.text = dict.value
        txtInfo.placeholder = dict.placeholder
        if let type = dict.type{
            switch type {
            case ProfileType.name, ProfileType.username :
                txtInfo.keyboardType = .default
            case ProfileType.email:
                txtInfo.keyboardType = .emailAddress
            case ProfileType.phoneNo:
                txtInfo.keyboardType = .phonePad
            default:
                break
            }
        }
        
    }
    
}
