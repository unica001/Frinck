//
//  URL+Constant.swift
//  BeaconSample
//
//  Created by LN-iMAC-003 on 06/06/18.
//  Copyright © 2018 LN-iMAC-003. All rights reserved.
//

import Foundation
import UIKit

let iOSDevice = "ios"

let BASE_URL = "https://beaconsdk.letsnurture.co.uk/api/"  // LIVE

enum URLS: String {
    case URL_BeaconList             = "get-beacon-list?"
    case URL_BeaconDetail           = "get-beacon-detail"
    case URL_UnAuthorizedUser       = "unauthorized-user"
    case URL_Analysis               = "analysis"
    case URL_BeaconHistory          = "update-beacon-history"
}

func getCurrentTime() -> Date {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    print(date)
    return date
}




