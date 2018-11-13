//
//  CellGender.swift
//  Frinck
//
//  Created by meenakshi on 5/29/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class CellGender: UITableViewCell {

    @IBOutlet weak var btnGender: UIButton!
    @IBOutlet weak var lblGender: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureGenderCell(dict: InfoStruct, isEdit: Bool) {
        btnGender.isHidden = !isEdit
        lblGender.text = dict.value
    }
    
}
