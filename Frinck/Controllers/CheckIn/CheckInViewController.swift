//
//  CheckInViewController.swift
//  Frinck
//
//  Created by vineet patidar on 17/05/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import CoreLocation
import GradientProgress

class CheckInViewController: UIViewController {
    
    @IBOutlet var noRecordView: UIView!
    @IBOutlet var checkInTable: UITableView!
    
    @IBOutlet weak var slider: GradientProgressBar!
    var loginInfoDictionary :NSMutableDictionary!
    var storeList = [[String:Any]]()
    var pageIndex = 1
    var titleView : TitleView!
    var totalCount = 0
    var checkInPoints : NSNumber = 0

    @IBOutlet var btnMyCheckin: UIButton!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    checkInTable.register(UINib(nibName: "CheckInCell", bundle: nil), forCellReuseIdentifier: "cell")
        
//        pointSlider.setMaximumTrackImage(#imageLiteral(resourceName: "sliderW"), for: .normal)
//        pointSlider.setMinimumTrackImage(#imageLiteral(resourceName: "sliderR"), for: .normal)
    }
    
  override func viewWillAppear(_ animated: Bool) {
    loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
    if CLLocationManager.locationServicesEnabled() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            self.checkInTable.isHidden = true
            self.noRecordView.isHidden = true
            self.btnMyCheckin.isHidden = true
            alertController(controller: self, title: "", message: "Please make sure your location is on so that nearby store can be shown.", okButtonTitle: "Ok") { (value) in
                self.tabBarController?.selectedIndex = 0
            }
            return
        case .authorizedAlways, .authorizedWhenInUse:
            print("Access")
        }
    } else {
        alertController(controller: self, title: "", message: "", okButtonTitle: "Ok") { (value) in
            self.checkInTable.isHidden = true
            self.btnMyCheckin.isHidden = true
            return
        }
    }
    
        getStoreList()
    }

    @IBAction func myCheckInButtonAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: kmyCheckInSegueIdentifier, sender:nil)
    }
    @IBAction func viewMoreOfferButtonAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == kstatusSegueIdentifier {
            let statusViewController : CheckInStatusViewController = (segue.destination as? CheckInStatusViewController)!
            statusViewController.selectedDictioinary = sender as! [String : Any]
            let message   = "You got \(checkInPoints) points on check-in"
            statusViewController.showMsg = message
            statusViewController.isMyCheckin = false
            statusViewController.checkinPoints = checkInPoints
        }
    }
    
    //MARK: - API Call
    
    func getStoreList()
    {
        let appDelegate : AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        
        var cityId : Int = 0
        if let cityid = loginInfoDictionary[kCityId] as? Int {
            cityId =  cityid
        } else {
            cityId = Int(loginInfoDictionary[kCityId] as! String)!
        }
        
        var params: NSMutableDictionary = [:]
        params = [  kCustomerId : loginInfoDictionary[kCustomerId]!,
            kCityId : cityId,
            kLatitude : appDelegate.lat,
            kLongitude : appDelegate.long,
            kpageNo : pageIndex
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kcheckingetstore))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            self.totalCount = payload["total"] as! Int
                            if self.pageIndex == 1 {
                                self.storeList = payload["storeList"] as! [[String : Any]]
                            } else {
                                let addMoreArray = payload["storeList"] as! [[String : Any]]
                                self.storeList.append(contentsOf: addMoreArray)
                            }
                            let Level : Int = (payload[kCustomerLevel] as? Int)!
                            let point : Int = (payload[kCustomerPoint] as? Int)!
                            self.pointLabel.text = "\(point) Points"
                            self.levelLabel.text = "Level \(Level)"
//                           let total = payload["totalLevel"] as! Int
//                            let avg = Level/total * 100
//                            self.pointSlider.minimumValue = 0
//                            self.pointSlider.maximumValue = Float(total)
                            self.slider.progress = Float(Level)
//                            self.titleView.setTitleData(point: String(point), level: String(Level))
                        }
                        
                        if self.storeList.count == 0 {
                            self.noRecordView.isHidden = false
                            self.checkInTable.isHidden = true
                            self.btnMyCheckin.isHidden = false
                        } else {
                            self.noRecordView.isHidden = true
                            self.checkInTable.isHidden = false
                            self.btnMyCheckin.isHidden = false
                            self.checkInTable.reloadData()
                        }
                    }
                    else
                    {
                       // let message = dict[kMessage]
                        self.noRecordView.isHidden = false
                        self.checkInTable.isHidden = true
//                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
//
//                        })
                        
                    }
                }
            }
        }
    }
    
    func checkInConfirmation( storeId : String, selectedDict : Dictionary <String, Any>){
        let appDelegate : AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            "latitude" : appDelegate.lat,
            "longitude" : appDelegate.long,
            kStoreId : storeId,
            "checkinBy" : "Manual",
            "checkinType" : "",
            "beaconUid" : ""
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kcheckinconfirmation))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        
                        let dict : [String :Any] = dict.value(forKey: kPayload) as! [String : Any]
                        
                        self.checkInPoints = dict["StoreCheckinPoint"] as! NSNumber
                        self.performSegue(withIdentifier: kstatusSegueIdentifier, sender: selectedDict)
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

extension CheckInViewController : UITableViewDataSource{
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if totalCount > storeList.count {
            if maximumOffset - currentOffset <= -40 && storeList.count != 0 && storeList.count%10 == 0 {
                pageIndex = pageIndex + 1
                getStoreList()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CheckInCell
        cell?.selectionStyle = .none
        cell?.setData(dict: storeList[indexPath.row])
        return cell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storeList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let storeName = storeList[indexPath.row][kStoreName] as? String
        
        let height = Float((storeName?.height(withConstrainedWidth: ScreenSize.width - 147, font: UIFont(name: kFontTextRegularBold, size: 13)!))!)
          if height > 32{
            return CGFloat(height + 62)
        }
        return 80
    }

}

extension CheckInViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storeName = self.storeList[indexPath.row][kStoreName] as? String
        let storeImage = self.storeList[indexPath.row][kBrandLogo] as? String
        let isCheckIn = self.storeList[indexPath.row][kIsCheckIn] as? Bool
        if isCheckIn! {
            return
        }
        
        let viewAlert = CustomAlert(frame: self.view.bounds)
        viewAlert.loadView(customType: .TwoButton, strMsg: "Please confirm if you are at \(storeName ?? "") and wanna check in", type: .select ,url: storeImage!, image: #imageLiteral(resourceName: "followers")) { (success) in
            if let isSucess = success as? Bool, isSucess == true {
                let storeID : Int = (self.storeList[indexPath.row][kStoreId] as? Int)!
                self.checkInConfirmation(storeId:String(storeID), selectedDict: self.storeList[indexPath.row])
                viewAlert.removeFromSuperview()
            } else {
                viewAlert.removeFromSuperview()
            }
        }
        let window = UIApplication.shared.keyWindow!
        window.addSubview(viewAlert)
    }
}
