//
//  UserViewModel.swift
//  Frinck
//
//  Created by meenakshi on 6/4/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import Foundation
import ObjectMapper

protocol UserViewModelling {
    func getUserList(pageIndex: AnyObject, strSearch: AnyObject, customerId: AnyObject, userListHandler: @escaping (_ responseData: [UserListModel], _ total: Int, _ success: Bool, _ message: String)-> Void)
    func followRequest(customerId: AnyObject,requestID: AnyObject, isFollow: Bool, unfollowReqHandler: @escaping (_ responseData: [String: AnyObject], _ success:Bool, _ message: String) -> Void)
    func unBlockRequest(customerId: AnyObject, requestId: AnyObject, unblockReqHandler: @escaping(_ responseData: [String : AnyObject], _ success: Bool, _ message: String) -> Void)
}

class UserViewModel: UserViewModelling {
    func getUserList(pageIndex: AnyObject, strSearch: AnyObject, customerId: AnyObject, userListHandler: @escaping (_ responseData: [UserListModel], _ total: Int, _ success: Bool, _ message: String)-> Void) {
        
        let params: NSMutableDictionary = [ kCustomerId : customerId,
                                            "PageNo" : pageIndex,
                                            kSearchKey : strSearch ]
        
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kuserList))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            let list = payload["userList"] as? [[String : Any]]
                            let userList = Mapper<UserListModel>().mapArray(JSONArray: list!)
                            let total = payload["total"] as! Int
                            userListHandler(userList, total, true, "")
                        }
                    } else {
                        let message = dict[kMessage] as? String
                        userListHandler([],0, false, message!)
                    }
                }
            }
        }
    }
    
    func followRequest(customerId: AnyObject,requestID: AnyObject, isFollow: Bool, unfollowReqHandler: @escaping (_ responseData: [String: AnyObject], _ success:Bool, _ message: String) -> Void) {
        let params: NSMutableDictionary = [ kCustomerId : customerId,
                                            kRequestId : requestID ]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,(isFollow) ? kuserFollow : kuserUnfollow))!
        
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
    
    func unBlockRequest(customerId: AnyObject, requestId: AnyObject, unblockReqHandler: @escaping(_ responseData: [String : AnyObject], _ success: Bool, _ message: String) -> Void) {
        let params: NSMutableDictionary = [ kCustomerId : customerId,
                                            "userId" : requestId]
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kUnblockUser))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    let message = dict[kMessage] as? String
                    if index == "200" {
                        let res = response as! [String : AnyObject]
                        unblockReqHandler(res, true, "")
                    } else {
                        let message = dict[kMessage] as? String
                        unblockReqHandler([:], false, message!)
                    }
                }
            }
        }
    }
    
}
