//
//  FrStoryDetailViewC.swift
//  Frinck
//
//  Created by Meenkashi on 8/1/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import ObjectMapper
import DZNEmptyDataSet

class FrStoryDetailViewC: UIViewController {

    @IBOutlet var tblStoryDetail: UITableView!
    var postDetail : PostListModel?
    var rowHeight = [Int : CGFloat]()
    var storyId : Int = 0
    var loginInfoDictionary :NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        tblStoryDetail.register(UINib(nibName: "StoryViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callApiStoryDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func tapBack(_ sender: Any) {
        if (self.navigationController?.viewControllers.count)! > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            AppDelegate.delegate.goToHomeScreen()
        }
    }
    
    func callApiStoryDetail() {
        var params: NSMutableDictionary = [:]
        params = [ kCustomerId : loginInfoDictionary[kCustomerId]!,
                kStoryId : storyId]
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kstorydetail))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    self.tblStoryDetail.emptyDataSetDelegate = self
                    self.tblStoryDetail.emptyDataSetSource = self
                    if index == "200" {
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            self.postDetail = Mapper<PostListModel>().map(JSON: payload)
                            self.tblStoryDetail.reloadData()
                        }
                    } else
                    {
                        self.tblStoryDetail.reloadData()
                    }
                }
            }
        }
    }
}

extension FrStoryDetailViewC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (postDetail != nil) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (postDetail != nil) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "cell"
        
        var cell: StoryViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? StoryViewCell
        
        tableView.register(UINib(nibName: "StoryViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        cell = (tableView.dequeueReusableCell(withIdentifier: identifier) as? StoryViewCell)!
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        // Button Action
        cell.commentButton.tag = indexPath.section
        cell.commentButton.addTarget(self, action:  #selector(viewAllcommentAction(_:)), for: .touchUpInside)
        cell.shareButton.addTarget(self, action:  #selector(shareButtonAction(_:)), for: .touchUpInside)
        
//        cell.reloadDelegate = self
        cell.setStoryCellData(dict: &postDetail!, tableView: tblStoryDetail)
        cell.readMoreButton.addTarget(self, action: #selector(readMoreButtonAction(_:)), for: .touchUpInside)
        cell.btnProfile.tag = indexPath.section
        cell.btnProfile.addTarget(self, action: #selector(profileButtonAction(_:)), for: .touchUpInside)
        cell.dotButton.tag = indexPath.section
        cell.dotButton.addTarget(self, action: #selector(dotButtonAction(_:)), for: .touchUpInside)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height : Float = 0.0
        
        // description
        
        let description : String = postDetail!.desc!
        height = Float(description.height(withConstrainedWidth: ScreenSize.width - 40, font: UIFont(name: kFontTextRegular, size: 14)!))
        
        if height > Float(descriptioHeight) && (postDetail?.isReadMore == nil ||  postDetail?.isReadMore == "1") {
            height = Float(descriptioHeight) + 20 // read more button
        }
        
        let locality : String =  postDetail!.storeAddress!
        height = Float(locality.height(withConstrainedWidth: ScreenSize.width - 170, font: UIFont(name: kFontTextRegular, size: 13)!)) + height
        
        if  postDetail?.meditaType == kVideo {
            height = height + Float(imageHeight)
        } else {
            if let ht = self.rowHeight[indexPath.section] {
                height = Float(ht) + height
            } else {
                let cache : SDImageCache = SDImageCache.shared()
                
                let image : UIImage? = cache.imageFromDiskCache(forKey: postDetail?.mediaUrl)
                
                if let image = image {
                    let aspectRatio = (image as UIImage).size.height/(image as UIImage).size.width
                    let imgHeight = self.view.frame.width*aspectRatio
                    self.rowHeight[indexPath.section] = imgHeight
                    height = height + Float(imgHeight)
                } else {
                    height = height + Float(imageHeight)
                }
            }
        }
        
        return CGFloat(storyCellHeight) + CGFloat(height);
    }
    
    // MARK Button Action
    
    @objc  func readMoreButtonAction(_ button : UIButton){
        postDetail?.isReadMore = "0"
        tblStoryDetail.reloadRows(at: [IndexPath(row: 0, section: button.tag)], with: .none)
    }
    
    @objc func shareButtonAction(_ button: UIButton) {
        CommonAction.sharedAction.shareStory(viewC: self, dict: postDetail!)
    }
    
    @objc func viewAllcommentAction(_ button : UIButton){
        // view all comment
        CommonAction.sharedAction.moveToComment(viewC: self, storyId: postDetail!.storyId!)
    }
    
    @objc func profileButtonAction(_ button: UIButton) {
        CommonAction.sharedInst().movetoProfile(viewC: self, dict: postDetail!, logInId: loginInfoDictionary[kCustomerId] as! Int)
    }
    
    @objc func dotButtonAction(_ button : UIButton) {
        CommonAction.sharedAction.storyDotAction(dict: postDetail!, logInId: loginInfoDictionary[kCustomerId] as! Int, viewC: self) { (succes, message, actionType) in
            if succes {
                switch actionType {
                case .Delete, .Hide:
                    self.navigationController?.popViewController(animated: true)
                case .Edit:
                    break
                case .Flag:
                    break
                }
            } else {
                alertController(controller: self, title: "", message:message, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                    
                })
            }
        }
    }
}

extension FrStoryDetailViewC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let txtAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font: UIFont(name: kFontTextSemibold, size: 15.0)! , NSAttributedStringKey.foregroundColor: UIColor.black]
        let placeholderText = NSAttributedString(string: "No story", attributes: txtAttributes)
        return placeholderText
    }

}
