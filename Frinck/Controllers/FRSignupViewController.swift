//
//  FRSignupViewController.swift
//  Frinck
//
//  Created by dilip-ios on 29/03/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import ActionSheetPicker_3_0

class FRSignupViewController: UIViewController, UIScrollViewDelegate
{
    @IBOutlet weak var signupTableView: UITableView!
    @IBOutlet var termCheckImage: UIImageView!
    var register_type : String = ""
    var appDelegate : AppDelegate! = nil
    var incommingType : NSString!
    var isTermCoonditionAgree : Bool = false
    var socialType : String = ""
    var loginInfoDictionary : NSMutableDictionary!

    var nameTextField : UITextField!
    var usernameTextField : UITextField!
    var dobTextField : UITextField!
    var emailTextField : UITextField!
    var mobileNumberTextField : UITextField!
    var passwordTextField : UITextField!
    var confirmPasswordTextField : UITextField!
    var referralCodeTextField : UITextField!
    var selectGenderTextField : UITextField!
    
    var selectedGender : Int = 0
    var dateFormatter : DateFormatter!
    
    let GenderArray = ["Male","Female", "Other"]
    var socialDictionary: NSDictionary = NSDictionary()
    
    var textFieldPlaceHolder = [String]()
    
    //MARK: - View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        signupTableView.register(UINib(nibName: "FRSignupTableViewCell", bundle: nil), forCellReuseIdentifier: "FRSignupTableViewCell")
        setInitailLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar for current view controller
        self.navigationController?.isNavigationBarHidden = true;
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.isNavigationBarHidden = false;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kVerifySegueIdentifier{
            
            let  verifyView :FROTPViewController = segue.destination as! FROTPViewController
            verifyView.incommingType  = self.incommingType
            if (self.socialDictionary != nil) {
                verifyView.socialDictionary = self.socialDictionary
                
            }
        }
    }
    
    //MARK: - Private Methods
    func setInitailLayout() -> Void {
            
        let size = CGRect(x: 40, y: 15, width: ScreenSize.width - 80, height: 30)
            // name
        nameTextField = UITextField(frame: size)
        nameTextField.backgroundColor = UIColor.clear
        nameTextField.borderStyle = UITextBorderStyle.none
        nameTextField.font =  UIFont(name: kFontTextRegular, size: 14.0)
        nameTextField.textColor = UIColor.black
        nameTextField.delegate = self
        nameTextField.placeholder = "NAME"
        nameTextField.textAlignment = .left
            
        // username
        usernameTextField = UITextField(frame: size)
        usernameTextField.backgroundColor = UIColor.clear
        usernameTextField.borderStyle = UITextBorderStyle.none
        usernameTextField.font =  UIFont(name: kFontTextRegular, size: 14.0)
        usernameTextField.textColor = UIColor.black
        usernameTextField.delegate = self
        usernameTextField.placeholder = "USERNAME"
        usernameTextField.textAlignment = .left
            
        // email
        emailTextField = UITextField(frame: size)
        emailTextField.backgroundColor = UIColor.clear
        emailTextField.borderStyle = UITextBorderStyle.none
        emailTextField.font =  UIFont(name: kFontTextRegular, size: 14.0)
        emailTextField.textColor = UIColor.black
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        emailTextField.delegate = self
        emailTextField.placeholder = "EMAIL"
        emailTextField.textAlignment = .left
        emailTextField.autocapitalizationType = UITextAutocapitalizationType.none
            
        // mobile
        mobileNumberTextField = UITextField(frame: CGRect(x: 85, y: 15, width: ScreenSize.width - 155, height: 30))
        mobileNumberTextField.backgroundColor = UIColor.clear
        mobileNumberTextField.borderStyle = UITextBorderStyle.none
        mobileNumberTextField.font =  UIFont(name: kFontTextRegular, size: 14.0)
        mobileNumberTextField.textColor = UIColor.black
        mobileNumberTextField.keyboardType = UIKeyboardType.phonePad
        mobileNumberTextField.delegate = self
        mobileNumberTextField.placeholder = "MOBILE NUMBER"
        mobileNumberTextField.textAlignment = .left
            
        // DOB
        dobTextField = UITextField(frame: size)
        dobTextField.backgroundColor = UIColor.clear
        dobTextField.isUserInteractionEnabled = false
        dobTextField.borderStyle = UITextBorderStyle.none
        dobTextField.font =  UIFont(name: kFontTextRegular, size: 14.0)
        dobTextField.textColor = UIColor.black
        dobTextField.placeholder = "DOB"
        dobTextField.delegate = self
        dobTextField.textAlignment = .left
            
        // passwordTextField
        passwordTextField = UITextField(frame: size)
        passwordTextField.backgroundColor = UIColor.clear
        passwordTextField.borderStyle = UITextBorderStyle.none
        passwordTextField.font =  UIFont(name: kFontTextRegular, size: 14.0)
        passwordTextField.textColor = UIColor.black
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        passwordTextField.placeholder = "PASSWORD"
        passwordTextField.textAlignment = .left
            
        // confrim Password
        confirmPasswordTextField = UITextField(frame: size)
        confirmPasswordTextField.backgroundColor = UIColor.clear
        confirmPasswordTextField.borderStyle = UITextBorderStyle.none
        confirmPasswordTextField.font =  UIFont(name: kFontTextRegular, size: 14.0)
        confirmPasswordTextField.textColor = UIColor.black
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.placeholder = "CONFIRM PASSWORD"
        confirmPasswordTextField.delegate = self
        confirmPasswordTextField.textAlignment = .left
            
        // referralCodeTextField
        referralCodeTextField = UITextField(frame: size)
        referralCodeTextField.backgroundColor = UIColor.clear
        referralCodeTextField.borderStyle = UITextBorderStyle.none
        referralCodeTextField.font =  UIFont(name: kFontTextRegular, size: 14.0)
        referralCodeTextField.textColor = UIColor.black
        referralCodeTextField.placeholder = "REFERRAL CODE"
        referralCodeTextField.delegate = self
        referralCodeTextField.textAlignment = .left
            
        // selectGenderTextField
        selectGenderTextField = UITextField(frame: size)
        selectGenderTextField.backgroundColor = UIColor.clear
        selectGenderTextField.isUserInteractionEnabled = false
        selectGenderTextField.borderStyle = UITextBorderStyle.none
        selectGenderTextField.placeholder = "SELECT GENDER"
        selectGenderTextField.font =  UIFont(name: kFontTextRegular, size: 14.0)
        selectGenderTextField.textColor = UIColor.black
        selectGenderTextField.isUserInteractionEnabled = false
        selectGenderTextField.delegate = self
        selectGenderTextField.textAlignment = .left
 
        // Social User Type
        if appDelegate.userType == "S" {
            setSocialLoginData()
        }
    }

    func setSocialLoginData(){
        nameTextField.text = self.socialDictionary.value(forKey: kCustomerName) as? String
        emailTextField.text = self.socialDictionary.value(forKey: kCustomerEmail) as? String
    }
    
    func validation()-> Bool
    {
        if nameTextField.text == ""
        {
            alertController(controller: self, title: "", message: "Please enter name", okButtonTitle: "OK", completionHandler: {(index) ->
                Void in
            })
            return false
        }
            
        else if usernameTextField.text == ""
        {
            alertController(controller: self, title: "", message: "Please enter username", okButtonTitle: "OK", completionHandler: { (index) ->
                Void in
            })
            return false
        }
        else if dobTextField.text == ""
        {
            alertController(controller: self, title: "", message: "Please enter DOB", okButtonTitle: "OK", completionHandler: { (index) ->
                Void in
            })
            return false
        }
            
        else if emailTextField.text == ""
        {
            alertController(controller: self, title: "", message: "Please enter email", okButtonTitle: "OK", completionHandler: { (index) ->
                Void in
            })
            return false
        }
            
        else if (!isValidEmail(testStr: emailTextField.text!)) {
            alertController(controller: self, title: "", message: "Enter your valid email.", okButtonTitle: "OK", completionHandler: {(index) -> Void in
            })
            
            return false;
        }
            
        else if mobileNumberTextField.text == ""
        {
            alertController(controller: self, title: "", message: "Please enter mobile number", okButtonTitle: "OK", completionHandler: { (index) ->
                Void in
            })
            return false
        }
        else  if (mobileNumberTextField.text!.count != 10) {            alertController(controller: self, title: "", message: "The customer mobile no must be at least 10 characters..", okButtonTitle: "OK", completionHandler: {(index) -> Void in
        })
            return false;
        }
            
        else if passwordTextField.text == "" && appDelegate.userType != "S"
        {
            alertController(controller: self, title: "", message: "Please enter password", okButtonTitle: "OK", completionHandler: { (index) ->
                Void in
            })
            return false
        }
            
        else if ((passwordTextField.text?.length)! < 6) && appDelegate.userType != "S" {
            alertController(controller: self, title: "", message: "Password should be more than 6 characters.", okButtonTitle: "OK", completionHandler: {(index) -> Void in
            })
            
            return false;
        }
            
        else if confirmPasswordTextField.text == "" && appDelegate.userType != "S"
        {
            alertController(controller: self, title: "", message: "Please enter confirm password", okButtonTitle: "OK", completionHandler: { (index) ->
                Void in
            })
            return false
        }
        else if passwordTextField.text != confirmPasswordTextField.text && appDelegate.userType != "S"
        {
            alertController(controller: self, title: "", message: "Password and Confirm password does not match", okButtonTitle: "OK", completionHandler: { (index) ->
                Void in
            })
            return false
        }
            
        else if isTermCoonditionAgree == false {
            alertController(controller: self, title: "", message: "Please select Terms And Conditions", okButtonTitle: "OK", completionHandler: { (index) ->
                Void in
            })
            return false
        }
        
        return true;
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

    //MARK: - IBAction Methods
    @IBAction func facebookButtonAction(_ sender: Any)
    {
        self.socialType = "F"
        appDelegate.userType = "S"

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
                                    self.checkUserExistance(type: kFB as NSString, socialID:id, registerType: "S")
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    @IBAction func googlePlusButtonAction(_ sender: Any)
    {
        self.socialType = KG
        appDelegate.userType = "S"

        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func termAndConditionButtonAction(_ sender: Any) {
        if isTermCoonditionAgree == false {
            termCheckImage.image = UIImage(named: "roundCheck")
            isTermCoonditionAgree = true
        }
        else {
            termCheckImage.image = UIImage(named: "roundCheckGray")
            isTermCoonditionAgree = false
        }
    }
    
    @IBAction func tapTerms(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let webViewC = storyboard.instantiateViewController(withIdentifier: "FRWebViewC") as? FRWebViewC
        webViewC?.strHeader = "Terms and Conditions"
        self.navigationController?.pushViewController(webViewC!, animated: true)
    }
    
    @IBAction func registerButtonAction(_ sender: Any)
    {
        if validation() {
           signUpApi()
        }
    }
    
    
    @IBAction func loginHereButtonAction(_ sender: Any)
    {
    }

    // MARK: - API Call
    func checkUserExistance(type: NSString,socialID:NSString,registerType: NSString)
    {
        
        var params : NSMutableDictionary = [:]
        
        params = [
            kCustomerSocialType: type,
            KCustomerSocialId :socialID,
            kCustomerRegisterType : registerType
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
                        kUserDefault.set(NSKeyedArchiver.archivedData(withRootObject:payload), forKey: kloginInfo)
                        self.loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
                        self.checkQuickBloxUserExist()
                    } else if index == "204" {
                        kUserDefault.set(NSKeyedArchiver.archivedData(withRootObject:payload), forKey: kloginInfo)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let otpVerify = storyboard.instantiateViewController(withIdentifier: "FROTPViewController") as? FROTPViewController
                        self.navigationController?.pushViewController(otpVerify!, animated: true)
                    } else if index == "202" {
                        if type == "G" {
                            self.socialType = KG
                        } else if type as String == kFB {
                            self.socialType = kFB
                        }
                        self.setSocialLoginData()
                        self.appDelegate.userType = "S"
                        self.signupTableView.reloadData()
                    } else {
                        
                    }
                }
            } else {
                
                // show alert
            }
        }
    }
    
    func signUpApi()
    {
        
        let appdelegate : AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerName: nameTextField.text!,
            kCustomerUserName: usernameTextField.text!,
            kCustomerDob: dobTextField.text!,
            kCustomerEmail: emailTextField.text!,
            kCustomerMobile: mobileNumberTextField.text!,
            kCustomerPassword: passwordTextField.text!,
            kCustomerReferalCode: referralCodeTextField.text!,
            kCustomerGender: selectGenderTextField.text!,
            kCustomerRegisterType : appDelegate.userType,
            kCustomerCountryCode: self.socialDictionary.value(forKey: kContryCode) ?? "91",
            kCustomerDeviceType: "iOS",
            kCustomerDeviceToken: appdelegate.deviceToken,
            KCustomerSocialId : self.socialDictionary.value(forKey: kSocialId) ?? "",
            kCustomerSocialType : self.socialDictionary.value(forKey: kStype) ?? ""
        ]
        print("Signup parameter \(params)")
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,"registration/register"))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: true, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    print("Sign up response \(response)")
                    if index == "200" {
                        kUserDefault.set(NSKeyedArchiver.archivedData(withRootObject: dict[kPayload] as Any ), forKey: kloginInfo)
                        self.performSegue(withIdentifier: kVerifySegueIdentifier, sender: nil)

                    } else {
                        let message = dict[kMessage]
                        
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                        })
                        
                    }
                }
            }
        }
    }
    
}

extension FRSignupViewController: GIDSignInUIDelegate, GIDSignInDelegate {
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
            
            self.checkUserExistance(type: KG as NSString, socialID:userId! as NSString, registerType: "S")
            // ...
        }
        else
        {
            print("\(error.localizedDescription)")
        }
        
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!)
    {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

extension FRSignupViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if(textField.returnKeyType == .done) {
            textField.resignFirstResponder()
        } else {
            if textField == nameTextField {
                usernameTextField.becomeFirstResponder()
            } else if textField == usernameTextField {
                emailTextField.becomeFirstResponder()
            } else if textField == emailTextField {
                mobileNumberTextField.becomeFirstResponder()
            } else if textField == mobileNumberTextField {
                passwordTextField.becomeFirstResponder()
            } else if textField == passwordTextField {
                confirmPasswordTextField.becomeFirstResponder()
            } else if textField == confirmPasswordTextField {
                referralCodeTextField.becomeFirstResponder()
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        var limit = 20
        
        switch textField {
        case nameTextField:
            limit=20
        case usernameTextField:
            limit=200
        case nameTextField:
            limit=30
        case emailTextField:
            limit=100
        case mobileNumberTextField:
            limit=10
        case passwordTextField:
            limit=10
        case confirmPasswordTextField:
            limit=10
        case referralCodeTextField:
            limit=10
        default:
            limit=10
        }
        return (textField.text?.count ?? 0) < limit || string == ""
    }
}

extension FRSignupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let identifier = "FRSignupTableViewCell"
        var cell: FRSignupTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? FRSignupTableViewCell
        
        tableView.register(UINib(nibName: "FRSignupTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        cell = (tableView.dequeueReusableCell(withIdentifier: identifier) as? FRSignupTableViewCell)!
        
        cell.contentTextField.delegate = self
        cell.contentTextField.returnKeyType = UIReturnKeyType.next
        
        if indexPath.row == 0 {
            cell.addSubview(nameTextField)
            cell.iconImageView.image = UIImage(named:"username")!
        } else if indexPath.row == 1 {
            cell.addSubview(usernameTextField)
            cell.iconImageView.image = UIImage(named:"username")!
        } else if indexPath.row == 2 {
            cell.addSubview(dobTextField)
            cell.iconImageView.image = UIImage(named:"DOB")!
        } else if indexPath.row == 3 {
            cell.addSubview(emailTextField)
            cell.iconImageView.image = UIImage(named:"Email")!
        } else if indexPath.row == 4 {
            cell.countryCodeLabelWidthConstraint.constant = 30
            cell.addSubview(mobileNumberTextField)
            cell.iconImageView.image = UIImage(named:"Mobile")!
        } else if indexPath.row == 5 {
            cell.addSubview(passwordTextField)
            cell.iconImageView.image = UIImage(named:"password")!
        } else if indexPath.row == 6 {
            cell.addSubview(confirmPasswordTextField)
            cell.iconImageView.image = UIImage(named:"Confirm_passwrd")!
        } else if indexPath.row == 7 {
            cell.contentTextField.keyboardType = UIKeyboardType.numberPad
            cell.addSubview(referralCodeTextField)
            cell.iconImageView.image = UIImage(named:"referalcode")!
        } else if indexPath.row == 8 {
            cell.addSubview(selectGenderTextField)
            cell.iconImageView.image = UIImage(named:"username")!
        }
        if appDelegate.userType == "S" && (indexPath.row == 5 || indexPath.row == 6) {
            cell.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if appDelegate.userType == "S" && (indexPath.row == 5 || indexPath.row == 6) {
            return 0
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.row == 2
        {
            var selectedDate = Date() as Date!
            
            if self.dobTextField.text != ""{
                
                self.dateFormatter = DateFormatter()
                self.dateFormatter.dateFormat = "dd-MM-yyyy"
                let date = self.dateFormatter.date(from:self.dobTextField.text!)
                selectedDate = date
            }
            
            let datePicker = ActionSheetDatePicker(title: "Date:", datePickerMode: UIDatePickerMode.date, selectedDate: selectedDate, doneBlock: {
                picker, value, index in
                
                self.dateFormatter = DateFormatter()
                self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
                let date = self.dateFormatter.date(from: String(describing: value!))
                self.dateFormatter.dateFormat = "dd-MM-yyyy"
                self.dobTextField.text =   self.dateFormatter.string(from: date!)
                return
                
            }, cancel: { ActionStringCancelBlock in return }, origin: self.view.superview!.superview)
            let secondsInWeek: TimeInterval = 365 * 70 * 24 * 60 * 60;
            //let max: TimeInterval =  365 * 12 * 24 * 60 * 60;
            
            datePicker?.minimumDate = Date(timeInterval: -secondsInWeek, since: Date())
            //datePicker?.maximumDate = Date(timeInterval: -max, since: Date())
            datePicker?.maximumDate = Calendar.current.date(byAdding: .year, value: -0, to: Date())
            datePicker?.show()
        }
        else if indexPath.row == 8 {
            ActionSheetStringPicker.show(withTitle: "Select Gender", rows: GenderArray, initialSelection: self.selectedGender, doneBlock: {
                picker, value, index in
                
                self.selectedGender = value
                self.selectGenderTextField.text = self.GenderArray[value]
                return
            }, cancel: { ActionStringCancelBlock in return }, origin: self.view)
        }
    }
}
