//
//  FRLoginViewController.swift
//  Frinck
//
//  Created by dilip-ios on 02/04/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class FRLoginViewController: UIViewController
{
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var loginInfoDictionary :NSMutableDictionary!
    var appDelegate : AppDelegate! = nil
    var socialDictionary : NSMutableDictionary = NSMutableDictionary()
    
    var socialType : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK : Prepare segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ksignupSegueIdentifier{
            let  signupViewController :FRSignupViewController = segue.destination as! FRSignupViewController
            signupViewController.socialDictionary = self.socialDictionary
        }
        
    }
    
    // MARK: - IBAction Button click

    @objc func myviewTapped(_ sender: UITapGestureRecognizer)
    {
        view.endEditing(true)
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        appDelegate.userType = "N"
        if validation() {
            siginInAPI()
        }
    }
    
    // Facebook login button
    //
    @IBAction func facebookButtonAction(_ sender: Any)
    {
        appDelegate.userType = "S"
        socialType = kFB
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil)
            {
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil
                {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        if((FBSDKAccessToken.current()) != nil)
                        {
                            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                                
                                if (error == nil)
                                {
                                    let fbDict = result as! [String : AnyObject]
                                    let dict :NSMutableDictionary = NSMutableDictionary()
                                    
                                    if fbDict["name"] != nil{
                                        dict.setValue(fbDict["name"] as! NSString, forKey: kCustomerName)
                                    }
                                    
                                    if fbDict["email"] != nil{
                                        dict.setValue(fbDict["email"] as! NSString, forKey: kCustomerEmail)
                                    }
                                    
                                    if let imageURL = ((fbDict["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                                        dict.setValue(imageURL as NSString, forKey: kCustomerProfileImage)
                                    }
                                    let id :NSString  = fbDict["id"] as! NSString
                                    dict.setValue(id, forKey: kSocialId)
                                    dict.setValue(self.socialType, forKey: kStype)
                                    
                                    self.socialDictionary = dict
                                    print(fbDict)
                                    self.checkUserExistance(type: self.socialType as NSString, socialID:id, registerType: "S")
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    // google login button
    //
    @IBAction func googlePlusButtonAction(_ sender: Any)
    {
        appDelegate.userType = "S"
        socialType = KG
        GIDSignIn.sharedInstance().signIn()
    }
    
    //MARK: - Methods
    func validation()-> Bool
    {
        if userNameTextField.text == ""
        {
            alertController(controller: self, title: "", message: "Please enter valid user name", okButtonTitle: "OK", completionHandler: {(index) ->
                Void in
            })
            return false
        }
        else if passwordTextField.text == ""
        {
            alertController(controller: self, title: "", message: "Please enter password", okButtonTitle: "OK", completionHandler: { (index) ->
                Void in
            })
            return false
        }
        return true
    }
    
    
    //MARK: - API call
    
    func checkUserExistance(type: NSString,socialID:NSString,registerType: NSString)
    {
        let appdelegate : AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        
        var params : NSMutableDictionary = [:]
        
        params = [
            kCustomerSocialType: type,
            KCustomerSocialId :socialID,
            kCustomerRegisterType : registerType,
            kCustomerDeviceType: "iOS",
            kCustomerDeviceToken: appdelegate.deviceToken
        ]
        
        print(params)
        
        let baseUrl = String(format: "%@%@",kBaseUrl,"authorization/checkuser")
        let requestURL: URL = URL(string: baseUrl)!
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: true, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    print(response![kCode]!)
                    
                    let dict    = response
                    let payload :NSMutableDictionary =  (dict![kPayload] as?NSMutableDictionary)!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    
                    if index == "200"
                    {
                        print(payload)
                        kUserDefault.set(NSKeyedArchiver.archivedData(withRootObject:payload), forKey: kloginInfo)
                        self.checkQuickBloxUserExist()
                    } else if index == "204" {
                        kUserDefault.set(NSKeyedArchiver.archivedData(withRootObject:payload), forKey: kloginInfo)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let otpVerify = storyboard.instantiateViewController(withIdentifier: "FROTPViewController") as? FROTPViewController
                        self.navigationController?.pushViewController(otpVerify!, animated: true)
                    } else if index == "202"
                    {
                        self.performSegue(withIdentifier: ksignupSegueIdentifier, sender: self.socialDictionary)
                    }
                    else
                    {
//                        self.performSegue(withIdentifier: ksignupSegueIdentifier, sender: self.socialDictionary)
                    }
                }
            }
            else {
                // show alert
            }
        }
    }
    
    func siginInAPI(){
        
        let appdelegate : AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        
        var params : NSMutableDictionary = [:]
        
        params = [
            kCustomerUserName: userNameTextField.text!,
            kCustomerPassword : passwordTextField.text!,
            kCustomerRegisterType : self.socialDictionary.value(forKey: appDelegate.userType) ?? "N",
            KCustomerSocialId : self.socialDictionary.value(forKey: kSocialId) ?? "",
            kCustomerSocialType : self.socialDictionary.value(forKey: kStype) ?? "",
            kCustomerDeviceType: "iOS",
            kCustomerDeviceToken: appdelegate.deviceToken
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,"authorization/login"))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: true, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    let cityDict = dict[kPayload] as Any
                    print("Login payload \(cityDict)")
                    if index == "200" {
                    kUserDefault.set(NSKeyedArchiver.archivedData(withRootObject: dict[kPayload] as Any ), forKey: kloginInfo)
                        self.loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
                        AppDelegate.delegate.quickBloxId = self.loginInfoDictionary[kqbId] as! Int
                        self.checkQuickBloxUserExist()
                    } else
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
    
    
    
    //MARK: - Quickblox
    func checkQuickBloxUserExist() {
        if let qbID : Int = AppDelegate.delegate.quickBloxId as? Int, qbID != 0 {
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
            self.logInChatWithUser(user: user, dict: self.loginInfoDictionary)
        }, errorBlock: {(error : QBResponse) in
            
        })
    }
    
    func logInChatWithUser(user: QBUUser, dict: NSMutableDictionary) {
        ServicesManager.instance().logIn(with: user, completion:{
            [unowned self] (success, errorMessage) -> Void in
            if success {
                AppDelegate.delegate.quickBloxId = Int(user.id)
                self.moveToHome(dict: dict)
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
            self.moveToHome(dict: self.loginInfoDictionary)
            
        }, errorBlock: {(response: QBResponse) in
            print(response)
        })
    }
    
    
    func moveToHome(dict: NSMutableDictionary) {
        let cityID  : Int = dict.value(forKey: kCityId) as? Int ?? 0
        
        let isMobile = dict.value(forKey: "CustomerIsMobileVerified") as? Bool
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if !(isMobile!) {
            let otpVerify = storyboard.instantiateViewController(withIdentifier: "FROTPViewController") as? FROTPViewController
            self.navigationController?.pushViewController(otpVerify!, animated: true)
        } else {
            if (cityID == 0){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "citySelectionStoryboardID")
                self.present(initialViewController, animated: true, completion: nil)
            } else {
                
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "tabbarController")
                self.present(initialViewController, animated: true, completion: nil)
            }
        }
    }
    
}

extension FRLoginViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!)
    {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        
        if (error == nil)
        {
            // Perform any operations on signed in user here.
            let userId = user.userID
            let fullName = user.profile.name
            let email = user.profile.email
            
            
            let dict :NSMutableDictionary = NSMutableDictionary()
            
            dict.setValue(userId, forKey: kSocialId)
            dict.setValue(fullName, forKey: kCustomerName)
            dict.setValue(email, forKey: kCustomerEmail)
            dict.setValue(socialType, forKey: kStype)
            self.socialDictionary = dict
            
            self.checkUserExistance(type: self.socialType as NSString, socialID:userId! as NSString, registerType: "S")
            // ...
        }
        else
        {
            print("\(error.localizedDescription)")
        }
        
    }
    
    private func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                        withError error: Error!)
    {
        // PeError!y operations when the user disconnects from app here.
        // ...
    }
}

extension FRLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == userNameTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField{
            passwordTextField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        var limit = 20
        
        switch textField {
        case userNameTextField:
            limit=20
        case passwordTextField:
            limit=10
        default:
            limit=10
        }
        return (textField.text?.count ?? 0) < limit || string == ""
    }
}

