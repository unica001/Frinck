//
//  EarnedCell.swift
//  Frinck
//
//  Created by Meenkashi on 7/31/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class EarnedCell: UITableViewCell {

    @IBOutlet var lblPoints: UILabel!
    @IBOutlet var lblGetPointsBy: UILabel!
    @IBOutlet var lblTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(dict : EarnedPointModel){
        
        lblPoints.text = "Point Received: \(String(describing: dict.Point!))"
        lblGetPointsBy.text = "\(String(describing: dict.PointGetBy!))"
        
        // Purchase date
        
        let date : Date = Date(timeIntervalSince1970:Double( dict.pointGetTime!))
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "dd MMM yyyy"
        lblTime.text = dateFormate.string(from:date)
    }
}
