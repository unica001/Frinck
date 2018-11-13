//
//  CellHowItWorks.swift
//  Frinck
//
//  Created by Meenkashi on 9/5/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class CellHowItWorks: UICollectionViewCell {
    @IBOutlet var lblViewHead: UILabel!
    @IBOutlet var lblHead: UILabel!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var imgWork: UIImageView!
    @IBOutlet var lblViewDesc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(dict : [String  : Any]) {
        lblViewHead.text = dict["viewHead"] as? String
        lblViewDesc.text = dict["viewDesc"] as? String
        imgWork.image = UIImage(named: dict["image"] as! String)
    }
    
}
