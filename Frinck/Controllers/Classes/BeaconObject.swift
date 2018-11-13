//
//  BeaconObject.swift
//  BeaconSample
//
//  Created by LN-iMAC-003 on 05/06/18.
//  Copyright © 2018 LN-iMAC-003. All rights reserved.
//

import Foundation

class BeaconObject: NSObject {
    var status      = 0
    var message     = ""
    var data        = [BeaconData]()
    init(objBeacon:[String:AnyObject]) {
        status = objBeacon["status"] as! Int
        message = objBeacon["message"] as! String
        for dict in objBeacon["data"] as! [[String: AnyObject]]{
            let data2 = BeaconData.init(dataBeacon: dict)
            data.append(data2)
        }
        
    }
}

