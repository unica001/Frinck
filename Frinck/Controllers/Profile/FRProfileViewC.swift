
import UIKit
import SJSegmentedScrollView

class FRProfileViewC: SJSegmentedViewController {

    internal var headerView: ProfileHeaderView?
    internal var infoViewC: FRInfoViewC?
    internal var postViewC: FRPostListViewC?
    var selectedSegment: SJSegmentTab?
    let segmentController = SJSegmentedViewController()
    internal var userId: Int? = nil
    var dictProfile = [String : AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dictProfile = [String : AnyObject]()
        profileApiCall()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Private Methods
    private func setUpView() {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        
        headerView = ProfileHeaderView(nibName: "ProfileHeaderView", bundle: nil)
        headerView?.userId = userId
        print(dictProfile)
        headerView?.dictInfo = dictProfile["profileSummary"] as! [String : AnyObject]
        headerView?.dictCustomerLevel = dictProfile["custLevel"] as! [String :AnyObject]
        var strName = ""
        if let name = headerView?.dictInfo["CustomerName"] as? String {
            strName = name
        }
        self.navigationItem.title = (userId == nil) ? "My Profile" : strName

        // info
        infoViewC = storyboard.instantiateViewController(withIdentifier: "FRInfoViewC") as? FRInfoViewC
        infoViewC?.dictInfo = dictProfile["userInfo"] as! [String : AnyObject]
        infoViewC?.userId = userId
        infoViewC?.title = "INFO"
        
        let blockDict  = dictProfile["profileSummary"] as! [String : AnyObject]
        //Post
        postViewC = storyboard.instantiateViewController(withIdentifier: "FRPostListViewC") as? FRPostListViewC
        postViewC?.userId = userId
        postViewC?.isBlock = blockDict["isBlock"] as! Int
        postViewC?.title = "POST"
        
        segmentController.headerViewController = headerView
        segmentController.delegate = self
        segmentController.segmentControllers = (userId == nil) ? [infoViewC!, postViewC!] : [postViewC!]
        segmentController.headerViewHeight = (UIScreen.main.nativeBounds.height == 2436) ? 345 : 315
        segmentController.selectedSegmentViewColor = kRedColor
        segmentController.segmentViewHeight = 50
        segmentController.segmentBackgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1)
        segmentController.segmentTitleColor = .black
        
        
        segmentController.view.frame = CGRect(x: 0, y: 64, width: ScreenSize.width, height: ScreenSize.height - 114)
        addChildViewController(segmentController)
        view.addSubview(segmentController.view)
        segmentController.didMove(toParentViewController: self)
    }

    @IBAction func tapBack(_ sender: Any) {
        if (self.navigationController?.viewControllers.count)! > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            AppDelegate.delegate.goToHomeScreen()
        }
    }
    
    //MARK: - API call
    
    func profileApiCall() {
        var params: NSMutableDictionary = [:]
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        if userId == nil {
            params = [ kCustomerId : loginInfoDictionary[kCustomerId]! as AnyObject]
        } else {
            params = [ kCustomerId : loginInfoDictionary[kCustomerId]! as AnyObject,
                       "ProfileId" : userId as AnyObject]
        }
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kuserProfile))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let list = dict.value(forKey: kPayload) as? [String : Any] {
                            self.dictProfile = list as [String : AnyObject]
                            self.setUpView()
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadHeaderView"), object: nil, userInfo: self.dictProfile)
                        }
                    } else {
                        let message = dict[kMessage] as? String
                        alertController(controller: self, title: "", message: message!, okButtonTitle: "Ok", completionHandler: { (value) in
                        })
                    }
                }
            }
        }
    }
}

extension FRProfileViewC: SJSegmentedViewControllerDelegate {
    
    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {

    }
}
