//
//  BeaconData.swift
//  BeaconSample
//
//  Created by LN-iMAC-003 on 05/06/18.
//  Copyright © 2018 LN-iMAC-003. All rights reserved.
//

import Foundation

public class BeaconData : NSObject {
    var id          = 0
    var uuid        = ""
    var major       = ""
    var minor       = ""
    var desc        = ""
    var link        = ""
    var title       = ""
    var image       = ""
    var field_type  = ""
    var thumbnail_image = ""

    
    init(dataBeacon:[String: AnyObject]) {
        id = dataBeacon["id"] as! Int
        uuid = dataBeacon["uuid"] as! String
        major = dataBeacon["major"] as! String
        minor  = dataBeacon["minor"] as! String
        desc = dataBeacon["desc"] as! String
        link = dataBeacon["link"] as! String
        title = dataBeacon["title"] as! String
        image = dataBeacon["image"] as! String
        field_type = dataBeacon["field_type"] as! String
        thumbnail_image = dataBeacon["thumbnail_image"] as! String
    }
}
