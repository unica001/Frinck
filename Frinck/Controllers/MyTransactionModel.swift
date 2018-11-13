//
//  MyTransactionModel.swift
//  Frinck
//
//  Created by vineet patidar on 13/07/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import ObjectMapper

protocol MyTransactionModelling {
    
    func setPayedTransaction(customerId : AnyObject, pageIndex : AnyObject, myTransactionHandelling : @escaping (_ isSuccess : Bool, _ responce : [MyTransactionListModel], _ total : NSInteger) -> Void )
     func getEarnedTransaction(customerId: AnyObject, pageIndex: AnyObject, myEarnedTransactionHandelling: @escaping (Bool, [EarnedPointModel], NSInteger) -> Void)
}

class MyTransactionModel: MyTransactionModelling {
    func setPayedTransaction(customerId: AnyObject, pageIndex: AnyObject, myTransactionHandelling: @escaping (Bool, [MyTransactionListModel], NSInteger) -> Void) {
        
        let params: NSMutableDictionary = [ kCustomerId : customerId,
                                            "PageNo" : pageIndex ]
        
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kpurchasemytransaction))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            let list = payload["transaction"] as? [[String : Any]]
                            let total = payload["total"] as! Int

                            let transactionList   =  Mapper<MyTransactionListModel>().mapArray(JSONArray: list!)
                            myTransactionHandelling(true,transactionList, total)
                        }
                    } else {
                     
                        myTransactionHandelling(false,[], 0)
                    }
                }
            }
        }
    }
   
    func getEarnedTransaction(customerId: AnyObject, pageIndex: AnyObject, myEarnedTransactionHandelling: @escaping (Bool, [EarnedPointModel], NSInteger) -> Void) {
        
        let params: NSMutableDictionary = [ kCustomerId : customerId,
                                            "PageNo" : pageIndex ]
        
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kmyEarned))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            let list = payload["recievedPoint"] as? [[String : Any]]
                            let total = payload["total"] as! Int
                            
                            let List   =  Mapper<EarnedPointModel>().mapArray(JSONArray: list!)
                            myEarnedTransactionHandelling(true,List, total)
                        }
                    } else {
                        
                        myEarnedTransactionHandelling(false,[], 0)
                    }
                }
            }
        }
    }
}
