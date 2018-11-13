
import UIKit
import Quickblox
 import GradientProgress

class ProfileHeaderView: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnThreeDot: UIButton!
    @IBOutlet weak var lblName: UILabel!
//    @IBOutlet weak var viewRate: UIView!
    @IBOutlet weak var cnstViewRateCenter: NSLayoutConstraint!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var viewFollow: UIView!
    @IBOutlet weak var btnFollowing: UIButton!
    @IBOutlet weak var btnSendMsg: UIButton!
    @IBOutlet weak var lblCheckIn: UILabel!
    @IBOutlet weak var viewFollowFollowing: UIView!
    @IBOutlet weak var btnNoFollowing: UIButton!
    @IBOutlet weak var btnNoFollower: UIButton!
//    @IBOutlet weak var imgLevel: UIImageView!
    @IBOutlet weak var slider: GradientProgressBar!
    @IBOutlet var lblLevel: UILabel!
    
    
    internal var userId: Int? = nil
    var dictInfo = [String : AnyObject]()
    var dictCustomerLevel = [String : AnyObject]()
    var loginInfoDictionary: NSMutableDictionary!
    var viewAlert = CustomAlert()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        setUpView()
//        slider.setMaximumTrackImage(#imageLiteral(resourceName: "sliderW"), for: .normal)
//        slider.setMinimumTrackImage(#imageLiteral(resourceName: "slider"), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadHeaderView(_:)), name: NSNotification.Name(rawValue: "reloadHeaderView"), object: nil)
        setUpView()
    }
    
    @objc func reloadHeaderView(_ notification: NSNotification) {
        
        self.dictInfo = notification.userInfo!["profileSummary"] as! [String : AnyObject]
        self.dictCustomerLevel =  notification.userInfo!["custLevel"] as! [String :AnyObject]
        print("reload")
        setUpView()

       
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
    
    //MARK: - Private Methods
    private func setUpView() {
        
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width/2
        imgProfile.layer.masksToBounds = true
        btnFollowing.layer.cornerRadius = btnFollowing.frame.size.height/2
        btnFollowing.layer.masksToBounds = true
        btnSendMsg.layer.cornerRadius = btnSendMsg.frame.size.height/2
        btnSendMsg.layer.masksToBounds = true
        btnNoFollowing.titleLabel?.numberOfLines = 0
        btnNoFollowing.titleLabel?.textAlignment = .center
        btnNoFollower.titleLabel?.numberOfLines = 0
        btnNoFollower.titleLabel?.textAlignment = .center
//        imgLevel.layer.cornerRadius = imgLevel.frame.size.height/2
//        imgLevel.layer.masksToBounds = true
       
        viewFollow.isHidden = (userId == nil) ? true : false
        lblCheckIn.isHidden = (userId == nil) ? false : true
        btnEdit.isHidden = (userId == nil) ? false : true
//        btnThreeDot.isHidden = (userId == nil) ? true : false
//        cnstViewRateCenter.constant = (userId == nil) ? 50 : 0
//        viewRate.isHidden = (userId == nil) ? false : true
        
        if let name = dictInfo["CustomerName"] as? String {
            lblName.text = name
        }
        
        let strFollowing = "FOLLOWING\n\(String(describing: dictInfo["totalFollowing"]!))"
        btnNoFollowing.setTitle(strFollowing, for: .normal)
        
        let strFollower = "FOLLOWER\n\(String(describing: dictInfo["totalFollower"]!))"
        btnNoFollower.setTitle(strFollower, for: .normal)
        
        if let imageUrl = dictInfo["imageUrl"] as? String {
            imgProfile.sd_setImage(with: URL(string: imageUrl), placeholderImage: #imageLiteral(resourceName: "roundPlaceHolder"), options: .cacheMemoryOnly, progress: nil) { (image, err, chache, url) in
                
            }
        }
        if userId == nil {
            if let checkIn = dictInfo["isCheckIn"] as? Int, checkIn == 1 {
                lblCheckIn.isHidden = false
            } else {
                lblCheckIn.isHidden = true
            }
        }

        lblLevel.text = "Level \(dictInfo["CustomerLevel"]!)"
        
        if let isFollowing = dictInfo["isFollowing"] as? Int, isFollowing == 1 {
            btnFollowing.setTitle("FOLLOWING", for: .normal)
            btnFollowing.setTitleColor(UIColor.black, for: .normal)
            btnFollowing.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1)
            btnThreeDot.isHidden = (userId != nil) ? false : true
        } else {
            btnFollowing.setTitle("FOLLOW", for: .normal)
            btnFollowing.setTitleColor(UIColor.white, for: .normal)
            btnFollowing.backgroundColor = UIColor.red
            btnThreeDot.isHidden = true
        }
        
        if let isBlock = dictInfo["isBlock"] as? Int, isBlock == 1 {
            btnThreeDot.isHidden = false
            viewFollow.isHidden = true
        }
        
        if let earnLoyality = dictInfo["CustomerEarnedLoyalty"] as? Int {
            lblRate.text = "Points " + String(earnLoyality)
        }
        
        let customerLevel = dictCustomerLevel["CustomerLevel"] as! Int
        let totalLevel = dictCustomerLevel["totalLevel"] as! Int
       let avg = customerLevel/totalLevel * 100
        slider.progress = Float(avg) + 0.5
    }
    
    func saveImageInDirectory(uploadImage : UIImage) -> URL {
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(getFileName).jpeg")
        let imageData = UIImageJPEGRepresentation(uploadImage, 0.99)
        fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
        
        return NSURL(fileURLWithPath: path) as URL
    }
    
    func getFileName()-> String {
        let date = Date()
        let interval = date.timeIntervalSince1970
        return String(interval)
    }
    
    func showPopUp() {
//        let strMessage = "Are you sure you want to unfollow \(String(describing: dictInfo["CustomerName"]!))?"
//        viewAlert = CustomAlert(frame: self.view.bounds)
//        viewAlert.loadView(customType: .TwoButton, strMsg: strMessage, image: #imageLiteral(resourceName: "following")) { (success) in
//            if let isSucess = success as? Bool, isSucess == true {
                self.callApiToUnfollow()
//            } else {
//                self.viewAlert.removeFromSuperview()
//            }
//        }
//        let window = UIApplication.shared.windows.first!
//        window.addSubview(viewAlert)
    }
    
    //MARK: - API call

    func apiCallImageUpload(strUrl: String) {
        var params: NSMutableDictionary = [:]
        
        params = [ kCustomerId : loginInfoDictionary[kCustomerId]! as AnyObject,
                   "imageUrl" : strUrl as AnyObject]
        let requestURL = URL(string: String(format:"%@%@",kBaseUrl,kchangePhoto))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                     let message = dict[kMessage] as? String
                    if index == "200" {
                        self.loginInfoDictionary["imageUrl"] = strUrl
                        kUserDefault.set(NSKeyedArchiver.archivedData(withRootObject:self.loginInfoDictionary), forKey: kloginInfo)
                        alertController(controller: self, title: "", message: message!, okButtonTitle: "Ok", completionHandler: { (value) in
                            self.imgProfile.sd_setImage(with: URL(string: strUrl), placeholderImage: #imageLiteral(resourceName: "roundPlaceHolder"), options: .cacheMemoryOnly , progress: nil, completed: { (img, error, cache, url) in
                                
                            })
                        })
                    } else {
                        alertController(controller: self, title: "", message: message!, okButtonTitle: "Ok", completionHandler: { (value) in
                            
                        })
                    }
                }
            }
        }
    }
    
    func callApiToFollow() {
        let params: NSMutableDictionary = [ kCustomerId : loginInfoDictionary[kCustomerId]! as AnyObject,
                                            kRequestId : userId ?? ""]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kuserFollow))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        self.btnFollowing.setTitle("Following", for: .normal)
                        self.btnFollowing.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1)
                        self.btnFollowing.setTitleColor(UIColor.black, for: .normal)
                        self.dictInfo["isFollowing"] = 1 as AnyObject
                    } else {
                        let message = dict[kMessage] as? String
                        alertController(controller: self, title: "", message:message!, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                        })
                    }
                }
            }
        }
    }
    
    func callApiToUnfollow() {
        let params: NSMutableDictionary = [ kCustomerId : self.loginInfoDictionary[kCustomerId]! as AnyObject,
                                            kRequestId : self.userId as AnyObject]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kuserUnfollow))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        self.btnFollowing.setTitle("FOLLOW", for: .normal)
                        self.btnFollowing.setTitleColor(UIColor.white, for: .normal)
                        self.btnFollowing.backgroundColor = UIColor.red
                        self.dictInfo["isFollowing"] = 0 as AnyObject
                        self.viewAlert.removeFromSuperview()
                    } else {
                        let message = dict[kMessage] as? String
                        alertController(controller: self, title: "", message: message!, okButtonTitle: "OK", completionHandler: { (value) in
                            self.viewAlert.removeFromSuperview()
                        })
                    }
                }
            }
        }
    }
    
    func callApiBlockUser() {

        let params: NSMutableDictionary = [ kCustomerId : self.loginInfoDictionary[kCustomerId]! as AnyObject,
                                            "userId" : self.userId as AnyObject]
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kblockUser))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    let message = dict[kMessage] as? String
                    if index == "200" {
                        alertController(controller: self, title: "", message: message!, okButtonTitle: "OK", completionHandler: { (value) in
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        alertController(controller: self, title: "", message: message!, okButtonTitle: "OK", completionHandler: { (value) in
                            
                        })
                    }
                }
            }
        }
    }
    
    func callApiUnBlockUser() {
        
        let params: NSMutableDictionary = [ kCustomerId : self.loginInfoDictionary[kCustomerId]! as AnyObject,
                                            "userId" : self.userId as AnyObject]
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kUnblockUser))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    let message = dict[kMessage] as? String
                    if index == "200" {
                        alertController(controller: self, title: "", message: message!, okButtonTitle: "OK", completionHandler: { (value) in
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        alertController(controller: self, title: "", message: message!, okButtonTitle: "OK", completionHandler: { (value) in
                            
                        })
                    }
                }
            }
        }
    }
    
    func callApiDeleteProfile() {
        
        let params: NSMutableDictionary = [ kCustomerId : self.loginInfoDictionary[kCustomerId]! as AnyObject]
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kremovePhoto))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    let message = dict[kMessage] as? String
                    if index == "200" {
                        alertController(controller: self, title: "", message: message!, okButtonTitle: "OK", completionHandler: { (value) in
                            self.imgProfile.image = #imageLiteral(resourceName: "roundPlaceHolder")
                        })
                    } else {
                        alertController(controller: self, title: "", message: message!, okButtonTitle: "OK", completionHandler: { (value) in
                            
                        })
                    }
                }
            }
        }
    }
    //MARK: - IBAction Methods
    @IBAction func tapThreeDot(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "" , message: "" , preferredStyle: .actionSheet)
        let actionSelectCamera = UIAlertAction(title: (dictInfo["isBlock"] as! Int == 1) ? "Unblock" : "Block", style: .default, handler: {
            UIAlertAction in
            if self.dictInfo["isBlock"] as! Int == 1 {
                self.callApiUnBlockUser()
            } else {
                self.callApiBlockUser()
            }
        })
        let actionSelectGallery = UIAlertAction(title: "Report", style: .default, handler: {
            UIAlertAction in
            let sb = UIStoryboard(name: "Profile", bundle: nil)
            let reportViewC = sb.instantiateViewController(withIdentifier: "FRReportViewC") as? FRReportViewC
            reportViewC?.userId = self.userId!
            reportViewC?.isFromReportUser = true
            self.navigationController?.pushViewController(reportViewC!, animated: true)
        })
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(actionCancel)
        actionSheet.addAction(actionSelectCamera)
        actionSheet.addAction(actionSelectGallery)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func tapEditProfile(_ sender: UIButton) {
        
        if let imageUrl = dictInfo["imageUrl"] as? String, imageUrl == "" {
                self.uploadProfile()
        } else {
            let actionSheet = UIAlertController(title: "" , message: "" , preferredStyle: .actionSheet)
            let actionSelectDelete = UIAlertAction(title: "Remove Profile Picture", style: .default, handler: {
                UIAlertAction in
                self.callApiDeleteProfile()
            })
            let actionSelectUpload = UIAlertAction(title: "Update Profile Picture", style: .default, handler: {
                UIAlertAction in
                self.uploadProfile()
            })
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            actionSheet.addAction(actionCancel)
            actionSheet.addAction(actionSelectDelete)
            actionSheet.addAction(actionSelectUpload)
            self.present(actionSheet, animated: true, completion: nil)
        }
       
    }
    
    func uploadProfile() {
        ImgPickerHandler.sharedHandler.getImage(instance: self.parent!, rect: self.view.bounds) { (img, success) in
            if success {
                
                self.updateUserProfileInQuickBlox(image: img!)
                NetworkManager.sharedInstance.uploadImageOnS3(self.saveImageInDirectory(uploadImage: img!), fileName: self.getFileName(), hude: true, fromView: "profile", completionHandler: { (url) in
                    if url != "" {
                        self.apiCallImageUpload(strUrl: url)
                    } else {
                        
                    }
                })
            }
        }
    }
    
    func updateUserProfileInQuickBlox( image : UIImage){
       
        let imageData : Data = UIImagePNGRepresentation(image)!
        if let currentUser:QBUUser = ServicesManager.instance().currentUser {
            
            
            QBRequest.tUploadFile(imageData, fileName: "profileImage", contentType: "image/png", isPublic: false, successBlock: {( responce : QBResponse, blobid : QBCBlob) in
                print(blobid)
                print(responce)
                let updateParameters = QBUpdateUserParameters()
                updateParameters.blobID = blobid.id
                
                QBRequest.updateCurrentUser(updateParameters, successBlock: {( responce : QBResponse,user : QBUUser) in
                    
                    print(user.blobID)
                    print(responce)
                    currentUser.blobID = user.blobID
                    
                }, errorBlock: {(error : QBResponse) in
                    
                })
               
                
            }, statusBlock: nil, errorBlock:{(error : QBResponse) in
                print(error)
            } )
    }
       
    }

    @IBAction func tapFollowingList(_ sender: UIButton) {
        moveToFollowViewC(isFollower: false)
    }
    
    @IBAction func tapFollowerList(_ sender: UIButton) {
        moveToFollowViewC(isFollower: true)
    }
    
    @IBAction func tapFollow(_ sender: UIButton) {
        if let isFollowing = dictInfo["isFollowing"] as? Int, isFollowing == 1 {
            self.showPopUp()
        } else {
            self.callApiToFollow()
        }
    }
    
    @IBAction func tapSendMsg(_ sender: UIButton) {
        if let qbid = dictInfo[kqbId] as? Int {
           getUserbyQBID(QBID: String(qbid))
        }
        else{
            getUserbyQBID(QBID: "55517879")
        }
    }
    
    func moveToFollowViewC(isFollower: Bool) {
        if userId != nil {
            return
        }
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let followViewC = storyboard.instantiateViewController(withIdentifier: "FRFollowViewC") as? FRFollowViewC
        followViewC?.isFollowers = isFollower
        self.navigationController?.pushViewController(followViewC!, animated: true)
    }
    
    // Chat Delegate
    func createChatButtonPressed(_ user: QBUUser) {
        
        var users: [QBUUser] = []
        users.append(user)
        
        let completion = {[weak self] (response: QBResponse?, createdDialog: QBChatDialog?) -> Void in
            
            if createdDialog != nil {
                self?.openNewDialog(dialog: createdDialog)
            }
        }
        
        if users.count == 1 {
            self.createChat(name: nil, users: users, completion: completion)
        }
    }
   
    func createChat(name: String?, users:[QBUUser], completion: ((_ response: QBResponse?, _ createdDialog: QBChatDialog?) -> Void)?) {
        
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        
        if users.count == 1 {
            // Creating private chat.
            ServicesManager.instance().chatService.createPrivateChatDialog(withOpponent: users.first!, completion: { (response, chatDialog) in
                
                self.openNewDialog(dialog: chatDialog)
            })
            
        }
    }
    
    
    func openNewDialog(dialog: QBChatDialog!) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let chatVC = storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.dialog = dialog
        self.navigationController?.pushViewController(chatVC, animated: true)
        return
    }
    
    func getUserbyQBID( QBID : String){
        
        QBRequest.user(withID: UInt(QBID)!, successBlock:{(responce : QBResponse , user: QBUUser) in
              self.createChatButtonPressed(user)
            
        }, errorBlock: {(error : QBResponse) in
        })
        

    }
}
