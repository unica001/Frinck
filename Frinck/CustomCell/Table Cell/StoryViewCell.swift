//
//  StoryViewCell.swift
//  Frinck
//
//  Created by vineet patidar on 02/04/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SDWebImage

let storyCellHeight = 126
var descriptioHeight = 34
let imageHeight = 120

protocol delegateReloadCell {
    func reloadCellData(dict : [String :Any], rowHeight : CGFloat, index: Int)
}
class StoryViewCell: UITableViewCell{
    
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var brnadImageView: UIImageView!
    @IBOutlet var playerView: AGVideoPlayerView!
    @IBOutlet var bgView: UIView!
//    @IBOutlet var bgViewHeight: NSLayoutConstraint!
    @IBOutlet var btnProfile: UIButton!
    @IBOutlet var descriptionLable: UILabel!
    @IBOutlet var storeNameLable: UILabel!
    @IBOutlet var localityLabel: UILabel!
    @IBOutlet var viewCountLable: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var dotButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var readMoreButton: UIButton!
    
    @IBOutlet var descriptionLableHeight: NSLayoutConstraint!
    @IBOutlet var storeNameLableHeight: NSLayoutConstraint!
    @IBOutlet var localityLableHeight: NSLayoutConstraint!
    @IBOutlet var readMoreButtonHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var cnstImageHt: NSLayoutConstraint!
    
    var reloadDelegate : delegateReloadCell!
    
    var selectedIndex = 0
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setStoryCellData(dict : inout PostListModel, tableView: UITableView){
        let sdCache = SDImageCache.shared()
        
//        selectedIndex = index
//        readMoreButton.tag = index
        
        var height : Float = 0.0
        var totalHeight : Float = 0.0
        // check media type
        if  dict.meditaType ?? "" == kVideo {
            self.playerView.isHidden = false
            self.brnadImageView.isHidden = true
            let urlString = dict.mediaUrl ?? ""
            let urlStrings = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            DispatchQueue.global(qos: .background).async {
                self.playerView.videoUrl = URL(string: urlStrings!)
                self.playerView.previewImageUrl =  URL(string: urlStrings!)
                self.playerView.shouldAutoplay = false
                self.playerView.shouldAutoRepeat = false
                self.playerView.showsCustomControls = true
                self.playerView.shouldSwitchToFullscreen = true
                
            }
        } else {
            // Brand Image
            self.playerView.isHidden = true
            self.brnadImageView.isHidden = false
            let urlString = dict.mediaUrl ?? ""
            
            if let urlString = urlString as? String {
                if (sdCache.imageFromCache(forKey: urlString) != nil) {
                    self.brnadImageView.sd_setImage(with: URL(string: urlString), completed: nil)
                } else {
                    self.brnadImageView.sd_setImage(with: URL(string: urlString), completed: { (image, err, cacheType, url) in
                        if err == nil {
                            
                        } else {
                            self.brnadImageView.image = UIImage(named : "placeHolder")
                        }
                    })
                }
            }
        }
        
        // profile image
        let profileString = dict.profilePic ?? ""
        let profileUrlString = profileString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let profileUrl = URL(string: profileUrlString!)
        self.profileImage.sd_setImage(with:profileUrl , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
        
        // Stories write time
        //        self.timeLabel.text = dict.postedTime ?? ""
        
        // description
        let description : String = dict.desc ?? ""
        descriptionLable.text = description
        
        // read more button  hide/show
        if descriptionLable.calculateMaxLines() > 2 && ( dict.isReadMore == nil ||  dict.isReadMore == "1") {
            height = Float(descriptioHeight)
            totalHeight = height
            readMoreButton.isHidden = false
            dict.isReadMore = "1"
            self.readMoreButtonHeight.constant = 20
            self.descriptionLableHeight.constant = CGFloat(descriptioHeight)
            self.updateConstraintsIfNeeded()
        } else {
            height = Float(description.height(withConstrainedWidth: ScreenSize.width - 40, font: UIFont(name: kFontTextRegular, size: 14)!))
            totalHeight = height
            readMoreButton.isHidden = true
            dict.isReadMore = "0"
            totalHeight = totalHeight - 20
            self.readMoreButtonHeight.constant = 0
            self.descriptionLableHeight.constant = CGFloat(height)
            self.updateConstraintsIfNeeded()
        }
        // user Name
        self.nameLabel.text = dict.customerName ?? ""
        // store name
        self.storeNameLable.text = dict.storeName ?? ""
        //Time
        if let time = dict.postedTime as? Double {
            print(dict.postedTime!)
            let strDate = Utility.sharedInstance.getDateFromTimeStamp(timeStamp: dict.postedTime!)
            self.timeLabel.text = Utility.sharedInstance.relativePast(for: strDate)
        }
        
        //ViewCount
        self.viewCountLable.text = "\(String(describing: dict.viewCount!))"
        // locality
        height = 0.0
        let locality : String =  dict.storeAddress ?? ""
        height = Float(locality.height(withConstrainedWidth: ScreenSize.width - 170, font: UIFont(name: kFontTextRegular, size: 13)!)) + height
        localityLableHeight.constant = CGFloat(height)
        totalHeight = height + totalHeight
        self.localityLabel.text = locality
    }
    
    
    func setPostInfoWithModel(arrPost: inout [PostListModel], index : NSInteger, tableView: UITableView) {
        let dict = arrPost[index]
        let sdCache = SDImageCache.shared()
        
        selectedIndex = index
        readMoreButton.tag = index
        
        var height : Float = 0.0
        var totalHeight : Float = 0.0
        // check media type
        if  dict.meditaType ?? "" == kVideo {
            self.playerView.isHidden = false
            self.brnadImageView.isHidden = true
            let urlString = dict.mediaUrl ?? ""
            let urlStrings = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
            DispatchQueue.global(qos: .background).async {
                self.playerView.videoUrl = URL(string: urlStrings!)
//                self.playerView.previewImageUrl =  URL(string: urlStrings!)
                self.playerView.shouldAutoplay = false
                self.playerView.shouldAutoRepeat = false
                self.playerView.showsCustomControls = true
                self.playerView.shouldSwitchToFullscreen = true
            }
        } else {
            // Brand Image
            self.playerView.isHidden = true
            self.brnadImageView.isHidden = false
            let urlString = dict.mediaUrl ?? ""
            
            if let urlString = urlString as? String {
                if (sdCache.imageFromCache(forKey: urlString) != nil) {
                    self.brnadImageView.sd_setImage(with: URL(string: urlString), completed: nil)
                } else {
                    self.brnadImageView.sd_setImage(with: URL(string: urlString), completed: { (image, err, cacheType, url) in
                        if err == nil {
                            
                        } else {
                            self.brnadImageView.image = UIImage(named : "placeHolder")
                        }
                    })
                }
            }
        }
        
        // profile image
        let profileString = dict.profilePic ?? ""
        let profileUrlString = profileString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let profileUrl = URL(string: profileUrlString!)
        self.profileImage.sd_setImage(with:profileUrl , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
        
        // description
        let description : String = dict.desc ?? ""
        descriptionLable.text = description
        
        // read more button  hide/show
        if descriptionLable.calculateMaxLines() > 2 && (dict.isReadMore == nil ||  dict.isReadMore == "1") {
            height = Float(descriptioHeight)
            totalHeight = height
            readMoreButton.isHidden = false
            dict.isReadMore = "1"
            self.readMoreButtonHeight.constant = 20
            self.descriptionLableHeight.constant = CGFloat(descriptioHeight)
            self.updateConstraintsIfNeeded()
        } else {
            height = Float(description.height(withConstrainedWidth: ScreenSize.width - 40, font: UIFont(name: kFontTextRegular, size: 14)!))
            totalHeight = height
            readMoreButton.isHidden = true
            dict.isReadMore = "0"
            totalHeight = totalHeight - 20
            self.readMoreButtonHeight.constant = 0
            self.descriptionLableHeight.constant = CGFloat(height)
            self.updateConstraintsIfNeeded()
        }
        // user Name
        self.nameLabel.text = dict.customerName ?? ""
        // store name
        self.storeNameLable.text = dict.storeName ?? ""
        //Time
        let strDate = Utility.sharedInstance.getDateFromTimeStamp(timeStamp: dict.postedTime!)
        self.timeLabel.text = Utility.sharedInstance.relativePast(for: strDate)
        //ViewCount
        self.viewCountLable.text = "\(String(describing: dict.viewCount!))"
        // locality
        height = 0.0
        let locality : String =  dict.storeAddress ?? ""
        height = Float(locality.height(withConstrainedWidth: ScreenSize.width - 170, font: UIFont(name: kFontTextRegular, size: 13)!)) + height
        localityLableHeight.constant = CGFloat(height)
        totalHeight = height + totalHeight
        self.localityLabel.text = locality
    }
}

extension UILabel {
    
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let lines = Int(textSize.height/charSize)
        return lines
    }
    
}
