
import UIKit
import SJSegmentedScrollView

class FROfferSegmentViewController: SJSegmentedViewController {

    var allViewController : FROfferViewController!
    var onlineViewController : FROfferViewController!
    var offlineViewController : FROfferViewController!
    var headerView: OfferBannerViewC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OfferGetBrand()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    func setUp(imgUrl: String) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        headerView = OfferBannerViewC(nibName: "OfferBannerViewC", bundle: nil)
        headerView?.imgBannerOffer = imgUrl
        // All
        allViewController = storyboard
            .instantiateViewController(withIdentifier: kofferStoryboardID) as! FROfferViewController
//        allViewController.bannerImageView = headerView.imgBanner
        allViewController.title = "ALL"
        
        // Online
        onlineViewController = storyboard
            .instantiateViewController(withIdentifier: kofferStoryboardID) as! FROfferViewController
//        onlineViewController.bannerImageView = headerView.imgBanner
        onlineViewController.title = "ONLINE"
        
        // Off line
        offlineViewController = storyboard
            .instantiateViewController(withIdentifier: kofferStoryboardID) as! FROfferViewController
//        offlineViewController.bannerImageView = headerView.imgBanner
        offlineViewController.title = "OFFLINE"
        
        let segmentController = SJSegmentedViewController()
        segmentController.headerViewController = headerView
        segmentController.delegate = self
        segmentController.segmentControllers = [allViewController,onlineViewController,offlineViewController]
        segmentController.headerViewHeight = 158.0
        segmentController.selectedSegmentViewColor = kRedColor
        addChildViewController(segmentController)
        view.addSubview(segmentController.view)
        segmentController.didMove(toParentViewController: self)
    }
    
    func OfferGetBrand() {
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        let offerType = "All"
        let cityId  = loginInfoDictionary[kCityId]
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId: loginInfoDictionary[kCustomerId]!,
            kLocationId: cityId!,
            kViewType: offerType,
            kpageNo : 1
            
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kOfferGetOffer))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: false,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200"
                    {
                        if let payLoadDictionary = dict.value(forKey: kPayload) as? [String : Any]{
                            
                            let dict = payLoadDictionary[kBanner] as! [String : Any]
                            let bannerUrlString = dict[kimageUrl] as? String
                            self.setUp(imgUrl: bannerUrlString!)
                        }
                    }
                }
            }
        }
    }
}


extension FROfferSegmentViewController: SJSegmentedViewControllerDelegate {
    
    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {
        
        if index == 0 {
            allViewController.OfferGetBrand(type:"all")
        }
        else  if index == 1 {
            onlineViewController.OfferGetBrand(type: konline as NSString)
        }
        else  if index == 2 {
            offlineViewController.OfferGetBrand(type: "offline")
        }
    }
}

