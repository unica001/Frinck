//
//  PasswordVM.swift
//  Frinck
//
//  Created by meenakshi on 6/7/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

protocol  PasswordViewModeling {
    func validateResetPwdFields(_ currentPwd: String, _ newPwd: String,_ confirmNewPwd: String, _ customerId: AnyObject, validHandler: @escaping (_ param: [String : AnyObject], _ msg: String, _ succes: Bool) -> Void)
    func validateSetPwdFields(_ otp: String, _ newPwd: String,_ confirmNewPwd: String, _ customerMobile: AnyObject, validHandler: @escaping (_ param: [String : AnyObject], _ msg: String, _ succes: Bool) -> Void)
    func callApiPassword(param: [String : AnyObject], isChangePwd: Bool, pwdHandler: @escaping ( _ isSuccess: Bool, _ msg: String) -> Void)
    func callApiSetPassword(param: [String : AnyObject], pwdHandler: @escaping ( _ isSuccess: Bool, _ msg: String) -> Void)
}

class PasswordVM: PasswordViewModeling {

    func validateResetPwdFields(_ currentPwd: String, _ newPwd: String,_ confirmNewPwd: String, _ customerId: AnyObject, validHandler: @escaping (_ param: [String : AnyObject], _ msg: String, _ succes: Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        if currentPwd.trimmingCharacters(in: .whitespaces) == "" && newPwd.trimmingCharacters(in: .whitespaces) == "" && confirmNewPwd.trimmingCharacters(in: .whitespaces) == "" {
            validHandler([:], "Fields can't be left empty.", false)
            return
        }else if currentPwd.trimmingCharacters(in: .whitespaces) == "" {
            validHandler([:], "Current Password can not be left Blank.", false)
            return
        } else if newPwd.trimmingCharacters(in: .whitespaces) == "" {
            validHandler([:], "New Password cannot be left blank.", false)
            return
        } else if ((newPwd.length) < 6) {
            validHandler([:], "Password should be more than 6 characters.", false)
            return
        } else if confirmNewPwd.trimmingCharacters(in: .whitespaces) == "" {
            validHandler([:], "Confirm New Password can no be left blank.", false)
            return
        } else if newPwd != confirmNewPwd {
            validHandler([:], "New Password and Confirm Password do not match.", false)
            return
        } else if newPwd == currentPwd {
            validHandler([:], "New Password cannot be same as Old Password.", false)
            return
        }
        dictParam["CustomerOldPassword"] = currentPwd as AnyObject
        dictParam["CustomerNewPassword"] = newPwd as AnyObject
        dictParam["CustomerId"] = customerId as AnyObject
        validHandler(dictParam, "", true)
    }
    
    func validateSetPwdFields(_ otp: String, _ newPwd: String,_ confirmNewPwd: String, _ customerMobile: AnyObject, validHandler: @escaping (_ param: [String : AnyObject], _ msg: String, _ succes: Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        if otp == "" {
            validHandler([:], "Please enter OTP.", false)
            return
        } else if otp.count != 4 {
            validHandler([:], "Please enter valid OTP.", false)
            return
        } else if newPwd.trimmingCharacters(in: .whitespaces) == "" && confirmNewPwd.trimmingCharacters(in: .whitespaces) == "" {
            validHandler([:], "Fields can't be left empty.", false)
            return
        } else if newPwd.trimmingCharacters(in: .whitespaces) == "" {
            validHandler([:], "New Password cannot be left blank.", false)
            return
        } else if newPwd.count < 8 || newPwd.count > 15 {
            validHandler([:], "Password should be between 8 to 15 characters long", false)
            return
        } else if confirmNewPwd.trimmingCharacters(in: .whitespaces) == "" {
            validHandler([:], "Confirm New Password can no be left blank.", false)
            return
        } else if newPwd != confirmNewPwd {
            validHandler([:], "New Password and Confirm Password do not match.", false)
            return
        }
        dictParam["CustomerPassword"] = newPwd as AnyObject
        dictParam["CustomerMobile"] = customerMobile as AnyObject
        dictParam["CustomerOtp"] = otp as AnyObject
        validHandler(dictParam, "", true)
    }
    
    func callApiPassword(param: [String : AnyObject], isChangePwd: Bool, pwdHandler: @escaping ( _ isSuccess: Bool, _ msg: String) -> Void) {
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,(isChangePwd) ? kresetPassword : ksetPassword))!
        let authenticate = (isChangePwd) ? false : true
        let params: NSMutableDictionary = NSMutableDictionary(dictionary: param)
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true, isAuthentication: authenticate, showSystemError: true, loadingText: false, params: params ) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    let message = dict[kMessage] as? String
                    if index == "200" {
                        pwdHandler(true, message!)
                    } else {
                        pwdHandler(false, message!)
                    }
                }
            }
        }
    }
    
    func callApiSetPassword(param: [String : AnyObject], pwdHandler: @escaping ( _ isSuccess: Bool, _ msg: String) -> Void) {
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl, ksetPassword))!
        let params: NSMutableDictionary = NSMutableDictionary(dictionary: param)
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true, showSystemError: true, loadingText: false, params: params ) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    let message = dict[kMessage] as? String
                    if index == "200" {
                        pwdHandler(true, message!)
                    } else {
                        pwdHandler(false, message!)
                    }
                }
            }
        }
    }
}
