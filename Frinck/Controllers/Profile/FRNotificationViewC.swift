//
//  FRNotificationViewC.swift
//  Frinck
//
//  Created by meenakshi on 6/7/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class FRNotificationViewC: UIViewController {

    @IBOutlet weak var switchBrand: UISwitch!
    @IBOutlet weak var switchOffers: UISwitch!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        callApiNotification()
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

    //MARK: - IBAction Methods
    @IBAction func tapBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapBrand(_ sender: UISwitch) {
        switchBrand.isOn = !switchBrand.isOn
        apiCallSetNotification(brand: switchBrand.isOn, offer: switchOffers.isOn)
    }
    
    @IBAction func tapSaved(_ sender: UISwitch) {
        switchOffers.isOn = !switchOffers.isOn
        apiCallSetNotification(brand: switchBrand.isOn, offer: switchOffers.isOn)
    }
    
    //MARK: - API Call
    
    func callApiNotification() {
        var params: NSMutableDictionary = [:]
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        params = [ kCustomerId : loginInfoDictionary[kCustomerId]! as AnyObject]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kgetNotification))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let list = dict.value(forKey: kPayload) as? [String : Any] {
                            if let brand = list["BrandNotification"] as? Int {
                                self.switchBrand.isOn = (brand == 1) ? true : false
                            }
                            if let offer = list["SavedOffer"] as? Int {
                                self.switchOffers.isOn = (offer == 1) ? true : false
                            }
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
    
    func apiCallSetNotification(brand: Bool, offer: Bool) {
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,ksetNotification))!
        var params: NSMutableDictionary = [:]
       
        params = [ kCustomerId : loginInfoDictionary[kCustomerId]!,
                       kBrandNotification : brand,
                       kSavedOfferNotification : offer]
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            
                        }
                    } else {
                        
                    }
                }
            }
        }
    }
}
