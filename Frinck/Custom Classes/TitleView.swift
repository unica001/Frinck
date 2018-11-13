//
//  TitleView.swift
//  Frinck
//
//  Created by vineet patidar on 05/06/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class TitleView: UIView {

    var titleLabel : UILabel!
    var pointLabel : UILabel!
    var LevelLabel : UILabel!

    var logoImageView : UIImageView!
    var sliderImageView : UIImageView!

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Title Lable
        titleLabel = UILabel(frame: CGRect(x:( self.frame.size.width-100)/2, y: 10, width: 100, height: 24))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.font = UIFont(name: kFontTextSemibold, size: 18)
        titleLabel.text = "Check In"
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        
        // Point Lable
        pointLabel = UILabel(frame: CGRect(x:( self.frame.size.width-70), y: 0, width: 40, height: 20))
        pointLabel.backgroundColor = UIColor.clear
        pointLabel.text = "0"
        pointLabel.font = UIFont(name: kFontTextRegular, size: 14)
        pointLabel.textAlignment = .right
        self.addSubview(pointLabel)
        
        // logo Image
        logoImageView = UIImageView(frame: CGRect(x:( self.frame.size.width-90), y: 0, width: 20, height: 20))
        logoImageView.backgroundColor = UIColor.clear
        logoImageView.image = UIImage(named: "web")
        self.addSubview(logoImageView)
        
      //  slider ImageView
        sliderImageView = UIImageView(frame: CGRect(x:( self.frame.size.width-95), y: 25, width: 70, height: 14))
        sliderImageView.backgroundColor = UIColor.clear
        sliderImageView.image = UIImage(named: "slider")
        self.addSubview(sliderImageView)
        
        // Level Label
        LevelLabel = UILabel(frame: CGRect(x:( self.frame.size.width-95)+35, y: 25, width: 35, height: 14))
        LevelLabel.backgroundColor = UIColor.clear
        LevelLabel.text = "Level 0"
        LevelLabel.font = UIFont(name: kFontTextRegular, size: 10)
        LevelLabel.textAlignment = .center
        self.addSubview(LevelLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
    }
    
    func setTitleData(point : String, level : String){
        pointLabel.text = point
        LevelLabel.text = "Level \(level)"
    }

}
