//
//  FRSetNewPasswordViewController.swift
//  Frinck
//
//  Created by sirez-ios on 13/04/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class FRSetNewPasswordViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var enterNewPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    
    var loginInfoDictionary :NSMutableDictionary!
    override func viewDidLoad() {
        super.viewDidLoad()
        enterNewPasswordTextField.delegate = self
        confirmNewPasswordTextField.delegate = self
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   // Text field delegate
    //
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == enterNewPasswordTextField
        {
            confirmNewPasswordTextField.becomeFirstResponder()
        }
        return true
    }
    
    func validation()-> Bool
    {
        if enterNewPasswordTextField.text == ""
        {
            alertController(controller: self, title: "", message: "Please enter new password.", okButtonTitle: "OK", completionHandler: {(index) ->
                Void in
            })
            return false
        }
        else if !isValidlPassword(testStr: enterNewPasswordTextField.text!){
            alertController(controller: self, title: "", message: "Password should be more than 6 characters,1 special character, 1 alphanumeric and 1 number.", okButtonTitle: "OK", completionHandler: {(index) -> Void in
            })
            
            return false;
        }
        else if confirmNewPasswordTextField.text == ""
        {
            alertController(controller: self, title: "", message: "Please enter confirm new password", okButtonTitle: "OK", completionHandler: { (index) ->
                Void in
            })
            return false
        }
        else if enterNewPasswordTextField.text != confirmNewPasswordTextField.text
        {
            alertController(controller: self, title: "", message: "Password and Confirm password does not match", okButtonTitle: "OK", completionHandler: { (index) ->
                Void in
            })
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        var limit = 20
        
        switch textField {
        case enterNewPasswordTextField:
            limit=20
        case confirmNewPasswordTextField:
            limit=20
        default:
            limit=20
        }
        return (textField.text?.count ?? 0) < limit || string == ""
    }

    @IBAction func submitButtonAction(_ sender: Any)
    {
        if validation()
        {
        setNewPassword()
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setNewPassword(){
        
        // param dictionary
        var params : NSMutableDictionary = [:]
        let customerID = loginInfoDictionary[kCustomerId] as! Int
        params = [
            kCustomerPassword : enterNewPasswordTextField.text ?? "",
            kCustomerConfirmPassword: confirmNewPasswordTextField.text ?? "",
            kCustomerId : String(customerID)
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,"registration/setpassword"))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200"
                    {
                        self.performSegue(withIdentifier: ksegueLoginController, sender: nil)
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
    
}
