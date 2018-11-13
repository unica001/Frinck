//
//  CellFollow.swift
//  Frinck
//
//  Created by meenakshi on 5/28/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

protocol UserDelegate: class {
    func didActionFollow(sender: UIButton, actionType: ActionType)
}

enum ActionType {
    case threeDot
    case follow
}

class CellFollow: UITableViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnThreeDot: UIButton!
    @IBOutlet weak var btnFollowUnfollow: UIButton!
    weak var delegate : UserDelegate!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width/2
        imgProfile.layer.masksToBounds = true
        btnFollowUnfollow.layer.cornerRadius = btnFollowUnfollow.frame.size.height/2
        btnFollowUnfollow.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(dictInfo : UserListModel, isUserList : Bool? = false) {
        let profileString = dictInfo.imageUrl
        let profileUrlString = profileString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let profileUrl = URL(string: profileUrlString!)
        self.imgProfile.sd_setImage(with:profileUrl , placeholderImage: UIImage(named : "roundPlaceHolder"), options:.cacheMemoryOnly, completed: nil)
        btnFollowUnfollow.isHidden = (isUserList)! ? false : true
        btnThreeDot.isHidden = (isUserList)! ? true : false
        lblUserName.text = dictInfo.CustomerUserName
//        btnFollowUnfollow.isHidden = false
        if dictInfo.isFollow == "follow" {
            btnFollowUnfollow.setTitle("FOLLOWING", for: .normal)
            btnFollowUnfollow.isUserInteractionEnabled = true
            btnFollowUnfollow.setTitleColor(UIColor( red: CGFloat(78.0/255.0), green: CGFloat(78.0/255.0), blue: CGFloat(78.0/255.0), alpha: CGFloat(1.0) ) , for: .normal)
            btnFollowUnfollow.backgroundColor = UIColor( red: CGFloat(236.0/255.0), green: CGFloat(236.0/255.0), blue: CGFloat(236.0/255.0), alpha: CGFloat(1.0) )
        } else {
            btnFollowUnfollow.setTitle("FOLLOW", for: .normal)
            btnFollowUnfollow.isUserInteractionEnabled = true
            btnFollowUnfollow.setTitleColor(UIColor.white , for: .normal)
            btnFollowUnfollow.backgroundColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(17.0/255.0), blue: CGFloat(0.0/255.0), alpha: CGFloat(1.0) )
        }
        
        if dictInfo.isBlock == 1 {
            btnFollowUnfollow.setTitle("UNBLOCK", for: .normal)
            btnFollowUnfollow.isUserInteractionEnabled = true
            btnFollowUnfollow.setTitleColor(UIColor.white , for: .normal)
            btnFollowUnfollow.backgroundColor = UIColor.black
        }
        
    }
    
    //MARK: - IBAction Methods
    
    @IBAction func taapthreedot(_ sender: UIButton) {
        if let safeDelegate = self.delegate {
            safeDelegate.didActionFollow(sender: sender, actionType: .threeDot)
        }
    }
    
    @IBAction func tapFollow(_ sender: UIButton) {
        if let safeDelegate = self.delegate {
            safeDelegate.didActionFollow(sender: sender, actionType: .follow)
        }
    }
}
