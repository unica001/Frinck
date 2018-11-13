
import UIKit
import SDWebImage
import Firebase

class FROfferDetailedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var offerDetailedTableView: UITableView!
    @IBOutlet weak var offerDetailImage: UIImageView!
    
    var loginInfoDictionary : NSMutableDictionary!
    var offerId : Int = 0
    var offerDictionary  = [String : Any]()
    var offerDetailsDictionary  = [String : Any]()
    var offerType = ""
    var webUrl : String = ""
    
    @IBOutlet var webButton: UIButton!
    @IBOutlet var saveButtonX_axis: NSLayoutConstraint!
    @IBOutlet var shareButtonTrailing: NSLayoutConstraint!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet weak var footerView: UIView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        offerDetailedTableView.register(UINib(nibName: "FROfferDetailedTableViewCell", bundle: nil), forCellReuseIdentifier: "FROfferDetailedTableViewCell")
        
        offerDetailedTableView.isHidden = true
        getOfferDetail()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Private Methods
    func setInitialData(dict : NSDictionary){
        self.offerDetailsDictionary = dict.value(forKey: kPayload) as! [String : Any]
        self.offerType = (self.offerDetailsDictionary[kOfferType] as? String)!
        
        self.setBrandImageInHeader()
        self.offerDetailedTableView.reloadData()
        self.offerDetailedTableView.isHidden = false
        
        if self.offerType == konline{
            webButton.isHidden = true
            saveButtonX_axis.constant = (ScreenSize.width-186)/3
            shareButtonTrailing.constant = (ScreenSize.width-186)/3
        } else {
            webUrl = offerDetailsDictionary["onlineUrl"] as! String
            if webUrl == "" {
                webButton.isHidden = true
                saveButtonX_axis.constant = (ScreenSize.width-186)/3
                shareButtonTrailing.constant = (ScreenSize.width-186)/3
            } else {
                saveButtonX_axis.constant = (ScreenSize.width - 93)/2
            }
        }
        footerView.isHidden = false
        setSaveOffer()
    }
    
    func setSaveOffer() {
        if let isSaved = offerDetailsDictionary["isSaved"] as? Bool {
            btnSave.setTitle("Save", for: .normal)
            btnSave.setTitleColor((isSaved) ? UIColor.red : UIColor(red: 136.0/255.0, green: 136.0/255.0, blue: 136.0/255.0, alpha: 1.0) , for: .normal)
            btnSave.setImage((isSaved) ? #imageLiteral(resourceName: "heart_h") : #imageLiteral(resourceName: "savefill"), for: .normal)
            btnSave.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
            btnSave.isUserInteractionEnabled = (isSaved) ? false : true
        }
    }
    
    func setBrandImageInHeader(){
        let urlString = self.offerDetailsDictionary[kimageUrl] as? String
        let urlStrings = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlStrings!)
        self.offerDetailImage.sd_setImage(with:url , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
        
        let title = self.offerDetailsDictionary[ktitle]
        Analytics.logEvent("Offer_Detail_Screen", parameters: ["OfferId" : offerDetailsDictionary[kOfferId] ?? "", "OfferName" : title ?? "", "BrandId" : self.offerDetailsDictionary[kBrandId] ?? "", "BrandName" : self.offerDetailsDictionary["BrandName"] ?? "", "OfferType" : self.offerDetailsDictionary[kOfferType] ?? ""])
        self.navigationItem.title = title as? String
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kbrnadDetailsSegueIdentifier {
            let brandDetailView : FRBrandDetailViewController = (segue.destination as? FRBrandDetailViewController)!
            brandDetailView.brandDictionary = sender as! [String : Any]
        }
    }
    
    //MARK: - Table view Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.offerType == konline{
            return 1
        }
        if offerDetailsDictionary.count != 0 {
            let desc = offerDetailsDictionary["description"] as! String
            return (desc == "") ? 3 : 4
        }
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FROfferDetailedTableViewCell", for: indexPath) as! FROfferDetailedTableViewCell
        cell.selectionStyle = .none
        
        if self.offerType == konline {
            cell.setOnlineData(dict: self.offerDetailsDictionary, index: indexPath.row)
        }
        else{
            cell.setOfflineData(dict: self.offerDetailsDictionary, index: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height: Float =  0
        if self.offerDetailsDictionary.count != 0  {
            if  indexPath.row == 0 {
                
                if let title = self.offerDetailsDictionary["onlineUrl"] as? String {
                
                if self.offerType == konline {
                        height =  Float(title.height(withConstrainedWidth: ScreenSize.width - 70, font: UIFont(name: kFontTextRegular, size: 14)!))
                    }
                }
            }
            else if  indexPath.row == 2 {
                if let title = self.offerDetailsDictionary["description"] as? String {
                    height =  (title == "") ? Float(50 + height) : Float(title.height(withConstrainedWidth: ScreenSize.width - 70, font: UIFont(name: kFontTextRegular, size: 14)!))
                }
            }
        }
        
        return CGFloat(50 + height)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let desc = self.offerDetailsDictionary["description"] as? String
       
        if  indexPath.row == 0 && self.offerType == konline {
            let onlineUrl = self.offerDetailsDictionary[konlineUrl] as? String
            let url : URL = URL(string: onlineUrl!)!
            UIApplication.shared.open(url, options:[:] , completionHandler: nil)
            apiCallClickUrl()
        } else  if  indexPath.row == 3 && self.offerType != konline || indexPath.row == 2 && desc == "" {
            let sb = UIStoryboard(name: "Profile", bundle: nil)
            let allViewC = sb.instantiateViewController(withIdentifier: "FRAllViewC") as? FRAllViewC
            allViewC?.strHeader = "Stores"
            allViewC?.brandId = self.offerDetailsDictionary[kBrandId] as! Int
            self.navigationController?.pushViewController(allViewC!, animated: true)
        }
    }
    
    //MARK: - Button Action
    @IBAction func brandDetailedButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: kbrnadDetailsSegueIdentifier, sender: self.offerDetailsDictionary)
    }
    
    @IBAction func SaveDetailButtonAction(_ sender: Any) {
        
        let offerid  =  (offerId != 0) ? String(offerId) : String(self.offerDictionary["offerId"] as! Int)
        saveBrand(offerId: offerid as NSString)
    }
    
    @IBAction func webButtonAction(_ sender: Any) {
        UIApplication.shared.open(URL(string: webUrl)!, options: [:], completionHandler: nil)
        apiCallClickUrl()        
    }
    @IBAction func shareDetailButtonAction(_ sender: Any) {
        let link = createURLWithString()
        createDnamicLink(link: link!)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        if (self.navigationController?.viewControllers.count)! > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            AppDelegate.delegate.goToHomeScreen()
        }
    }
 
    //MARK: - APIs call
    func saveBrand( offerId : NSString){
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId: loginInfoDictionary[kCustomerId]!,
            kOfferId: offerId
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kSaveOffer))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    self.offerDetailsDictionary["isSaved"] = true
                    self.setSaveOffer()
                    let message = dict[kMessage]
                    alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                    })
                }
            }
        }
    }
    
    func getOfferDetail()
    {
        let offerid  =  (self.offerId != 0) ? String(offerId) :  String(self.offerDictionary["offerId"] as! Int)
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId: loginInfoDictionary[kCustomerId]!,
            kOfferId: offerid as NSString
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kOfferDetail))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200"
                    {
                      
                        self.setInitialData(dict: dict)
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
    
    func apiCallClickUrl() {
        let offerid  =  (self.offerId != 0) ? String(offerId) :  String(self.offerDictionary["offerId"] as! Int)
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId: loginInfoDictionary[kCustomerId]!,
            kOfferId: offerid,
            "ClickTime" : Date().toMillis()
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kclickUrl))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: false,isAuthentication: false, showSystemError: false, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                
                }
            }
        }
    }
    
}

extension FROfferDetailedViewController {
    
    //Create and Share URL
    func createURLWithString() -> URL? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https";
        urlComponents.host = "frinck.page.link";
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        // add params
        let offerid  =  (self.offerId != 0) ? String(offerId) :  String(self.offerDictionary["offerId"] as! Int)
        let typeQuery = NSURLQueryItem(name: "link_type", value: "offer")
        let storyIdQuery = NSURLQueryItem(name: kOfferId, value: offerid)
        let inviteQuery = NSURLQueryItem(name: "invited_by", value: "\(loginInfoDictionary[kCustomerUserName] ?? "")")
        urlComponents.queryItems = [typeQuery as URLQueryItem, storyIdQuery as URLQueryItem, inviteQuery as URLQueryItem]
        return urlComponents.url
    }
    
    func createDnamicLink(link: URL) {
        let components = DynamicLinkComponents(link: link, domain: "frinck.page.link")
        let iOSParams = DynamicLinkIOSParameters(bundleID: "frinck.com.frinckapp")
        iOSParams.appStoreID = "987654321"
        iOSParams.customScheme = "frinck.com.frinckapp"
        components.iOSParameters = iOSParams
        
        // Android params
        let androidParams = DynamicLinkAndroidParameters(packageName: "com.frinck")
        components.androidParameters = androidParams

        //social tag params
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        let socialParams = DynamicLinkSocialMetaTagParameters()
        if let name = loginInfoDictionary[kCustomerUserName] {
            socialParams.descriptionText = "\(name) shared a offer with you."
        }
        //        var metaImage = Constant.appLogoUrl
        //        if let shareAs = topic.shareAs, shareAs == ShareAs.showIdentity.rawValue {
        //            if let userPic = topic.userPicture, userPic != "" {
        //                metaImage = userPic
        //            }
        //        }
        //        socialParams.imageURL = URL(string: metaImage)
        components.socialMetaTagParameters = socialParams
        
        components.shorten { (shortURL, warnings, error) in
            // Handle shortURL.
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let shortLink = shortURL
            if let link = shortLink?.absoluteString, link != "" {
                self.sendLink(shortLinkStr: link)
            }
        }
    }
    
    func sendLink(shortLinkStr: String) {
        if let myWebsite = NSURL(string: shortLinkStr) {
            let objectsToShare = [myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

