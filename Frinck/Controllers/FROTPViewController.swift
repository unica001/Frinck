//
//  FROTPViewController.swift
//  Frinck
//
//  Created by dilip-ios on 02/04/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class FROTPViewController: UIViewController
{
    @IBOutlet weak var mobileNumberLabel: UILabel!
    @IBOutlet weak var firstOTPTextField: UITextField!
    @IBOutlet weak var secondOTPTextField: UITextField!
    @IBOutlet weak var thirdOTPTextField: UITextField!
    @IBOutlet weak var fourthOTPTextField: UITextField!
    
    @IBOutlet var btnBack: UIButton!
    var incommingType : NSString!
    var socialDictionary: NSDictionary = NSDictionary()
//    var mobileNumber : String!
    var loginInfoDictionary :NSMutableDictionary!
    var mobileNumberString : String = ""
    var isSplash : Bool = false
    
    //MARK: - View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        firstOTPTextField.delegate = self
        secondOTPTextField.delegate = self
        thirdOTPTextField.delegate = self
        fourthOTPTextField.delegate = self
        
        firstOTPTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        secondOTPTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        thirdOTPTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        fourthOTPTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        // Set mobile number
        btnBack.isHidden = (isSplash) ? true : false
        
        if self.incommingType == kCustomerOldPassword as NSString {
            let mobileNumber =  self.mobileNumberString
            let index1 = mobileNumber.index((mobileNumber.endIndex), offsetBy: -4)
            let substring1 = mobileNumber.substring(from: index1)
            mobileNumberLabel.text = String(mobileNumber)
        } else if self.incommingType == "EditProfile" {
            let mobileNumber =  self.mobileNumberString
            let index1 = mobileNumber.index((mobileNumber.endIndex), offsetBy: -4)
            let substring1 = mobileNumber.substring(from: index1)
            mobileNumberLabel.text = mobileNumber
        } else {
            mobileNumberLabel.text = mobileNumberString
            mobileNumberLabel.text = loginInfoDictionary.value(forKey: kCustomerMobile) as! String
        }
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false;
    }
    
    //MARK: - IBAction Methods
    
    @IBAction func resendOTPButtonAction(_ sender: Any)
    {
        reSendOTP()
    }
    @IBAction func tapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func verifyButtonAction(_ sender: Any)
    {
        if validation() == true
        {
            if self.incommingType == "EditProfile" {
                let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
                let qbID : Int = AppDelegate.delegate.quickBloxId
                verify(qbId: "\(qbID)")
            } else {
                checkQuickBloxUserExist()
            }
        }
    }
    
    
    // MARK - Validation
    
    func validation()-> Bool {
        
        if firstOTPTextField.text == "" && secondOTPTextField.text == "" && thirdOTPTextField.text == "" && fourthOTPTextField.text == "" {
            alertController(controller: self, title: "", message: "Please enter OTP.", okButtonTitle: "OK", completionHandler: {(index) -> Void in
            })
            return false;
            
        }
        else  if firstOTPTextField.text == "" || secondOTPTextField.text == "" || thirdOTPTextField.text == ""||fourthOTPTextField.text == "" {
            alertController(controller: self, title: "", message: "Please enter valid OTP.", okButtonTitle: "OK", completionHandler: {(index) -> Void in
            })
            return false;
            
        }
        return true;
    }
    
    //MARK: - API Call
    
    func reSendOTP(){
        
        // param dictionary
        var params : NSMutableDictionary = [:]
        params = [
            kCustomerMobile : (incommingType == "EditProfile") ? mobileNumberString : loginInfoDictionary[kCustomerMobile]!,
            kCustomerId : loginInfoDictionary[kCustomerId]! ]
        
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,"registration/resendotp"))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: true, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        print(response![kPayload]!)
                        
                        alertController(controller: self, title: "", message:response![kMessage] as! String , okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                            self.firstOTPTextField.text = ""
                            self.secondOTPTextField.text = ""
                            self.thirdOTPTextField.text = ""
                            self.fourthOTPTextField.text = ""
                            
                        })
                    }
                    else
                    {
                        let message = dict[kMessage]
                        
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                        })
                        
                    }
                }
            }
                
            else {
                
                // show alert
            }
            
        }
    }
    
    func verify(qbId : String)
    {
        let otp = String(format: "%@%@%@%@",firstOTPTextField.text!,secondOTPTextField.text!,thirdOTPTextField.text!,fourthOTPTextField.text!)
        
        // param dictionary
        var params : NSMutableDictionary = [:]
        let customerID = loginInfoDictionary[kCustomerId] as! Int
        params = [
            "CustomerOtp": otp,
            kCustomerMobile : (incommingType == "EditProfile") ? mobileNumberString : loginInfoDictionary[kCustomerMobile] as! String,
            kCustomerId : String(customerID),
            kqbId : qbId
        ]
        
        print("OTP Parameter \(params)")
        
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,"authorization/verifyotp"))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: true, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil){
                
                let dict    = response
                let payload :NSMutableDictionary =  (dict![kPayload] as?NSMutableDictionary)!
                let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                print("Response otp \(response)")
                if index == "200"
                {
                    if self.incommingType == "forgotPassword" as NSString
                    {
                        DispatchQueue.main.sync {
                            let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
                            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "FRPasswordViewC") as! FRPasswordViewC
                            nextViewController.isChangePassword = false
                            self.navigationController?.pushViewController(nextViewController, animated: true)
                        }
         
                    } else if self.incommingType == "EditProfile" {
                        DispatchQueue.main.sync {
                        for controller in (self.navigationController?.viewControllers)! {
                            if controller.isKind(of: FRProfileViewC.self) {
                                self.navigationController!.popToViewController(controller, animated: true)
                                break
                            }
                        }
                        }
                    }
                    else
                    {
                        DispatchQueue.main.sync {
                          kUserDefault.set(NSKeyedArchiver.archivedData(withRootObject:payload), forKey: kloginInfo)
                            
                            self.performSegue(withIdentifier: kselectCityIdentifier, sender: nil)
                        }
                    }
                }
                else
                {
                    let message = dict![kMessage]
                    
                    alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                        
                    })
                    
                }
            }
        }
    }
  
    func checkQuickBloxUserExist() {
        if let qbID : Int = AppDelegate.delegate.quickBloxId, qbID != 0 {
            loginUserQuickBlox()
        } else {
            CreatUserForChat()
        }
    }
    
    func loginUserQuickBlox() {
        let qbID : Int = AppDelegate.delegate.quickBloxId
        
        QBRequest.user(withID: UInt(qbID), successBlock: {(responce : QBResponse , user : QBUUser) in
            user.fullName = (self.loginInfoDictionary[kCustomerUserName] as! String)
            user.email = (self.loginInfoDictionary[kCustomerEmail] as! String)
            user.password = kPassword
            self.logInChatWithUser(user: user)
        }, errorBlock: {(error : QBResponse) in
            
        })
    }
    
    func logInChatWithUser(user: QBUUser) {
        ServicesManager.instance().logIn(with: user, completion:{
            [unowned self] (success, errorMessage) -> Void in
            if success {
                AppDelegate.delegate.quickBloxId = Int(user.id)
                self.verify(qbId: String(user.id))
            } else {
                alertController(controller: self, title: "", message: errorMessage! , okButtonTitle: "OK", completionHandler: {(index) -> Void in
                    
                })
            }
        })
    }
    
    // Create User For chat
    func CreatUserForChat() {
        let userLogin = "user_\(String(describing: loginInfoDictionary[kCustomerId]!))"
        let user = QBUUser()
        user.password = kPassword
        user.login = userLogin
        user.email = (loginInfoDictionary[kCustomerEmail] as! String)
        user.fullName = (loginInfoDictionary[kCustomerUserName] as! String)
        
        QBRequest.signUp(user, successBlock: {(response: QBResponse, user: QBUUser) in
            AppDelegate.delegate.quickBloxId = Int(user.id)
            self.verify(qbId: String(user.id))

        }, errorBlock: {(response: QBResponse) in
            print(response)
        })
    }
    
}

extension FROTPViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return (textField.text?.count ?? 0) < 1 || string == ""
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        let text = textField.text
        if  text?.count == 1 {
            switch textField{
            case firstOTPTextField:
                secondOTPTextField.becomeFirstResponder()
            case secondOTPTextField:
                thirdOTPTextField.becomeFirstResponder()
            case thirdOTPTextField:
                fourthOTPTextField.becomeFirstResponder()
            case fourthOTPTextField:
                fourthOTPTextField.resignFirstResponder()
            default:
                break
            }
        }
        if  text?.count == 0 {
            switch textField{
            case firstOTPTextField:
                firstOTPTextField.becomeFirstResponder()
            case secondOTPTextField:
                firstOTPTextField.becomeFirstResponder()
            case thirdOTPTextField:
                secondOTPTextField.becomeFirstResponder()
            case fourthOTPTextField:
                thirdOTPTextField.becomeFirstResponder()
            default:
                break
            }
        }
        else{
            
        }
    }
}
