//
//  FRAllViewC.swift
//  Frinck
//
//  Created by Meenkashi on 6/18/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage

class FRAllViewC: UIViewController {
    
    @IBOutlet var tblAllStoreStory: UITableView!
    var strHeader = ""
    var brandId: Int = 0
    var arrStories = [PostListModel]()
    var arrStores = [[String : AnyObject]]()
    var rowHeight = [Int : CGFloat]()
    var commentString = ""
    var pageIndexStories = 1
    var pageIndexStore = 1
    var totalCountStories = 0
    var totalCountStores = 0
    
    //MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = strHeader
        tblAllStoreStory.register(UINib(nibName: "StoreCell", bundle: nil), forCellReuseIdentifier: "storeCell")
        tblAllStoreStory.register(UINib.init(nibName: "StoryViewCell", bundle: nil), forCellReuseIdentifier: "StoryViewCell")
        
        if self.strHeader == "Stores" {
            getStores()
        } else {
            getStoryList()
        }
        // Do any additional setup after loading the view.
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
    
    //MARK: - Selector
    @objc  func readMoreButtonAction(_ button : UIButton){
        let dict = arrStories[button.tag]
        dict.isReadMore = "0"
        arrStories[button.tag] = dict
        tblAllStoreStory.reloadRows(at: [IndexPath(row: 0, section: button.tag)], with: .none)
    }
    
    func reloadCellData(dict: [String : Any]) {
        
    }
    @objc func commentButtonAction(_ button: UIButton) {
        let dict = arrStories[button.tag]
        if  dict.isShowComment == "0"  ||  dict.isShowComment == nil{
            dict.isShowComment = "1"
        } else {
            dict.isShowComment = "0"
        }
        arrStories[button.tag] = dict
        tblAllStoreStory.reloadRows(at: [IndexPath(row: 0, section: button.tag)], with: .none)
    }
    
    @objc func shareButtonAction(_ button: UIButton) {
        CommonAction.sharedInst().shareStory(viewC: self, dict: arrStories[button.tag])
    }
    
    @objc func viewAllcommentAction(_ button : UIButton){
        // view all comment
        CommonAction.sharedInst().moveToComment(viewC: self, storyId: arrStories[button.tag].storyId!)
    }
    
    @objc func profileButtonAction(_ button: UIButton) {
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        CommonAction.sharedInst().movetoProfile(viewC: self, dict: arrStories[button.tag], logInId: loginInfoDictionary[kCustomerId] as! Int)
    }
    
    @objc func dotButtonAction(_ button: UIButton){
        let dict = arrStories[button.tag]
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        CommonAction.sharedAction.storyDotAction(dict: dict, logInId: loginInfoDictionary[kCustomerId] as! Int, viewC: self) { (succes, message, actionType) in
            if succes {
                switch actionType {
                case .Hide:
                    self.arrStories.remove(at: button.tag)
                    self.tblAllStoreStory.reloadData()
                case .Delete:
                    alertController(controller: self, title: "", message: "Your story deleted successfully.", okButtonTitle: "Ok", completionHandler: { (valid) in
                        self.arrStories.remove(at: button.tag)
                        self.tblAllStoreStory.reloadData()
                    })
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
    
    //MARK: - IBAction Methods
    
    @IBAction func tapBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func getStores()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let  lat  = String(appDelegate.lat)
        let  lng  =  String(appDelegate.long)
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            kBrandId : String(brandId),
            kLatitude:  lat,
            kLongitude: lng,
            kpageNo: pageIndexStore
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kbrandStore))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        print(dict)
                        if  let payloadDict =  dict.value(forKey: kPayload) as? [String : Any]
                        {
                            self.totalCountStores = payloadDict["total"] as! Int
                            self.arrStores = payloadDict[kBrandStore]! as! [[String : AnyObject]]
                        }
                        self.tblAllStoreStory.reloadData()
                        
                    }
                    else
                    {
                        let message = dict[kMessage]
                        
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                        })
                        
                    }
                }
            }
        }
    }
    
    func getStoryList()
    {
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            kpageNo : pageIndexStories,
            kBrandId : String(brandId)
        ]
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kbrandstory))!
        
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            self.totalCountStories = payload["total"] as! Int
                            let brandStory = payload["brandStoryList"] as! [[String : Any]]
                            let postList = Mapper<PostListModel>().mapArray(JSONArray: brandStory)
                            if self.pageIndexStories == 1 {
                                self.arrStories = postList
                            } else {
                                self.arrStories.append(contentsOf: postList)
                            }
                            self.tblAllStoreStory.reloadData()
                        }
                    }
                    else
                    {
                        self.tblAllStoreStory.reloadData()
                        //                        let message = dict[kMessage]
                        //
                        //                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                        //
                        //                        })
                        
                    }
                }
            }
        }
    }
    
    func postComment(textField: UITextField)
    {
        let dict = arrStories[textField.tag]
        let storyId : Int = dict.storyId!
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            StoryId : String(storyId),
            kComment : self.commentString
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kcommentpost))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        self.commentString = ""
                    } else {
                        let message = dict[kMessage]
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                        })
                        
                    }
                }
            }
        }
    }
}

extension FRAllViewC: UITableViewDelegate, UITableViewDataSource, delegateReloadCell {
    func reloadCellData(dict: [String : Any], rowHeight: CGFloat, index: Int) {
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (strHeader == "Stores") ? 1 : arrStories.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (strHeader == "Stores") ? arrStores.count : 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (strHeader == "Stores") ? 0.001 : 10.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if strHeader == "Stores" {
            return 0
        }
        let dict = arrStories[section]
        if  dict.isShowComment == "1"  &&  dict.isShowComment != nil{
            return 60
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if strHeader == "Stores" {
            var height : Float = 0.0
            let dict = self.arrStores[indexPath.row]
            var title : String = dict[kStoreName] as! String
            height =  Float(title.height(withConstrainedWidth: ScreenSize.width - 160, font: UIFont(name: kFontTextRegularBold, size: 14)!)+5)
            
            title = dict[kStoreAddress] as! String
            height += Float(title.height(withConstrainedWidth: ScreenSize.width - 160, font: UIFont(name: kFontTextRegular, size: 13)!)+5) + height
            
            if height > 70 {
                return CGFloat(height)
            }
            return 70
        } else {
            var height : Float = 0.0
            let dict = arrStories[indexPath.section]
            
            // description
            
            let description : String = dict.desc!
            height = Float(description.height(withConstrainedWidth: ScreenSize.width - 40, font: UIFont(name: kFontTextRegular, size: 14)!))
            
            if height > Float(descriptioHeight) && (dict.isReadMore == nil ||  dict.isReadMore == "1") {
                height = Float(descriptioHeight) + 20 // read more button
            }
            
            let locality : String =  dict.storeAddress!
            height = Float(locality.height(withConstrainedWidth: ScreenSize.width - 170, font: UIFont(name: kFontTextRegular, size: 13)!)) + height
            
            if  dict.meditaType == kVideo {
                height = height + Float(imageHeight)
            } else {
                if let ht = self.rowHeight[indexPath.section] {
                    height = Float(ht) + height
                } else {
                    let cache : SDImageCache = SDImageCache.shared()
                    
                    let image : UIImage? = cache.imageFromDiskCache(forKey: dict.mediaUrl)
                    
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
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if strHeader == "Stores" {
            return nil
        }
        let dict = arrStories[section]
        if  dict.isShowComment == "1"  &&  dict.isShowComment != nil{
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSize.width - 40, height: 60))
            headerView.backgroundColor = UIColor.clear
            
            let commnetTextField = UITextField(frame: CGRect(x: 10, y: 5, width: ScreenSize.width-60, height: 30))
            commnetTextField.backgroundColor = UIColor.clear
            commnetTextField.font = UIFont(name: kFontTextSemibold, size: 15.0)
            commnetTextField.placeholder = "Write a comment"
            commnetTextField.returnKeyType = .done
            commnetTextField.borderStyle = .roundedRect
            commnetTextField.delegate = self
            commnetTextField.tag = section
            headerView.addSubview(commnetTextField)
            
            let commnetButton = UIButton(frame: CGRect(x: ScreenSize.width-200, y: 40, width: 150, height: 15))
            commnetButton.setTitleColor(.red, for: .normal)
            commnetButton.setTitle("View Comments", for: .normal)
            commnetButton.titleLabel?.font = UIFont(name: kFontTextRegularBold, size: 15.0)
            commnetButton.tag = section
            commnetButton.addTarget(self, action: #selector(viewAllcommentAction(_:)), for: .touchUpInside)
            headerView.addSubview(commnetButton)
            return headerView
        }
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if strHeader == "Stores" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell") as? StoreCell
            cell?.setStoreData(dict: self.arrStores[indexPath.row])
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoryViewCell") as? StoryViewCell
            cell?.selectionStyle = UITableViewCellSelectionStyle.none
            tableView.separatorStyle = .none
            // Button Action
            cell?.commentButton.tag = indexPath.section
            cell?.commentButton.addTarget(self, action:  #selector(commentButtonAction(_:)), for: .touchUpInside)
            cell?.shareButton.addTarget(self, action:  #selector(shareButtonAction(_:)), for: .touchUpInside)
            
            cell?.dotButton.addTarget(self, action: #selector(dotButtonAction(_:)), for: .touchUpInside)
            cell?.reloadDelegate = self
            cell?.setPostInfoWithModel(arrPost: &arrStories, index: indexPath.section, tableView: tblAllStoreStory)
            cell?.readMoreButton.addTarget(self, action: #selector(readMoreButtonAction(_:)), for: .touchUpInside)
            cell?.btnProfile.tag = indexPath.section
            cell?.btnProfile.addTarget(self, action: #selector(profileButtonAction(_:)), for: .touchUpInside)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if strHeader == "Stores" {
            if totalCountStores > arrStores.count {
                if maximumOffset - currentOffset <= -40 && arrStores.count != 0 && arrStores.count%10 == 0 {
                    pageIndexStore = pageIndexStore + 1
                    getStores()
                }
            }
        } else {
            if totalCountStories > arrStories.count {
                if maximumOffset - currentOffset <= -40 && arrStories.count != 0 && arrStories.count%10 == 0 {
                    pageIndexStories = pageIndexStories + 1
                    getStoryList()
                }
            }
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if strHeader != "Stores" {
            let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
            let arrVisibleCell = tblAllStoreStory.indexPathsForVisibleRows
            CommonAction.sharedAction.storyVisible(arrVisible: arrVisibleCell!, storyArray: arrStories, customerId: loginInfoDictionary[kCustomerId]! as! Int)
        }
    }
}

extension FRAllViewC:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.commentString = self.commentString + string
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            self.postComment(textField: textField)
        }
        textField.text = ""
        textField.resignFirstResponder()
        return true
    }
}
