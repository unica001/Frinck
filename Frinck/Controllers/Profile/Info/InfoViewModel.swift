//
//  InfoViewModel.swift
//  Frinck
//
//  Created by meenakshi on 6/4/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

enum ProfileType {
    case name
    case username
    case dob
    case email
    case phoneNo
    case gender
}

struct InfoStruct {
    var type: ProfileType!
    var image: UIImage!
    var value: String!
    var placeholder:String!
    var countryCode: String!
    
    init(type: ProfileType, placeholder: String = "", value: String = "", image: UIImage, countryCode: String = "") {
        self.type = type
        self.image = image
        self.value = value
        self.placeholder = placeholder
        self.countryCode = countryCode
    }
}

protocol InfoViewModelling {
    func prepareInfo(dictInfo : [String : AnyObject]) -> [InfoStruct]
    func validateFields(dataStore: [InfoStruct], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void)
     func callApiEditProfile(param: [String : AnyObject], editProfileHandler: @escaping ( _ isSuccess: Bool, _ msg: String, _ isOtp: Bool, _ mobileNumber: String) -> Void)
}

class InfoViewModel: InfoViewModelling {

    func prepareInfo(dictInfo : [String : AnyObject]) -> [InfoStruct] {
        var infoData = [InfoStruct]()
        infoData.append(InfoStruct(type: ProfileType.name , placeholder: "Name", value: dictInfo["CustomerName"] as! String, image: #imageLiteral(resourceName: "username")))
        infoData.append(InfoStruct(type: ProfileType.username , placeholder: "Username", value: dictInfo["CustomerUserName"] as! String, image: #imageLiteral(resourceName: "username")))
        infoData.append(InfoStruct(type: ProfileType.dob , placeholder: "DOB", value: dictInfo["CustomerDob"] as! String, image: #imageLiteral(resourceName: "DOB")))
        infoData.append(InfoStruct(type: ProfileType.email , placeholder: "Email", value: dictInfo["CustomerEmail"] as! String, image: #imageLiteral(resourceName: "Email")))
        infoData.append(InfoStruct(type: ProfileType.phoneNo , placeholder: "Phone No", value: dictInfo["CustomerMobile"] as! String, image: #imageLiteral(resourceName: "Mobile"), countryCode: dictInfo["CustomerCountryCode"] as! String))
        infoData.append(InfoStruct(type: ProfileType.gender , placeholder: "Gender", value: dictInfo["CustomerGender"] as! String, image: #imageLiteral(resourceName: "username")))
        return infoData
    }
    
    func validateFields(dataStore: [InfoStruct], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
            case .name:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], "Please enter name", false)
                    return
                }
                dictParam["CustomerName"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
            case .username:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], "Please enter username", false)
                    return
                }
                dictParam["CustomerUserName"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
            case .dob:
                if dataStore[index].value == "" {
                    validHandler([:], "Please select date of birth", false)
                    return
                }
                dictParam["CustomerDob"] = dataStore[index].value as AnyObject
            case .email:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], "Please enter email", false)
                    return
                }
                else if !isValidEmail(testStr: dataStore[index].value.trimmingCharacters(in: .whitespaces)) {
                    validHandler([:], "Please enter valid email", false)
                    return
                }
                dictParam["CustomerEmail"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
            case .phoneNo:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) != "" && (dataStore[index].value.trimmingCharacters(in: .whitespaces).count < 10) {
                    validHandler([:], "Please enter mobile no", false)
                    return
                }
                dictParam["CustomerMobile"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                dictParam["CustomerCountryCode"] = dataStore[index].countryCode as AnyObject
            case .gender:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], "Please select gender", false)
                }
                dictParam["CustomerGender"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
            case .none:
                break
            case .some(_):
                break
            }
        }
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        dictParam["CustomerId"] = loginInfoDictionary[kCustomerId]! as AnyObject
        dictParam["CustomerDeviceType"] = "" as AnyObject
        dictParam["CustomerDeviceToken"] = "" as AnyObject
        validHandler(dictParam, "", true)
    }
    
    func callApiEditProfile(param: [String : AnyObject], editProfileHandler: @escaping ( _ isSuccess: Bool, _ msg: String, _ isOtp: Bool, _ mobileNumber: String) -> Void) {
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,keditProfile))!
        let params: NSMutableDictionary = NSMutableDictionary(dictionary: param)
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params ) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    let message = dict[kMessage] as? String
                    if index == "200" {
                        if let res = dict["payloads"] as? [String : AnyObject], let otp = res["CustomerOtp"] {
                            let mobileNumber = res["CustomerMobile"] as? String
                            editProfileHandler(true, message!, true, mobileNumber!)
                        } else {
                            editProfileHandler(true, message!, false, "")
                        }
                    } else {
                        editProfileHandler(false, message!, false, "")
                    }
                }
            }
        }
    }
}
