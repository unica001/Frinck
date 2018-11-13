
import UIKit
import SDWebImage
import FirebaseDynamicLinks
import SJSegmentedScrollView

class FROfferViewController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewBottonHeight: NSLayoutConstraint!
    @IBOutlet var noRecordLable: UILabel!
    var offerType : NSString = ""
    var offerArray = [[String:Any]]()
    var loginInfoDictionary :NSMutableDictionary!
    var showHude : Bool = false
    var pageIndex = 1
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showHude = true
        self.view.backgroundColor = kLightGrayColor
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        if DeviceType.iPhoneX {
            collectionViewBottonHeight.constant = -250
        }
        else {
            collectionViewBottonHeight.constant = -218
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.title == kMySavedOffer {
            OfferGetBrand(type: "All")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == kOfferDetailedSegueIdentifier {
            let  offerDetails :FROfferDetailedViewController = segue.destination as! FROfferDetailedViewController
            offerDetails.offerDictionary = sender as! [String : Any]
        }
    }
    
    //MARK:- Private Methods
    
    func noRecordLabel( index : NSInteger, count : NSInteger){
        if  index == 1 && count == 0 {
            self.noRecordLable.isHidden = false
        }
        else{
            self.noRecordLable.isHidden = true
        }
    }
    
//    func setBannerImage(dict : [String : Any]){
//        let bannerUrlString = dict[kimageUrl]
//        UserDefaults.standard.set(bannerUrlString, forKey: "bannerImgUrl")
//        let urlString = bannerUrlString as? String
//        let urlStrings = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//        let url = URL(string: urlStrings!)
//        if bannerImageView == nil {
//            self.headerView.setUp(img: urlString!)
//        } else {
//            self.bannerImageView.sd_setImage(with:url , placeholderImage: UIImage(named : ""), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
//        }
//    }
    
    @objc func saveButtonClick(dict: [String : Any])
    {
        let offerid  =  String(dict["offerId"] as! Int)
        saveBrand(offerId: offerid as NSString)
    }
    
    @objc func shareButtonClick(dict: [String : Any])
    {
        let link = createURLWithString(dict: dict as [String : AnyObject])
        createDnamicLink(link: link!)
    }
    
    //MARK: - IBAction Methods
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapThreeDot(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "" , message: "Select any" , preferredStyle: .actionSheet)
        let dict = offerArray[sender.tag]
        let isSaved = dict["isSaved"] as! Bool
        let actionSelectCamera = UIAlertAction(title: (isSaved) ? "Saved" : "Save", style: .default, handler: {
            UIAlertAction in
            if isSaved {
                return
            }
            self.saveButtonClick(dict: dict)
        })
        let actionSelectGallery = UIAlertAction(title: "Share", style: .default, handler: {
            UIAlertAction in
            self.shareButtonClick(dict: dict)
        })
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(actionCancel)
        actionSheet.addAction(actionSelectCamera)
        actionSheet.addAction(actionSelectGallery)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK:- Collection view Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return offerArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FROfferCollectionCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        let dict = offerArray[indexPath.row]
        cell.setOfferData(dictionary:dict)
        cell.btnThree.tag = indexPath.row
        
//        cell.saveButton.tag = indexPath.row
//        cell.saveButton.addTarget(self, action: #selector(saveButtonClick(_:)), for: .touchUpInside)
//        cell.shareButton.addTarget(self, action: #selector(shareButtonClick(_:)), for: .touchUpInside)
//        
//        if self.title == kMySavedOffer {
//            cell.saveButton.isHidden = true
//        }
        return cell
    }
    
    
    // MARK:- UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (ScreenSize.width-30)/2, height: 100) // The size of one cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 0, 10) // margin between cells
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.title == kMySavedOffer {
            return
        }
        let dict = offerArray[indexPath.row]
        self.performSegue(withIdentifier: kOfferDetailedSegueIdentifier, sender: dict)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if maximumOffset - currentOffset <= -40 && offerArray.count != 0 && offerArray.count%10 == 0 {
            pageIndex = pageIndex + 1
            showHude = true
            OfferGetBrand(type: self.offerType)
        }
    }
    
    //MARK: - API Call
    func OfferGetBrand(type : NSString) {
        
        offerType = type
        let cityId  = loginInfoDictionary[kCityId]
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId: loginInfoDictionary[kCustomerId]!,
            kLocationId: cityId!,
            kViewType: type,
            kpageNo : pageIndex
            
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kOfferGetOffer))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: showHude,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    self.showHude = false
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200"
                    {
                        if let payLoadDictionary = dict.value(forKey: kPayload) as? [String : Any]{
                            if (payLoadDictionary[kOffer]  as? String) != nil {
                                return;
                            }
                            if self.pageIndex == 1 {
                                self.offerArray = payLoadDictionary[kOffer] as! [[String : Any]]
                                self.noRecordLabel(index: self.pageIndex, count: self.offerArray.count)
                            } else {
                                let addMoreArray = payLoadDictionary[kOffer] as! [[String : Any]]
                                self.offerArray.append(contentsOf: addMoreArray)
                            }
//                            if self.title != kMySavedOffer {
//                                self.setBannerImage(dict: payLoadDictionary[kBanner] as! [String : Any])
//                            }
                            self.collectionView.reloadData()
                        } else {
                            self.noRecordLabel(index: self.pageIndex, count: 0)
                        }
                    }
                }
            }
        }
    }
    
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
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200"
                    {
                        self.collectionView.reloadData()
                        let message = dict[kMessage]
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                        })
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

extension FROfferViewController {
    
    //Create and Share URL
    func createURLWithString(dict: [String: AnyObject]) -> URL? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https";
        urlComponents.host = "frinck.page.link";
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        // add params
        let offerid  = String(dict["offerId"] as! Int)
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

extension FROfferViewController: SJSegmentedViewControllerViewSource {
    
    func viewForSegmentControllerToObserveContentOffsetChange() -> UIView {
        return collectionView
    }
}
