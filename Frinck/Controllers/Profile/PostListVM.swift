//
//  PostListVM.swift
//  Frinck
//
//  Created by meenakshi on 6/6/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import ObjectMapper

protocol PostViewModelling {
    func getUserPostList(param: NSMutableDictionary, postListHandler: @escaping (_ responseData: [PostListModel], _ total: Int, _ success: Bool, _ message: String)-> Void)
    func deleteStory(storyId: AnyObject, customerId: AnyObject, deleteStoryHandler: @escaping(_ responseData: [String : AnyObject], _ success: Bool, _ msg: String) -> Void)
}


class PostListVM: PostViewModelling {

    func getUserPostList(param: NSMutableDictionary, postListHandler: @escaping (_ responseData: [PostListModel], _ total: Int, _ success: Bool, _ message: String)-> Void) {
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kuserSpecificStory))!
            
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: param) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            let list = payload["userStoryList"] as? [[String : Any]]
                            let postList = Mapper<PostListModel>().mapArray(JSONArray: list!)
                            let total = payload["total"] as! Int
                            postListHandler(postList, total, true, "")
                        }
                    } else {
                        let message = dict[kMessage] as? String
                        postListHandler([], 0, false, message!)
                    }
                }
            }
        }
    }

    func deleteStory(storyId: AnyObject, customerId: AnyObject, deleteStoryHandler: @escaping(_ responseData: [String : AnyObject], _ success: Bool, _ msg: String) -> Void) {
        let params: NSMutableDictionary = [ kCustomerId : customerId,
                                            "StoryId" : storyId ]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kdeleteStory))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        let res = response as! [String : AnyObject]
                        deleteStoryHandler(res, true, "")
                    } else {
                        let message = dict[kMessage] as? String
                        deleteStoryHandler([:], false, message!)
                    }
                }
            }
        }
    }

}
