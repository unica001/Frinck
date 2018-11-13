

import UIKit
import AVKit
import AVFoundation
import SDWebImage
import ObjectMapper

class FRBrandDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,delegateReloadCell {
  
    var brandDictionary = [String : Any]()
    var isCommentClicked : Bool = false
    @IBOutlet weak var favBrandButton: UIBarButtonItem!
    var loginInfoDictionary :NSMutableDictionary!
    var brandStoreArray = [[String:Any]]()
    var brandOfferArray = [[String:Any]]()
    var brandStoriesArray = [PostListModel]()
    var brandInfo = [String:Any]()
    var totalStoreCount = 0
    var totalStoryCount = 0
    var rowHeight = [Int : CGFloat]()
    var brandStorieIndex = 2
    var commentString = ""

    @IBOutlet var brandDetailTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
          brandDetailTable.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getBrandDetails()
    }
    
    @IBAction func tapFav(_ sender: UIBarButtonItem) {
        if let fav = brandInfo[kisFavourite] as? Int {
            brandInfo[kisFavourite] = (fav == 1) ? false : true
        }
        var params: NSMutableDictionary = [:]
        
        guard let data = try? JSONSerialization.data(withJSONObject: [brandInfo], options: []) else {
            return
        }
        let favBrandList =  String(data: data, encoding: String.Encoding.utf8)
        
        params = [ kCustomerId: loginInfoDictionary[kCustomerId]!,
                   kBrandList : favBrandList!]
        
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kBrandFavourite))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200"
                    {
                        _ = self.navigationController?.popViewController(animated: true)
                    } else {
                        let message = dict[kMessage]
                        
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                        })
                        
                    }
                }
            }
        }
    }
    
    //MARK : Table Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if brandStoriesArray.count > 5 {
            return 7

        }
        return 2 + brandStoriesArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if self.brandStoreArray.count > 5 {
                return 5
            }
            return self.brandStoreArray.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section < 3 {
        let headerView = UIView(frame: CGRect(x: 10, y: 0, width: ScreenSize.width - 20, height: 60))
        headerView.backgroundColor = UIColor.white
        
        // Header Lable
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 5, width: ScreenSize.width-150, height: 30))
        headerLabel.backgroundColor = UIColor.white
        headerLabel.font = UIFont(name: kFontTextSemibold, size: 15.0)
        headerView.addSubview(headerLabel)
        
        // View all button
        let viewAllButton = UIButton(frame: CGRect(x: ScreenSize.width-100, y: 7, width: 70, height: 26))
        viewAllButton.setTitleColor(.lightGray, for: .normal)
        viewAllButton.setTitle("View All", for: .normal)
        viewAllButton.titleLabel?.font = UIFont(name: kFontTextRegular, size: 15.0)
        viewAllButton.addTarget(self, action: #selector(viewAllButtonAction(_:)), for: .touchUpInside)
        viewAllButton.tag = section
        viewAllButton.layer.borderWidth = 1.0
        viewAllButton.layer.cornerRadius = 5.0
        viewAllButton.layer.borderColor = UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1).cgColor
        viewAllButton.layer.masksToBounds = true
            
        headerView.addSubview(viewAllButton)
        
        // check section type
        if section == 0 {
            headerLabel.text = "Offers"
            viewAllButton.isHidden = true
        }
        else if section == 1 {
            headerLabel.text = (self.brandStoreArray.count == 0) ? "No stores avaliable" : "Stores"
            viewAllButton.isHidden = (totalStoreCount > 3) ? false : true
        }
        else if section == brandStorieIndex {
            headerLabel.text = "User Stories"
            viewAllButton.isHidden = (totalStoryCount > 3) ? false : true
        }
        
        return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section >= brandStorieIndex {
            
            let dict = brandStoriesArray[section - brandStorieIndex]
            
            if  dict.isShowComment == "1"{
            
            let headerView = UIView(frame: CGRect(x: 10, y: 5, width: ScreenSize.width - 20, height: 60))
            headerView.backgroundColor = UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1)
            
            let commnetTextField = UITextField(frame: CGRect(x: 10, y: 8, width: ScreenSize.width-40, height: 30))
            commnetTextField.backgroundColor = UIColor.clear
            commnetTextField.font = UIFont(name: kFontTextRegular, size: 15.0)
            commnetTextField.placeholder = "Write a comment"
            commnetTextField.returnKeyType = .done
            commnetTextField.borderStyle = .roundedRect
            commnetTextField.delegate = self
            commnetTextField.tag = section
            headerView.addSubview(commnetTextField)
            
            let commnetButton = UIButton(frame: CGRect(x: ScreenSize.width-160, y: 45, width: 150, height: 15))
            commnetButton.setTitleColor(.red, for: .normal)
            commnetButton.setTitle("View Comments", for: .normal)
            commnetButton.titleLabel?.font = UIFont(name: kFontTextMedium, size: 15.0)
                commnetButton.tag = section
            commnetButton.addTarget(self, action: #selector(viewAllcommentAction(_:)), for: .touchUpInside)
            headerView.addSubview(commnetButton)
          
            return headerView
            }
            return nil
        }
        return nil
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < 3 {
            return 40
        }
        return 10.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
     
        if  section >= brandStorieIndex {
            let dict = brandStoriesArray[section - brandStorieIndex]

            if  dict.isShowComment == "1"{
              return 70
            }
            return 0.001
        }
        else if (section == 0 || section == 1){
            return 10
        }
        return 10.0
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var identifier = "brandCell"
        
        if indexPath.section == 0 {// brand offer
            
        var cell: BrandOfferCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? BrandOfferCell
        tableView.register(UINib(nibName: "BrandOfferCell", bundle: nil), forCellReuseIdentifier: identifier)
        cell = (tableView.dequeueReusableCell(withIdentifier: identifier) as? BrandOfferCell)!
        cell.brandOfferArray = self.brandOfferArray
        cell.selectionStyle = UITableViewCellSelectionStyle.none
            
        return cell
        
        } else if indexPath.section == 1 { // Store
        
        identifier = "storeCell"
        var cell: StoreCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? StoreCell
        tableView.register(UINib(nibName: "StoreCell", bundle: nil), forCellReuseIdentifier: identifier)
        cell = (tableView.dequeueReusableCell(withIdentifier: identifier) as? StoreCell)!
        cell.setStoreData(dict: self.brandStoreArray[indexPath.row])
        cell.selectionStyle = UITableViewCellSelectionStyle.none
            
        return cell
            
        }
        
         identifier = "cell" // stories
        
        var cell: StoryViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? StoryViewCell
        
        tableView.register(UINib(nibName: "StoryViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        cell = (tableView.dequeueReusableCell(withIdentifier: identifier) as? StoryViewCell)!
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        tableView.separatorStyle = .none
        // Button Action
        cell.commentButton.tag = indexPath.section
        cell.commentButton.addTarget(self, action:  #selector(commentButtonAction(_:)), for: .touchUpInside)
        cell.shareButton.tag = indexPath.section
        cell.shareButton.addTarget(self, action:  #selector(shareButtonAction(_:)), for: .touchUpInside)
        
        cell.reloadDelegate = self
        cell.setPostInfoWithModel(arrPost: &brandStoriesArray, index: indexPath.section - brandStorieIndex, tableView: brandDetailTable)
        cell.readMoreButton.tag = indexPath.section
        cell.readMoreButton.addTarget(self, action: #selector(readMoreButtonAction(_:)), for: .touchUpInside)
        cell.btnProfile.tag = indexPath.section
        cell.btnProfile.addTarget(self, action: #selector(profileButtonAction(_:)), for: .touchUpInside)
        cell.dotButton.tag = indexPath.section
        cell.dotButton.addTarget(self, action: #selector(dotButtonAction(_:)), for: .touchUpInside)
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 { // store
            var height : Float = 0.0
            let dict = self.brandStoreArray[indexPath.row]
            var title : String = dict[kStoreName] as! String
            height =  Float(title.height(withConstrainedWidth: ScreenSize.width - 160, font: UIFont(name: kFontTextSemibold, size: 14)!)+5)
            
            title = dict[kStoreAddress] as! String
            height += Float(title.height(withConstrainedWidth: ScreenSize.width - 160, font: UIFont(name: kFontTextRegular, size: 13)!)+5) + height
            
            if height > 70 {
                return CGFloat(height)
            }
            return 70
        } else if indexPath.section == 0 {
             return 130; // Brand offer
        }
        
        var height : Float = 0.0
        let dict = brandStoriesArray[indexPath.section - brandStorieIndex]
        
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let arrVisibleCell = brandDetailTable.indexPathsForVisibleRows
        CommonAction.sharedAction.storyVisible(arrVisible: arrVisibleCell!, storyArray: brandStoriesArray, customerId: loginInfoDictionary[kCustomerId]! as! Int, isBrand: true)
    }

    // MARK : Button Action
    
    @objc  func readMoreButtonAction(_ button : UIButton){
        let tag = button.tag - brandStorieIndex
        let dict = brandStoriesArray[tag]
        dict.isReadMore = "0"
        brandStoriesArray[tag] = dict
        brandDetailTable.reloadRows(at: [IndexPath(row: 0, section: tag)], with: .none)
    }
    func reloadCellData(dict: [String : Any]) {
        
    }
    @objc func commentButtonAction(_ button: UIButton) {
        let tag = button.tag - brandStorieIndex
        let dict = brandStoriesArray[tag]
        if  dict.isShowComment == "0"  ||  dict.isShowComment == nil{
            dict.isShowComment = "1"
        } else {
            dict.isShowComment = "0"
        }
        brandStoriesArray[tag] = dict
        brandDetailTable.reloadRows(at: [IndexPath(row: 0, section: tag)], with: .none)
    }
    
    @objc func shareButtonAction(_ button: UIButton) {
        let tag = button.tag - brandStorieIndex
        CommonAction.sharedInst().shareStory(viewC: self, dict: brandStoriesArray[tag])
    }
    
    @objc func viewAllcommentAction(_ button : UIButton){
        // view all comment
        let tag = button.tag - brandStorieIndex
        CommonAction.sharedInst().moveToComment(viewC: self, storyId: brandStoriesArray[tag].storyId!)
    }
    
    @objc func viewAllButtonAction(_ button : UIButton){
        let index = button.tag
        let sb = UIStoryboard(name: "Profile", bundle: nil)
        let allViewC = sb.instantiateViewController(withIdentifier: "FRAllViewC") as? FRAllViewC
        if index == 1 {
            allViewC?.strHeader = "Stores"
        } else if index == 2 {
            allViewC?.strHeader = "Stories"
        }
        allViewC?.brandId = brandDictionary[kBrandId] as! Int
        self.navigationController?.pushViewController(allViewC!, animated: true)
    }

    @objc func profileButtonAction(_ button: UIButton) {
        let tag = button.tag - brandStorieIndex
        let dict = brandStoriesArray[tag]
        CommonAction.sharedInst().movetoProfile(viewC: self, dict: dict, logInId: loginInfoDictionary[kCustomerId] as! Int)
    }
    
    @objc func dotButtonAction(_ button: UIButton) {
        let tag = button.tag - brandStorieIndex
        let dict = brandStoriesArray[tag]
        CommonAction.sharedAction.storyDotAction(dict: dict, logInId: loginInfoDictionary[kCustomerId] as! Int, viewC: self) { (succes, message, actionType) in
            if succes {
                switch actionType {
                case .Hide:
                    self.brandStoriesArray.remove(at: tag)
                    self.brandDetailTable.reloadData()
                case .Delete:
                    alertController(controller: self, title: "", message: "Your story deleted successfully.", okButtonTitle: "Ok", completionHandler: { (valid) in
                        self.brandStoriesArray.remove(at: tag)
                        self.brandDetailTable.reloadData()
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
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK : APIs
    
     func getBrandDetails()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let brandID  : Int = (brandDictionary[kBrandId] as? Int)!
        let  lat  = String(appDelegate.lat)
        let  lng  =  String(appDelegate.long)

        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            kBrandId : String(brandID),
            kLatitude:  lat,
            kLongitude: lng,
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kbranddetail))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        print(dict)
                        self.brandDetailTable.isHidden = false
                        if  let payloadDict =  dict.value(forKey: kPayload) as? [String : Any]
                        {
                            self.brandInfo = payloadDict[kBrandInfo] as! [String : Any]
                            self.brandStoreArray = payloadDict[kBrandStore] as! [[String : Any]]
                            self.brandOfferArray = payloadDict[kBrandOffer] as! [[String : Any]]
                            let stories = payloadDict[kBrandStories] as! [[String : Any]]
                            self.brandStoriesArray = Mapper<PostListModel>().mapArray(JSONArray: stories)
                            self.totalStoreCount = payloadDict["storeCount"] as! Int
                            self.totalStoryCount = payloadDict["storyCount"] as! Int
                            self.setBrandImageInHeader()
                        }
                        self.brandDetailTable.reloadData()
                    } else {
                        let message = dict[kMessage]
                        
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                        })
                    }
                }
            }
        }
    }
    
    
    func setBrandImageInHeader() {
        
        self.title = brandInfo[kBrandName] as? String
        
        
        let fav : NSInteger = brandInfo[kisFavourite] as? NSInteger ?? 0
        if fav == 1 {
            self.favBrandButton.image = UIImage(named: "heart_h")
            self.favBrandButton.tintColor = UIColor.red
        } else {
            self.favBrandButton.image = UIImage(named: "savefill")

        }
       /* let urlString = self.brandDictionary[kBrandLogo] as? String
        let urlStrings = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlStrings!)
        self.brandImage.sd_setImage(with:url , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)*/
    }
    
    
    func reloadCellData(dict: [String : Any], rowHeight: CGFloat, index: Int) {
        
    }
    
    func postComment(textField: UITextField)
    {
        let tag = textField.tag - brandStorieIndex
        let dict = brandStoriesArray[tag]
        let storeId = dict.storyId
        
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            StoryId : storeId,
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}
extension FRBrandDetailViewController : UITextFieldDelegate{
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
