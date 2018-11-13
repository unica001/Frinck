//
//  FRForgotPasswordViewController.swift
//  Frinck
//
//  Created by sirez-ios on 11/04/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class FRForgotPasswordViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var mobileNumberTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        mobileNumberTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitButtonAction(_ sender: Any)
    {
        if validation() == true
        {
        mobileNumberTextField.resignFirstResponder()
        forgotPassword()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return (textField.text?.count ?? 0) < 10 || string == ""
    }
    
    func validation()-> Bool
    {
        if mobileNumberTextField.text == ""
        {
            alertController(controller: self, title: "", message: "Please enter valid Mobile No.", okButtonTitle: "OK", completionHandler: {(index) ->
                Void in
            })
            return false
        }
        else  if (mobileNumberTextField.text!.count != 10) {            alertController(controller: self, title: "", message: "The customer mobile no must be at least 10 characters.", okButtonTitle: "OK", completionHandler: {(index) -> Void in
        })
            return false;
        }
        return true
    }

    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:- APIs call
    
    func forgotPassword(){
        
        // param dictionary
        var params : NSMutableDictionary = [:]
        params = [
            kCustomerMobile : mobileNumberTextField.text ?? "",
        ]
        
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,"registration/forgotpassword"))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: true, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200"
                    {
//                    kUserDefault.set(NSKeyedArchiver.archivedData(withRootObject: dict[kPayload] as Any ), forKey: kloginInfo)
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "FRPasswordViewC") as! FRPasswordViewC
                        nextViewController.isChangePassword = false
                        nextViewController.mobileNoStr = self.mobileNumberTextField.text ?? ""
                        self.navigationController?.pushViewController(nextViewController, animated: true)
                        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kVerifyForgotPasswordSegueIdentifier{
            let otpViewController :FROTPViewController = segue.destination as! FROTPViewController
            print(self.mobileNumberTextField.text!)
            otpViewController.mobileNumberString = self.mobileNumberTextField.text!
            otpViewController.incommingType = "forgotPassword"
           
        }
    }
    
   
}
