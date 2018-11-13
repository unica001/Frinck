//
//  CustomAlert.swift
//  Frinck
//
//  Created by meenakshi on 5/28/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SDWebImage

enum CustomAlertType: Int {
    case TwoButton = 0
    case DailyCheckInSuccess
    case Congrats
}

enum DetailType {
    case select
    case ok
    case dailyCheckIn
    case success
    case checkInAt
}

class CustomAlert: UIView {
    
    @IBOutlet var imgBackground: UIImageView!
    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var cnstCenterYes: NSLayoutConstraint!
    
    @IBOutlet var imgSuccess: UIImageView!
    @IBOutlet var lblHead: UILabel!
    @IBOutlet var lblPoints: UILabel!
    @IBOutlet var lblDesc: UILabel!
    
    @IBOutlet var lblHeadComplete: UILabel!
    @IBOutlet var lblDescComplete: UILabel!
    @IBOutlet var btnOk: UIButton!
    
    var handler : ((Bool) -> Void)!
    
    
    /*
     // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    func loadView(customType: CustomAlertType,strMsg : String = "", type: DetailType, url: String = "", checkInpoints: String = "", image: UIImage, eventHandler: ((Bool) -> Void)?) {
        let arrAllView = Bundle.main.loadNibNamed("CustomAlert", owner: self, options: nil)
        
        let alertView = arrAllView![customType.rawValue] as! UIView
        alertView.frame = self.bounds
        addSubview(alertView)

        viewAlert.layer.cornerRadius = 4
        viewAlert.layer.masksToBounds = true
        imgBackground.layer.cornerRadius = 10
        imgBackground.layer.masksToBounds = false
        
        switch customType {
        case .TwoButton :
            lblAlert.text = strMsg
            btnYes.layer.cornerRadius = btnYes.frame.size.height/2
            btnYes.layer.masksToBounds = true
            btnNo.layer.cornerRadius = btnNo.frame.size.height/2
            btnNo.layer.masksToBounds = true
            img.layer.cornerRadius = img.frame.size.height/2
            img.layer.masksToBounds = true
            if url == "" {
                img.image = image
            } else {
                img.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "roundPlaceHolder"), options: .cacheMemoryOnly, completed: nil)
            }
            btnNo.isHidden = (type == .ok || type == .checkInAt) ? true : false
            btnClose.isHidden = (type == .select) ? false : true
            cnstCenterYes.constant = (type == .select) ? -67.5 : 0
            btnYes.setTitle((type == .select) ? "YES" : "OK", for: .normal)
            btnYes.isHidden = (type == .checkInAt) ? true : false
        case .DailyCheckInSuccess:
            lblPoints.layer.cornerRadius = lblPoints.frame.size.height/2
            lblPoints.layer.masksToBounds = true
            lblPoints.text = checkInpoints
            lblDesc.text = strMsg
            lblHead.text = (type == .dailyCheckIn) ? "Daily Check-in" : "Success"
            lblHead.textColor = (type == .dailyCheckIn) ? .black : .red
            imgSuccess.image = image
        case .Congrats:
            btnOk.layer.cornerRadius = btnOk.frame.size.height/2
            btnOk.layer.masksToBounds = true
            
        default:
            break
        }
        
        
        handler = eventHandler
    }
    
    func callHandler(success: Bool) {
        if self.handler != nil {
            self.handler(success)
        }
    }
    
    //MARK: - IBAction Method
    
    @IBAction func tapClose(_ sender: UIButton) {
        callHandler(success: false)
    }
    
    @IBAction func tapYes(_ sender: UIButton) {
        callHandler(success: true)
    }
    
    @IBAction func tapNo(_ sender: UIButton) {
        callHandler(success: false)
    }
    
}
