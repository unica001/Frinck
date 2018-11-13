


import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import IQKeyboardManagerSwift
import CoreLocation
import AWSCore
import AWSS3
import MoEngage
import Quickblox
import Firebase
import FirebaseDynamicLinks
import Reachability
import CoreLocation
import FrinckPod_iOS
import CoreBluetooth

let kQBApplicationID:UInt = 72099
let kQBAuthKey = "8tkqWpSQAQQRfX8"
let kQBAuthSecret = "vk66jRZexnXxuLK"
let kQBAccountKey = "tcVWYpeyVrnqPVJeex8A"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate,UNUserNotificationCenterDelegate,MessagingDelegate,LNBeaconDataManagerDelegate,CBCentralManagerDelegate {

    class var delegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var userType : String = String()
    var lat : Double = Double()
    var long : Double = Double()
    var reachability: Reachability!
    
    var locationManager : CLLocationManager!
    var currentLocation :CLLocation!
    var shouldAutorotate = false
    var window: UIWindow?
    var deviceToken  : String = String()
    var quickBloxId : Int = 0
    
    var arrBeacons = [BeaconData]()
    let beaconManager = LNBeaconDataManager.sharedInstance
    let beacondata = LNBeaconManager.sharedInstance
    var manager : CBCentralManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UITabBar.appearance().tintColor = kRedColor
        UINavigationBar.appearance().tintColor  = .white
        IQKeyboardManager.sharedManager().enable = true
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.black], for: .normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : kRedColor], for: .selected)
        
        // Set QuickBlox credentials (You must create application in admin.quickblox.com).
        QBSettings.applicationID = kQBApplicationID;
        QBSettings.authKey = kQBAuthKey
        QBSettings.authSecret = kQBAuthSecret
        QBSettings.accountKey = kQBAccountKey
        // enabling carbons for chat
        QBSettings.carbonsEnabled = true
        // Enables Quickblox REST API calls debug console output.
        QBSettings.logLevel = .debug
        
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
        
        // fb login
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // google login
        GIDSignIn.sharedInstance().clientID = "233657812355-ohftsihji48et0oqod4mh34tdurfik84.apps.googleusercontent.com"
        
        if (kUserDefault.value(forKey: kloginInfo) != nil) {
            self.autoLogin()
        }
        
        UIBarButtonItem.appearance().tintColor = UIColor.white
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.getCurrentLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidChangeFullscreenMode), name: .playerDidChangeFullscreenMode, object: nil)
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "frinck.com.frinckapp"
        FirebaseApp.configure()
        // DB Manager
        copyFile("Frinck.sqlite")
        
        reachability = Reachability.forInternetConnection()
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: reachability)
        reachability.startNotifier()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        let userData = ["client_id" : "101", "first_name" : "Tim", "last_name" : "Cook"]
        beacondata.passUserData(userData: userData)
        
        beacondata.delegateManager = self
        // Give Permission of Bluetooth
        let opts = [CBCentralManagerOptionShowPowerAlertKey: false]
        manager = CBCentralManager(delegate: self, queue: nil, options: opts)
        beaconManager.delegate = self
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("Will Resign Active")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        ServicesManager.instance().chatService.disconnect(completionBlock: nil)
        print("applicationDidEnterBackground")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        ServicesManager.instance().chatService.connect(completionBlock: nil)
        print("applicationWillEnterForeground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        ServicesManager.instance().chatService.disconnect(completionBlock: nil)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        GIDSignIn.sharedInstance().handle(url as URL?,
                                          sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            
            print(dynamicLink)
            return true
        } else {
            return GIDSignIn.sharedInstance().handle(url as URL?,
                                                     sourceApplication: sourceApplication,
                                                     annotation: annotation)
        }
        
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
      
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { [weak self](dynamiclink, error) in
            guard self != nil else { return }
            print(dynamiclink ?? "")
            if dynamiclink != nil {
                self!.dynamicLinkHandle(dynamicLink: dynamiclink!)
            }
        }
        return handled
    }
    
    //MARK: - Methods
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        if reachability.isReachable() {
            if kUserDefault.value(forKey: kloginInfo) != nil {
                getPostStoryDataFromDB()
            }
        } else {
            print("Not reachable")
        }
    }
    
    // MARK synck data from Story databse for upload on server
    
    func getPostStoryDataFromDB(){
        let postStoryArray = getStoryData()
        
        for  dict : [String :Any] in postStoryArray {
            
            let storeId : String = (dict["storeId"] as? String)!
            let customerId : String = (dict["customerId"] as? String)!
            let description : String = (dict["description"] as? String)!
            let brandId : String = (dict["brandId"] as? String)!
            
            let mediaType : String = (dict["mediaType"] as? String)!

            if mediaType == "image" {
                let image = (dict["image"] as? UIImage)!
                let url : URL = saveImageInDirectory(image: image)
                NetworkManager.sharedInstance.uploadImageOnS3( url, fileName: getFileName(), hude: true, fromView: "creatStory", completionHandler: { (responce : String) in
                    DispatchQueue.main.async {
                        self.postStory(customerId: customerId, responce, brandId, storeId, description, mediaType)
                    }
                })
            } else /*if mediaType == "video"*/ {
                let data = (dict["data"] as? Data)!
                let url : URL = saveVideoInDirectory(data: data)
                NetworkManager.sharedInstance.uploadImageOnS3( url, fileName: getFileName(), hude: true, fromView: "creatStory", completionHandler: { (responce : String) in
                    DispatchQueue.main.async {
                        self.postStory(customerId: customerId, responce, brandId, storeId, description, mediaType)
                    }
                })
            }
        }
        
         do {
            deleteStoryDataFromDatabase()
        }
    }
    
    
    func saveImageInDirectory(image : UIImage) -> URL{
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(getFileName()).jpeg")
        let imageData = UIImageJPEGRepresentation(image, 0.99)
        fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
        
        let url : URL = URL(fileURLWithPath: path)
        return url
    }
    
    func saveVideoInDirectory(data: Data) -> URL {
        
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(getFileName()).mp4")
        
        if let videoData = data as? NSData{
            videoData.write(toFile: path, atomically: false)
        }
        return NSURL(fileURLWithPath: path) as URL
    }
    
    func getFileName()-> String {
        let date = Date()
        let interval = date.timeIntervalSince1970
        return String(interval)
    }
    
  @objc func playerDidChangeFullscreenMode(_ notification: Notification) {
        guard let isFullscreen = notification.object as? Bool else {
            return
        }
        shouldAutorotate = isFullscreen
        if !shouldAutorotate {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
    func autoLogin(){
    
    // set auto login data
        let loginInfoDictionary  = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
    
        if (loginInfoDictionary.value(forKey: kCustomerUserName) != nil)
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "FRSplashScreen")
            self.window?.rootViewController?.navigationController?.pushViewController(initialViewController, animated: true)
        }
    }
    
    func dailyCheckInApi() {
        let dailyCheckinTime = Date().toMillis()
        if (kUserDefault.value(forKey: kloginInfo) != nil) {
             let loginInfoDictionary  = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
            var params: NSMutableDictionary = [:]
            params = [
                kCustomerId : loginInfoDictionary[kCustomerId]!,
                "AppCheckinTime" : dailyCheckinTime ?? 0.0
            ]
            print(params)
            let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kdailyCheckIn))!
            
            NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
                if (response != nil) {
                    
                    DispatchQueue.main.async {
                        let dict  = response!
                        print(dict)
                        let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                        if index == "200" {

                        }
                        else
                        {
                            let message = dict[kMessage]

                        }
                    }
                }
            }
        }
    }

    //MARK: - Firebase messaging
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
         self.deviceToken = String(fcmToken)
    }
    
    private func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    @available(iOS 10, *)
    internal func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        if let aps = userInfo["aps"] as? [String : AnyObject] {
            if let alert = aps["alert"] as? [String : AnyObject] {
                if let type = userInfo["gcm.notification.type"] as? String {
                    if type == "checkin" || type == "story"{
                        return
                    }
                }
                alertController(controller: (UIApplication.shared.keyWindow?.rootViewController)!, title: "", message: "\(alert["body"]!)", okButtonTitle: "OK", completionHandler: {(index) -> Void in
                        self.setRootForNotification(userInfo: userInfo as! [String : AnyObject])
                })
            }
        }
        completionHandler([])
    }
    
    internal func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification \(userInfo)")
        if let aps = userInfo["aps"] as? [String : AnyObject] {
            if let alert = aps["alert"] as? [String : AnyObject] {
                setRootForNotification(userInfo: userInfo)
            }
        }
        completionHandler()
    }
    
    func setRootForNotification(userInfo: [AnyHashable : Any]) {
        if let type = userInfo["gcm.notification.type"] as? String {
            print(type)
            if type == "follow" {
                if let window = self.window, let rootTabController = window.rootViewController as? UITabBarController, let nacViewC = rootTabController.selectedViewController as? UINavigationController {
                    let otherUserId = userInfo["gcm.notification.userId"] as? String
                    let otherProfile = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "FRProfileViewC") as? FRProfileViewC
                    otherProfile?.userId = Int(otherUserId!)
                    nacViewC.pushViewController(otherProfile!, animated: true)
                }
            } else if type == "checkin" {
                if let window = self.window, let rootTabController = window.rootViewController as? UITabBarController, let nacViewC = rootTabController.selectedViewController as? UINavigationController {
                    if nacViewC.visibleViewController is CheckInStatusViewController {
                        return
                    }
                    let checkin = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "CheckInStatusViewController") as? CheckInStatusViewController
                    checkin?.isMyCheckin = true
                    nacViewC.pushViewController(checkin!, animated: true)
                }
            } else if type == "story" {
                if let window = self.window, let rootTabController = window.rootViewController as? UITabBarController, let nacViewC = rootTabController.selectedViewController as? UINavigationController {
                    if nacViewC.visibleViewController is MyCheckInViewController {
                        return
                    }
                    let checkin = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "MyCheckInViewController") as? MyCheckInViewController
                    nacViewC.pushViewController(checkin!, animated: true)
                }
            } else if type == "comment" {
                let storyId = userInfo["gcm.notification.storyId"] as? String
                if let window = self.window, let rootTabController = window.rootViewController as? UITabBarController, let nacViewC = rootTabController.selectedViewController as? UINavigationController {
                    if nacViewC.visibleViewController is FRCommentViewController {
                        return
                    }
                    let comment = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CommentStoryboardID") as? FRCommentViewController
                    comment?.storyId = Int(storyId!)
                    comment?.hidesBottomBarWhenPushed = true
                    nacViewC.pushViewController(comment!, animated: true)
                }
            } else if type == "offer" {
                let offerId = userInfo["gcm.notification.offerId"] as? String
                if let window = self.window, let rootTabController = window.rootViewController as? UITabBarController, let nacViewC = rootTabController.selectedViewController as? UINavigationController {
                    if nacViewC.visibleViewController is FROfferDetailedViewController {
                        return
                    }
                    let offerDetail = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "FROfferDetailedViewController") as? FROfferDetailedViewController
                    offerDetail?.offerId = Int(offerId!)!
                    offerDetail?.hidesBottomBarWhenPushed = true
                    nacViewC.pushViewController(offerDetail!, animated: true)
                }
            } else if type == "level" {
                if let window = self.window, let rootTabController = window.rootViewController as? UITabBarController, let nacViewC = rootTabController.selectedViewController as? UINavigationController {
                    if nacViewC.visibleViewController is FRCustomerLevelViewC {
                        return
                    }
                    let offerDetail = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "FRCustomerLevelViewC") as? FRCustomerLevelViewC
                    nacViewC.pushViewController(offerDetail!, animated: true)
                }
            }
        }
    }
    
    
    //MARK: - Methods
    func dynamicLinkHandle(dynamicLink: DynamicLink) {
        let url = dynamicLink.url?.absoluteString
        let linkType = getQueryStringParameter(url: url!, param: "link_type")
        if linkType == "story" {
            let storyId = getQueryStringParameter(url: url!, param: kStoryId)
            pushToStoryDetail(storyId: storyId!)
        } else if linkType == "offer" {
            let offerId = getQueryStringParameter(url: url!, param: kOfferId)
            pushToOfferDetail(offerId: offerId!)
        }
    }
    
    func pushToStoryDetail(storyId: String) {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        if let storyViewC = storyBoard.instantiateViewController(withIdentifier: "FrStoryDetailViewC") as? FrStoryDetailViewC {
            storyViewC.storyId = Int(storyId)!
            let navigation = UINavigationController(rootViewController: storyViewC)
            self.window?.rootViewController = nil
            self.window?.rootViewController = navigation
        }
    }
    
    func pushToOfferDetail(offerId: String) {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        if let offerViewC = storyBoard.instantiateViewController(withIdentifier: "FROfferDetailedViewController") as? FROfferDetailedViewController {
            offerViewC.offerId = Int(offerId)!
            let navigation = UINavigationController(rootViewController: offerViewC)
            self.window?.rootViewController = nil
            self.window?.rootViewController = navigation
        }
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func goToHomeScreen(){
        // set auto login data
        
        if kUserDefault.value(forKey: kloginInfo) != nil {
            let loginInfoDictionary  = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
            
            
            let cityId = loginInfoDictionary.value(forKey: kCityId) as? Int ?? 0
            
            if (loginInfoDictionary.value(forKey: kCustomerUserName) != nil && cityId != 0)
            {
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "tabbarController")
                if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
                    window.rootViewController = initialViewController
                }
            }
        } else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewC = storyboard.instantiateViewController(withIdentifier: "FRWelcomeViewController")
            let navigation = UINavigationController(rootViewController: viewC)
            self.window?.rootViewController = nil
            self.window?.rootViewController = navigation
        }
        
    }
    
    //MARK: - Location
    func getCurrentLocation(){
        if CLLocationManager.locationServicesEnabled() {            switch(CLLocationManager.authorizationStatus()) {
        case  .denied:
            
            alertController(controller: (self.window?.rootViewController)!, title: "", message: "Enable location from your device Settings", okButtonTitle: "SETTINGS", cancelButtonTitle: "CANCEL", completionHandler: {(index) -> Void in
                
                if index == 1 {
                    let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                    UIApplication.shared.open(settingsUrl! as URL, options: [:], completionHandler: nil)
                }
            })
            
        case .authorizedAlways, .authorizedWhenInUse:
            print("Access")
            
        case .notDetermined:
            print("notDetermined")
            
            
        case .restricted:
            print("restricted")
            
            }
        }
        
        self.getLocation()
    }
    
    // MARK :- Location Manager
    
    func getLocation() -> Void {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        locationManager.stopUpdatingLocation()
        currentLocation = locations.last! as CLLocation
         lat = currentLocation.coordinate.latitude
         long = currentLocation.coordinate.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("1")
            manager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            print("2")
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            print("3")
            manager.startUpdatingLocation()
            break
        case .restricted:
            print("4")
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            print("5")
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if shouldAutorotate {
            return .all
        } else {
            return .portrait
        }
    }
    
    // MARK POSt Story Data on server
    
    func postStory( customerId : String, _ uploadUrlString : String,_ brandID : String ,_ storeId : String, _ description : String, _ mediaType : String){
        
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : customerId,
            kBrandId : String(brandID),
            kStoreId : String(storeId),
            kMediaUrl : uploadUrlString,
            kType : "public",
            kTitle : "iOS",
            kMediaType : mediaType,
            kDescription : description
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kcheckinpoststory))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {

                    } else {
                    }
                }
            }
        }
    }
    
    // MARK : - Beacon Functionality
    
    func didReceiveBeaconData(data: AnyObject?)  {
        arrBeacons = data as! [BeaconData]
        
        let obj = self.arrBeacons[0]
        let data = ["data": ["beacon_id": obj.id , "link":obj.link, "type":"2"]]
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        let userData = ["client_id" : "101",
                        "first_name" : "Tim",
                        "last_name" : "Cook"]
        
        switch central.state {
        case .resetting:
            print(" State : Resetting")
            break
            
        case .poweredOn:
            beacondata.startToRange()
            beaconManager.foundBeacons()
            beaconManager.startTimer()
            beacondata.passUserData(userData: userData)
            
        case .poweredOff:
            print("State : Powered Off")
            fallthrough
            
        case .unauthorized:
            print("State : Unauthorized")
            fallthrough
            
        case .unknown:
            print("State : Unknown")
            fallthrough
            
        case .unsupported:
            print("State : Unsupported")
        }
        
    }
    
    //    func storeDetectData() -> [BeaconData]? {
    //        let obj = arrBeacons
    //        beacondata.storeData(data: arrBeacons)
    //        return obj
    //    }
    
    func getNotification() {
        print("Your Notification Code")
        // Your Notification Code
    }
    
    func didRangeBeacons(beacons: [CLBeacon], in_region: CLBeaconRegion) {
        print("Ranging Beacon \(beacons)")
    }
    
    func didEnterRegion(monitor: LNBeaconManager, region: CLRegion) {
        print("Enter Region \(region)")
        
        let major : NSInteger =  region.value(forKey: "major") as! NSInteger
        let minor : NSInteger =  region.value(forKey: "minor") as! NSInteger
        let identifierString : String = region.identifier
        getBeaconsDetails(uuid: identifierString, major: String(major), minor: String(minor), checkinType: "In")

    }
    
    func didExitRegion(_ monitor: LNBeaconManager, region: CLRegion) {
        print("Exit Region \(region)")
        
        let major : NSInteger =  region.value(forKey: "major") as! NSInteger
        let minor : NSInteger =  region.value(forKey: "minor") as! NSInteger
        
        let identifierString : String = region.identifier
        getBeaconsDetails(uuid: identifierString, major: String(major), minor: String(minor), checkinType:"Out")
    }
    
    func didChangeAuthorizationStatus(monitor: LNBeaconManager, status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            beacondata.startToUpdateLocation()
            
        default:
            print("default")
        }
    }
    
    func getBeaconsDetails( uuid : String,major : String, minor : String, checkinType : String){
        

        var params: NSMutableDictionary = [:]
        params = [
            "beacon_id" : "",
            "beacon_unique_id" : "",
            "uuid" : uuid,
            "major":major,
            "minor" : minor
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,"beacon/getbeacondetail"))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!

                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            
                            let store_id : NSInteger =  payload["store_id"] as! NSInteger
                            let beaconUid : String =  payload["beaconUid"] as! String
                            
                            self.checkInConfirmation(storeId: String(store_id), beaconUid: String(beaconUid), checkinType: checkinType)
                        }
                    }
                }
            }
        }
    }
    
    
    func checkInConfirmation( storeId : String, beaconUid : String, checkinType : String){
      let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            "latitude" : "",
            "longitude" : "",
            kStoreId : storeId,
            "checkinBy" : "Beacon",
            "checkinType" : checkinType,
            "beaconUid" : beaconUid
            
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kcheckinconfirmation))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                    }
                }
            }
        }
    }
}

