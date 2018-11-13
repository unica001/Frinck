//
//  TransactionCell.swift
//  Frinck
//
//  Created by Meenkashi on 6/18/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet var lblTransactionId: UILabel!
    @IBOutlet var imgBrnad: UIImageView!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblPointsUsed: UILabel!
    @IBOutlet var lblAmount: UILabel!
    @IBOutlet var lblDate: UILabel!
    
    //MARK: - view Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setMyTransactionData(dict : MyTransactionListModel){
        
        lblTransactionId.text = "Transaction : \(String(dict.transactionID))"
        lblPrice.text = "Price : \(String(dict.price))"
        lblPointsUsed.text = "Point Used : \(dict.pointUsed!)"
        lblAmount.text = "Amount Paid : \(String(dict.amountPaid))"
        
        // Purchase date
        
        let date : Date = Date(timeIntervalSince1970:Double( dict.purchaseTime))
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "dd MMM yyyy"
        lblDate.text = dateFormate.string(from:date)
        
        // profile
        let profileString = dict.brandLogo
        let profileUrlString = profileString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let profileUrl = URL(string: profileUrlString!)
        imgBrnad.sd_setImage(with:profileUrl , placeholderImage: UIImage(named : "placeHolder"), options:.cacheMemoryOnly, completed: nil)

    }
}
