//
//  RedeemOfferModule.swift
//  Frinck
//
//  Created by vineet patidar on 14/06/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import Foundation
import ObjectMapper


protocol RedeemOfferModelling {
    func getRedeemOfferList(_ customerId : AnyObject ,_ pageIndex : AnyObject, redeemOfferHandelling : @escaping (_ response : RedeemOfferDetailModel, _ success : Bool , _ message : String) -> Void)
    
    func purchasePoint(_ customerId: AnyObject,_ voucherId : AnyObject,_ price:AnyObject, _ point:AnyObject, _ qty : AnyObject, pointPurchaseHandelling : @escaping (_ success : Bool,_ message : String) -> Void)
    
    func purchasePointByCash(_ customerId: AnyObject,_ transictionId : AnyObject,_ voucherId : AnyObject,_ price:AnyObject, _ point:AnyObject, _ qty : AnyObject, pointPurchaseHandelling : @escaping (_ success : Bool,_ message : String) -> Void)
}


class RedeemOfferModule: RedeemOfferModelling {
    
    
    
    func purchasePointByCash(_ customerId: AnyObject, _ transictionId: AnyObject, _ voucherId: AnyObject, _ price: AnyObject, _ point: AnyObject, _ qty: AnyObject, pointPurchaseHandelling: @escaping (Bool, String) -> Void) {
        
        let params: NSMutableDictionary = [ kCustomerId : customerId,
                                            kVoucherId : voucherId,
                                            kPrice : price,
                                            kPoint : point,
                                            kQty : qty,
                                            kTransactionId : transictionId
        ]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kpurchasevoucher))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        let message = dict[kMessage] as? String
                        pointPurchaseHandelling(true, message!)                        }
                    else  {
                        let message = dict[kMessage] as? String
                        pointPurchaseHandelling(false, message!)
                    }
                }
            }
        }
    }
    
   
    
   
    func purchasePoint(_ customerId: AnyObject, _ voucherId: AnyObject, _ price: AnyObject, _ point: AnyObject, _ qty: AnyObject, pointPurchaseHandelling: @escaping (Bool, String) -> Void) {
        
        let params: NSMutableDictionary = [ kCustomerId : customerId,
                                            kVoucherId : voucherId,
                                            kPrice : price,
                                            kPoint : point,
                                            kQty : qty
                                            ]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kpurchasepoint))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        let message = dict[kMessage] as? String
                        pointPurchaseHandelling(true, message!)                        }
                else  {
                        let message = dict[kMessage] as? String
                        pointPurchaseHandelling(false, message!)
                    }
                }
            }
        }
    }
    
 
    
    
    func getRedeemOfferList(_ customerId: AnyObject, _ pageIndex: AnyObject, redeemOfferHandelling: @escaping (RedeemOfferDetailModel, Bool, String) -> Void) {
        
        let params: NSMutableDictionary = [ kCustomerId : customerId,
                                            "PageNo" : pageIndex ]
        
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kredeemoffers))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if (dict.value(forKey: kPayload) as? [String : Any]) != nil {
                            print(dict)
                            let offerDetails   =    Mapper<RedeemOfferDetailModel>().map(JSON: dict.value(forKey: kPayload) as! [String : Any])
                            redeemOfferHandelling(offerDetails!, true, "")
                        }
                    } else {
                        
                        let message = dict[kMessage] as? String
                        let offerDetails   =    Mapper<RedeemOfferDetailModel>().map(JSON: dict.value(forKey: kPayload) as! [String : Any])
                        redeemOfferHandelling(offerDetails!, false, message!)
                    }
                }
            }
        }
    }
    

}
