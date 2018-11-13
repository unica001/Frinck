//
//  FollowViewModel.swift
//  Frinck
//
//  Created by meenakshi on 6/4/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import Foundation
import ObjectMapper

protocol FollowViewModelling {
    func getFollowList(pageIndex: AnyObject, strSearch: AnyObject, customerId: AnyObject, isFollowers: Bool, followListHandler: @escaping (_ responseData: [UserListModel], _ total: Int, _ success: Bool, _ messgae: String)-> Void)
    func unfollowRequest(customerId: AnyObject,requestID: AnyObject, unfollowReqHandler: @escaping (_ responseData: [String: AnyObject], _ success: Bool, _ messgae: String) -> Void)
    func removeRequest(customerId: AnyObject,requestID: AnyObject, unfollowReqHandler: @escaping (_ responseData: [String: AnyObject], _ success: Bool, _ messgae: String) -> Void)
}


class FollowViewModel: FollowViewModelling {
    
    func getFollowList(pageIndex: AnyObject, strSearch: AnyObject, customerId: AnyObject, isFollowers: Bool , followListHandler: @escaping (_ responseData: [UserListModel], _ total: Int, _ success: Bool, _ messgae: String)-> Void) {
        
        let params: NSMutableDictionary = [ kCustomerId : customerId,
                                            "PageNo" : pageIndex,
                                            kSearchKey : strSearch ]
        
        let apiName = (isFollowers) ? kgetfollowers : kgetfollowing
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,apiName))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            if isFollowers {
                                let list = payload["followerList"] as? [[String : Any]]
                                let suggestedList = Mapper<UserListModel>().mapArray(JSONArray: list!)
                                let total = payload["total"] as! Int
                                followListHandler(suggestedList, total, true, "")
                            } else {
                                let list = payload["followingList"] as? [[String : Any]]
                                let suggestedList = Mapper<UserListModel>().mapArray(JSONArray: list!)
                                followListHandler(suggestedList, 0, true, "")
                            }
                           
                        }
                    } else {
                        let message = dict[kMessage] as? String
                        followListHandler([], 0, false, message!)
                    }
                }
            }
        }
    }

    func unfollowRequest(customerId: AnyObject,requestID: AnyObject, unfollowReqHandler: @escaping (_ responseData: [String: AnyObject], _ success: Bool, _ messgae: String) -> Void) {
        let params: NSMutableDictionary = [ kCustomerId : customerId,
                                            kRequestId : requestID ]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kuserUnfollow))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        let res = response as! [String : AnyObject]
                        unfollowReqHandler(res, true, "")
                    } else {
                        let message = dict[kMessage] as? String
                        unfollowReqHandler([:], false, message!)
                    }
                }
            }
        }
    }
    
    func removeRequest(customerId: AnyObject,requestID: AnyObject, unfollowReqHandler: @escaping (_ responseData: [String: AnyObject], _ success: Bool, _ messgae: String) -> Void) {
        let params: NSMutableDictionary = [ kCustomerId : customerId,
                                            kRequestId : requestID ]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kremovefollower))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        let res = response as! [String : AnyObject]
                        unfollowReqHandler(res, true, "")
                    } else {
                        let message = dict[kMessage] as? String
                        unfollowReqHandler([:], false, message!)
                    }
                }
            }
        }
    }
    
   
}

