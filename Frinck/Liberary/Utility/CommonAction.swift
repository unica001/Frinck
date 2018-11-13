//
//  CommonAction.swift
//  Frinck
//
//  Created by Meenkashi on 6/22/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import Firebase


enum StoryActionType {
    case Edit
    case Delete
    case Hide
    case Flag
}

class CommonAction: NSObject {
    
    static let sharedAction = CommonAction()
    class func sharedInst() -> CommonAction {
        return sharedAction
    }
    
    
    func moveToComment(viewC: UIViewController, storyId: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commentView : FRCommentViewController = storyboard.instantiateViewController(withIdentifier: "CommentStoryboardID") as! FRCommentViewController
        commentView.storyId = storyId
        viewC.navigationController?.pushViewController(commentView, animated:true )
    }
    
    func movetoProfile(viewC: UIViewController, dict: PostListModel, logInId: Int) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let profile = storyboard.instantiateViewController(withIdentifier: "FRProfileViewC") as? FRProfileViewC
        if logInId != dict.CustomerId {
            profile?.userId = dict.CustomerId
        }
        viewC.navigationController?.pushViewController(profile!, animated: true)
    }
    
    func shareStory(viewC: UIViewController, dict: PostListModel) {
        let link = createURLWithString(dict: dict)
        createDnamicLink(link: link!, dict: dict, viewC: viewC)
    }
    
    func storyDotAction(dict: PostListModel, logInId: Int, viewC: UIViewController, completion: @escaping( _ success: Bool, _ msg: String, _ action: StoryActionType) -> Void) {
        if logInId == dict.CustomerId {
            self.ownPostDot(dict: dict, logInId: logInId, viewC: viewC, completion: completion)
        } else {
            self.otherUserPost(dict: dict, logInId: logInId, viewC: viewC, completion: completion)
        }
    }
    
    private func ownPostDot(dict: PostListModel, logInId: Int, viewC: UIViewController, completion: @escaping( _ success: Bool, _ msg: String, _ action: StoryActionType) -> Void) {
        let actionSheet = UIAlertController(title: "" , message: "Choose" , preferredStyle: .actionSheet)
        let actionSelectCamera = UIAlertAction(title: "Edit", style: .default, handler: {
            UIAlertAction in
            let sb = UIStoryboard(name: "Home", bundle: nil)
            let editStory = sb.instantiateViewController(withIdentifier: "CreatStoryViewController") as? CreatStoryViewController
            editStory?.isEdit = true
            editStory?.dictStory = dict
            viewC.navigationController?.pushViewController(editStory!, animated: true)
        })
        let actionSelectGallery = UIAlertAction(title: "Delete", style: .default, handler: {
            UIAlertAction in
            self.callApiDeleteStory(dict: dict, logInId: logInId, completion: completion)
        })
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(actionCancel)
        actionSheet.addAction(actionSelectCamera)
        actionSheet.addAction(actionSelectGallery)
        viewC.present(actionSheet, animated: true, completion: nil)
    }
    
    private func otherUserPost(dict: PostListModel, logInId: Int, viewC: UIViewController, completion: @escaping( _ success: Bool, _ msg: String, _ action: StoryActionType) -> Void) {
        let actionSheet = UIAlertController(title: "" , message: "Choose" , preferredStyle: .actionSheet)
        let actionSelectCamera = UIAlertAction(title: "Hide this Story", style: .default, handler: {
            UIAlertAction in
            self.callApiHideStory(dict: dict, logInId: logInId, completion: completion)
        })
        let actionSelectGallery = UIAlertAction(title: "Flag Inappropriate", style: .default, handler: {
            UIAlertAction in
            let sb = UIStoryboard(name: "Profile", bundle: nil)
            let reportViewC = sb.instantiateViewController(withIdentifier: "FRReportViewC") as? FRReportViewC
            reportViewC?.storyId = dict.storyId!
            reportViewC?.userId = dict.CustomerId!
            reportViewC?.isFromReportUser = false
            viewC.navigationController?.pushViewController(reportViewC!, animated: true)
        })
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(actionCancel)
        actionSheet.addAction(actionSelectCamera)
        actionSheet.addAction(actionSelectGallery)
        viewC.present(actionSheet, animated: true, completion: nil)
    }

    private func callApiDeleteStory(dict: PostListModel, logInId: Int, completion: @escaping( _ success: Bool, _ msg: String, _ action: StoryActionType) -> Void) {
        
        let params: NSMutableDictionary = [ kCustomerId : logInId,
                                            "StoryId" : dict.storyId as AnyObject]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kdeleteStory))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        completion(true, "", .Delete)
                    } else {
                        let message = dict[kMessage] as? String
                        completion(false, message!, .Delete)
                    }
                }
            }
        }
    }
    
    private func callApiHideStory(dict: PostListModel, logInId: Int, completion: @escaping( _ success: Bool, _ msg: String, _ action: StoryActionType) -> Void) {
        
        let params: NSMutableDictionary = [ kCustomerId : logInId,
                                            "StoryId" : dict.storyId as AnyObject,
                                            "UserId" : dict.CustomerId!]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kstoryHide))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        completion(true, "", .Hide)
                    } else {
                        let message = dict[kMessage] as? String
                        completion(false, message!, .Hide)
                    }
                }
            }
        }
    }
    
    //Craete and Share URL
    
    func createURLWithString(dict: PostListModel) -> URL? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https";
        urlComponents.host = "frinck.page.link";
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        // add params
        let typeQuery = NSURLQueryItem(name: "link_type", value: "story")
        let storyIdQuery = NSURLQueryItem(name: kStoryId, value: "\(dict.storyId!)")
        let inviteQuery = NSURLQueryItem(name: "invited_by", value: "\(loginInfoDictionary[kCustomerUserName] ?? "")")
        urlComponents.queryItems = [typeQuery as URLQueryItem, storyIdQuery as URLQueryItem, inviteQuery as URLQueryItem]
        return urlComponents.url
    }
    
    func createDnamicLink(link: URL, dict: PostListModel, viewC: UIViewController) {
        let components = DynamicLinkComponents(link: link, domain: "frinck.page.link")
        let iOSParams = DynamicLinkIOSParameters(bundleID: "frinck.com.frinckapp")
        iOSParams.appStoreID = "987654321"
        iOSParams.customScheme = "frinck.com.frinckapp"
        components.iOSParameters = iOSParams

//         Android params
        let androidParams = DynamicLinkAndroidParameters(packageName: "com.frinck")
        components.androidParameters = androidParams
//
//        // social tag params
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        let socialParams = DynamicLinkSocialMetaTagParameters()
//        socialParams.title = topic.topicName
//
        if let name = loginInfoDictionary[kCustomerUserName] {
            socialParams.descriptionText = "\(name) shared you a story."
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
            print(shortLink)
            if let link = shortLink?.absoluteString, link != "" {
                self.sendLink(shortLinkStr: link, viewC: viewC)
            }
        }
    }
    
    func sendLink(shortLinkStr: String, viewC: UIViewController) {
        if let myWebsite = NSURL(string: shortLinkStr) {
            let objectsToShare = [myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            viewC.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func storyVisible(arrVisible: [IndexPath], storyArray: [PostListModel], customerId: Int, isBrand: Bool? = false) {
        var storyId = ""
        for indexPath in arrVisible {
            let dict = (isBrand)! ? storyArray[indexPath.row] : storyArray[indexPath.section]
            if dict.IsView! == 1 {
                return
            }
            storyId = (storyId == "") ? "\(dict.storyId!)" : storyId + ",\(dict.storyId!)"
        }
        print("Visible Rows \(storyId)")
        var params: NSMutableDictionary = [:]
        params = [ kCustomerId : customerId,
                   StoryId : storyId,
        ]
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kuserView))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: false,isAuthentication: false, showSystemError: false, loadingText: false, params: params) { (response: NSDictionary?) in
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
}
