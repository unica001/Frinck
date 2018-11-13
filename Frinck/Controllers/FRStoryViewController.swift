
import UIKit
import SDWebImage
import DZNEmptyDataSet
import ObjectMapper

class FRStoryViewController: UIViewController,delegateReloadCell {
    
    @IBOutlet var storyTableView: UITableView!
    
    @IBOutlet var imgBanner: UIImageView!
    @IBOutlet var viewBannerHeader: UIView!
    
    var loginInfoDictionary :NSMutableDictionary!
    
    var isCommentClicked : Bool = false
    var userStoryArray = [PostListModel]()
    
    var requestURL: URL!
    
    var fromViewController : String  = ""
    var rowHeight = [Int : CGFloat]()
    var  selectedCommentIndex : Int = 0
    var commentString : String = ""
    var commentTextField : UITextField!
    var pageIndex = 1
    var totalCount = 0
    var isMyStory = false
    
    //MARK: - View Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        storyTableView.register(UINib(nibName: "StoryViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        if !isMyStory {
            storyTableView.tableHeaderView = viewBannerHeader
            if let imgUrl = UserDefaults.standard.object(forKey: "bannerImgUrl")
            {
                let urlString = imgUrl as? String
                let urlStrings = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                let url = URL(string: urlStrings!)
                self.imgBanner.sd_setImage(with:url , placeholderImage: UIImage(named : ""), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isMyStory {
            getMyStoryList()
        } else {
            getUserStoryList()
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    // MARK:- Table Button Action
    
    @objc  func readMoreButtonAction(_ button : UIButton){
        let dict = userStoryArray[button.tag]
        dict.isReadMore = "0"
        userStoryArray[button.tag] = dict
        storyTableView.reloadRows(at: [IndexPath(row: 0, section: button.tag)], with: .none)
    }
    
    func reloadCellData(dict: [String : Any], rowHeight: CGFloat, index: Int) {
        storyTableView.beginUpdates()
        self.rowHeight[index] = rowHeight
        storyTableView.endUpdates()
    }
    
    @objc func commentButtonAction(_ button: UIButton) {
        selectedCommentIndex = button.tag
        let dict = userStoryArray[button.tag]
        if  dict.isShowComment == "0"  ||  dict.isShowComment == nil{
            dict.isShowComment = "1"
        } else {
            dict.isShowComment = "0"
        }
        userStoryArray[button.tag] = dict
        self.storyTableView.reloadRows(at: [IndexPath.init(row: 0, section: button.tag)], with: .none)
    }
    
    @objc func shareButtonAction(_ button: UIButton) {
        CommonAction.sharedAction.shareStory(viewC: self, dict: userStoryArray[button.tag])
    }
    
    @objc func viewAllcommentAction(_ button : UIButton){
        // view all comment
        CommonAction.sharedAction.moveToComment(viewC: self, storyId: userStoryArray[button.tag].storyId!)
    }
    
    @objc func profileButtonAction(_ button: UIButton) {
        CommonAction.sharedInst().movetoProfile(viewC: self, dict: userStoryArray[button.tag], logInId: loginInfoDictionary[kCustomerId] as! Int)
    }
    
    @objc func dotButtonAction(_ button : UIButton) {
        let dict = userStoryArray[button.tag]
        CommonAction.sharedAction.storyDotAction(dict: dict, logInId: loginInfoDictionary[kCustomerId] as! Int, viewC: self) { (succes, message, actionType) in
            if succes {
                switch actionType {
                case .Hide:
                    self.userStoryArray.remove(at: button.tag)
                    self.storyTableView.reloadData()
                case .Delete:
                    alertController(controller: self, title: "", message: "Your story deleted successfully.", okButtonTitle: "Ok", completionHandler: { (valid) in
                        self.userStoryArray.remove(at: button.tag)
                        self.storyTableView.reloadData()
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
    
    @objc func doneButtonClicked() {
        self.postComment()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if totalCount > userStoryArray.count {
            if maximumOffset - currentOffset <= -40 && userStoryArray.count != 0 && userStoryArray.count%10 == 0 {
                pageIndex = pageIndex + 1
                if isMyStory {
                    getMyStoryList()
                } else {
                    getUserStoryList()
                }
            }
        }
    }
    
    @IBAction func tapBack(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - API Call
    
    @objc func getUserStoryList()
    {
        var params: NSMutableDictionary = [:]
        if self.fromViewController == kBrandStories {
            params = [
                kCustomerId : loginInfoDictionary[kCustomerId]!,
                kpageNo : pageIndex,
            ]
            requestURL = URL(string: String(format: "%@%@",kBaseUrl,kbrandstory))!
        }
        else {
            params = [
                kCustomerId : loginInfoDictionary[kCustomerId]!,
                kpageNo : pageIndex,
            ]
            requestURL = URL(string: String(format: "%@%@",kBaseUrl,kuserstory))!
            
        }
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    self.storyTableView.emptyDataSetDelegate = self
                    self.storyTableView.emptyDataSetSource = self
                    if index == "200" {
                        
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            self.totalCount = payload["total"] as! Int
                            if self.fromViewController == kBrandStories {
                                let brandStory = payload["brandStoryList"] as! [[String : Any]]
                                let postList = Mapper<PostListModel>().mapArray(JSONArray: brandStory)
                                if self.pageIndex == 1 {
                                    self.userStoryArray = postList
                                } else {
                                    self.userStoryArray.append(contentsOf: postList)
                                }
                            }
                            else {
                                let userStory = payload["userStoryList"] as! [[String : Any]]
                                let storyList = Mapper<PostListModel>().mapArray(JSONArray: userStory)
                                if self.pageIndex == 1 {
                                    self.userStoryArray = storyList
                                } else {
                                    self.userStoryArray.append(contentsOf: storyList)
                                }
                            }
                            self.storyTableView.reloadData()
                        }
                    }
                    else
                    {
                        self.storyTableView.reloadData()
                        
                    }
                }
            }
        }
    }
    
    @objc func getMyStoryList()
    {
        var params: NSMutableDictionary = [:]
            params = [
                kCustomerId : loginInfoDictionary[kCustomerId]!,
                kpageNo : pageIndex,
            ]
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kmyStory))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    self.storyTableView.emptyDataSetDelegate = self
                    self.storyTableView.emptyDataSetSource = self
                    if index == "200" {
                        
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            self.totalCount = payload["total"] as! Int
                            let userStory = payload["userStoryList"] as! [[String : Any]]
                            let storyList = Mapper<PostListModel>().mapArray(JSONArray: userStory)
                            if self.pageIndex == 1 {
                                self.userStoryArray = storyList
                            } else {
                                self.userStoryArray.append(contentsOf: storyList)
                            }
                            self.storyTableView.reloadData()
                        }
                    }
                    else
                    {
                        self.storyTableView.reloadData()
                        
                    }
                }
            }
        }
    }
    
    func postComment()
    {
        if self.commentString == "" {
            alertController(controller: self, title: "", message: "Please enter your comment", okButtonTitle: "Ok", completionHandler: { (value) in
                
            })
            return
        }
        let dict = userStoryArray[selectedCommentIndex]
        let storeId : Int = dict.storyId!
        
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            StoryId : String(storeId),
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
                        
                        
                        self.commentTextField.resignFirstResponder()
                        self.commentTextField.text = ""
                        self.commentString = ""
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
    
}

extension FRStoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return userStoryArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let dict = userStoryArray[section]
        
        if  dict.isShowComment == "1"  &&  dict.isShowComment != nil{
            return 60
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let dict = userStoryArray[section]
        
        if  dict.isShowComment == "1"  &&  dict.isShowComment != nil{
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: 60))
            headerView.backgroundColor = UIColor.clear
            
            let commnetTextField = UITextField(frame: CGRect(x: 0, y: 5, width: ScreenSize.width-20, height: 30))
            commnetTextField.backgroundColor = UIColor.clear
            commnetTextField.font = UIFont(name: kFontTextRegular, size: 15.0)
            commnetTextField.placeholder = "Write a comment"
            commnetTextField.returnKeyType = .done
            commnetTextField.delegate = self
            commnetTextField.borderStyle = .roundedRect
            headerView.addSubview(commnetTextField)
            
            let commnetButton = UIButton(frame: CGRect(x: ScreenSize.width-150, y: 40, width: 150, height: 15))
            commnetButton.setTitleColor(.red, for: .normal)
            commnetButton.setTitle("View Comments", for: .normal)
            commnetButton.titleLabel?.font = UIFont(name: kFontTextSemibold, size: 15.0)
            commnetButton.addTarget(self, action: #selector(viewAllcommentAction(_:)), for: .touchUpInside)
            commnetButton.tag = section
            headerView.addSubview(commnetButton)
            
            return headerView
        }
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "cell"
        
        var cell: StoryViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? StoryViewCell
        
        tableView.register(UINib(nibName: "StoryViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        cell = (tableView.dequeueReusableCell(withIdentifier: identifier) as? StoryViewCell)!
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        // Button Action
        cell.commentButton.tag = indexPath.section
        cell.commentButton.addTarget(self, action:  #selector(commentButtonAction(_:)), for: .touchUpInside)
        cell.shareButton.addTarget(self, action:  #selector(shareButtonAction(_:)), for: .touchUpInside)
        
        cell.reloadDelegate = self
        cell.setPostInfoWithModel(arrPost: &userStoryArray, index: indexPath.section, tableView: tableView)
        cell.readMoreButton.addTarget(self, action: #selector(readMoreButtonAction(_:)), for: .touchUpInside)
        cell.btnProfile.tag = indexPath.section
        cell.btnProfile.addTarget(self, action: #selector(profileButtonAction(_:)), for: .touchUpInside)
        cell.dotButton.tag = indexPath.section
        cell.dotButton.addTarget(self, action: #selector(dotButtonAction(_:)), for: .touchUpInside)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height : Float = 0.0
        let dict = userStoryArray[indexPath.section]
        
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
        let arrVisibleCell = storyTableView.indexPathsForVisibleRows
        CommonAction.sharedAction.storyVisible(arrVisible: arrVisibleCell!, storyArray: userStoryArray, customerId: loginInfoDictionary[kCustomerId]! as! Int)
    }
}

extension FRStoryViewController:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.commentTextField = textField
        self.commentTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.commentString = self.commentString + string
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.postComment()
        return true
    }
    
}

extension FRStoryViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let txtAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font: UIFont(name: kFontTextSemibold, size: 15.0)! , NSAttributedStringKey.foregroundColor: UIColor.black]
        let placeholderText = NSAttributedString(string: (self.fromViewController == kbrandstory) ? "No Brand Stories" : "No User Stories", attributes: txtAttributes)
        return placeholderText
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attString = NSAttributedString(string: "Refresh", attributes: [ NSAttributedStringKey.font: UIFont(name: kFontTextMedium, size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.red])
        return attString
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.pageIndex = 1
        if isMyStory {
            getMyStoryList()
        } else {
            self.getUserStoryList()
        }
       
    }
}

