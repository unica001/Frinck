//
//  FRMoreViewC.swift
//  Frinck
//
//  Created by meenakshi on 5/29/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

enum More: Int {
    case MyProfile = 0
    case MyMessage
    case ViewStory
    case CustomerLevel
    case MySavedOffer
    case InviteFriends
    case AboutUs
    case TermsCondition
    case PrivacyPolicy
    case Refund
    case Notification
    case ChangePassword
    case Help
    case RateApp
    case SignOut
}

class FRMoreViewC: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate, QMChatConnectionDelegate, QMChatServiceDelegate, QMAuthServiceDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    //
    var offerType : NSString = ""
    let moreArray = [["type" : More.MyProfile.rawValue ,"moreText": "My Profile", "moreImage" : #imageLiteral(resourceName: "MyProfile")],["type" : More.MyMessage.rawValue ,"moreText": "My Message", "moreImage" : #imageLiteral(resourceName: "MyMessages")],["type" : More.ViewStory.rawValue ,"moreText": "My Stories", "moreImage" : #imageLiteral(resourceName: "story-posting")], ["type" : More.CustomerLevel.rawValue ,"moreText": "Customer Level", "moreImage" : #imageLiteral(resourceName: "CustomerLevel")], ["type" : More.MySavedOffer.rawValue ,"moreText": "My Saved Offers", "moreImage" : #imageLiteral(resourceName: "SavedOffers")], ["type" : More.InviteFriends.rawValue ,"moreText": "Invite Friends", "moreImage" : #imageLiteral(resourceName: "InviteFriends")],["type" : More.AboutUs.rawValue ,"moreText": "About Us", "moreImage" : #imageLiteral(resourceName: "aboutMore")], ["type" : More.TermsCondition.rawValue ,"moreText": "Terms and Conditions", "moreImage" : #imageLiteral(resourceName: "T&C")], ["type" : More.PrivacyPolicy.rawValue ,"moreText": "Privacy Policy", "moreImage" : #imageLiteral(resourceName: "PrivacyPolicy")], ["type" : More.Refund.rawValue ,"moreText": "Refund", "moreImage" : #imageLiteral(resourceName: "Refund")], ["type" : More.Notification.rawValue ,"moreText": "Notifications", "moreImage" : #imageLiteral(resourceName: "Notification-1")], ["type" : More.ChangePassword.rawValue ,"moreText": "Change Password", "moreImage" : #imageLiteral(resourceName: "ChangePassword")],  ["type" : More.Help.rawValue ,"moreText": "Help", "moreImage" : #imageLiteral(resourceName: "Help")], ["type" : More.RateApp.rawValue ,"moreText": "Rate App", "moreImage" : #imageLiteral(resourceName: "RateApp")], ["type" : More.SignOut.rawValue ,"moreText": "Sign Out", "moreImage" : #imageLiteral(resourceName: "Signout")]]
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = kLightGrayColor
    }
    
    // MARK:- Collection view Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moreArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MoreCollectionViewCell
        let dict = moreArray[indexPath.row]
        cell.setInitialData(dictionary: dict, isMoreView: true)        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (ScreenSize.width-60)/3, height: 135) // The size of one cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 0, 10) // margin between cells
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let dict = moreArray[indexPath.row]
        let dictType = dict["type"] as! Int
        switch dictType {
        case 0:
            let profile = storyboard.instantiateViewController(withIdentifier: "FRProfileViewC") as? FRProfileViewC
            self.navigationController?.pushViewController(profile!, animated: true)
        case 5:
            let inviteViewC = storyboard.instantiateViewController(withIdentifier: "FRInviteFriendViewC") as? FRInviteFriendViewC
            self.navigationController?.pushViewController(inviteViewC!, animated: true)
        case 1:
            let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
            let dialogsController = storyBoard.instantiateViewController(withIdentifier: "DialogsViewController") as! DialogsViewController
            self.navigationController?.pushViewController(dialogsController, animated: true)
            
        case 4:
            let savedOfferView = storyboard
                .instantiateViewController(withIdentifier: "FRSavedOfferViewC") as! FRSavedOfferViewC
            self.navigationController?.pushViewController(savedOfferView, animated: true)
        case 2:
            let sb = UIStoryboard(name: "Home", bundle: nil)
            let view = sb.instantiateViewController(withIdentifier: "storyStoryboardID") as! FRStoryViewController
            view.isMyStory = true
            self.navigationController?.pushViewController(view, animated: true)
            
        case 3:
            let customerLevelViewC = storyboard.instantiateViewController(withIdentifier: "FRCustomerLevelViewC") as? FRCustomerLevelViewC
            self.navigationController?.pushViewController(customerLevelViewC!, animated: true)
            
        case 11:
            let pwdViewC = storyboard.instantiateViewController(withIdentifier: "FRPasswordViewC") as? FRPasswordViewC
            self.navigationController?.pushViewController(pwdViewC!, animated: true)
            
        case 10:
            let notifViewC = storyboard.instantiateViewController(withIdentifier: "FRNotificationViewC") as? FRNotificationViewC
            self.navigationController?.pushViewController(notifViewC!, animated: true)
            
        case 6:
            let webViewC = storyboard.instantiateViewController(withIdentifier: "FRWebViewC") as? FRWebViewC
            webViewC?.strHeader = "About"
            self.navigationController?.pushViewController(webViewC!, animated: true)
            
        case 7:
            let webViewC = storyboard.instantiateViewController(withIdentifier: "FRWebViewC") as? FRWebViewC
            webViewC?.strHeader = "Terms and Conditions"
            self.navigationController?.pushViewController(webViewC!, animated: true)
        case 8:
            let webViewC = storyboard.instantiateViewController(withIdentifier: "FRWebViewC") as? FRWebViewC
            webViewC?.strHeader = "Privacy Policy"
            self.navigationController?.pushViewController(webViewC!, animated: true)
        case 12:
            let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let helpView = homeStoryboard.instantiateViewController(withIdentifier: "HelpStoryBoardID") as? HelpViewController
            self.navigationController?.pushViewController(helpView!, animated: true)
            
        case 9:
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let faqViewC = sb.instantiateViewController(withIdentifier: "FAQViewC") as? FAQViewC
            faqViewC?.strHeader = "Refund"
            self.navigationController?.pushViewController(faqViewC!, animated: true)
        case 13:
            let url:URL =  URL(string: "https://itunes.apple.com/us/app/amazon-kindle/id302584613?mt=8")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case 14:
            alertController(controller: self, title: "Logout", message: "Do you want to logout?", okButtonTitle: "Yes", cancelButtonTitle: "Cancel", completionHandler:{(index) -> Void in
                if index == 1 {
                    self.callApiLogout()
                }
            })
        default:
            break
        }
    }
    
    
    func callApiLogout() {
        var params: NSMutableDictionary = [:]
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
            params = [ kCustomerId : loginInfoDictionary[kCustomerId]! as AnyObject]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,klogout))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        AppDelegate.delegate.quickBloxId = 0
                        SVProgressHUD.show(withStatus: "SA_STR_LOGOUTING".localized, maskType: SVProgressHUDMaskType.clear)
                        
                        ServicesManager.instance().logoutUserWithCompletion { [weak self] (boolValue) -> () in
                            
                            guard let strongSelf = self else { return }
                            if boolValue {
                                NotificationCenter.default.removeObserver(strongSelf)
                        ServicesManager.instance().chatService.removeDelegate(strongSelf)
                            ServicesManager.instance().authService.remove(strongSelf)
                            ServicesManager.instance().lastActivityDate = nil;
                                
                                UserDefaults.standard.removeObject(forKey: kloginInfo)
                                AppDelegate.delegate.goToHomeScreen()
                                
                                SVProgressHUD.showSuccess(withStatus: "SA_STR_COMPLETED".localized)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
