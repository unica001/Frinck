//
//  FRPasswordViewC.swift
//  Frinck
//
//  Created by meenakshi on 6/6/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class FRPasswordViewC: UIViewController, UITextFieldDelegate {

    @IBOutlet var cnstViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewFields: UIView!
    @IBOutlet weak var cnstViewHt: NSLayoutConstraint!
    @IBOutlet weak var txtField1: UITextField!
    @IBOutlet weak var txtField2: UITextField!
    @IBOutlet weak var txtField3: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    
    var isChangePassword : Bool = true
    var mobileNoStr = ""
    internal var viewModel : PasswordViewModeling?
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    //MARK: - Private Method
    
    private func recheckVM() {
        if viewModel == nil {
            viewModel = PasswordVM()
        }
    }
    
    private func setUpView() {
        recheckVM()
        txtField2.delegate = self
        txtField1.delegate = self
        txtField3.delegate = self
        txtField1.placeholder = (isChangePassword) ? "Enter Old Password" : "Enter OTP"
        txtField2.placeholder = (isChangePassword) ? "Enter New Password" : "Enter New Password"
        txtField3.placeholder = (isChangePassword) ? "Confirm New Password" : "Enter Confirm Password"
        cnstViewHeight.constant = (DeviceType.iPhone5orSE) ? 50 : 0
        btnSubmit.setTitle((isChangePassword) ? "UPDATE" : "SUBMIT", for: .normal)
        btnSubmit.layer.cornerRadius = btnSubmit.frame.size.height/2
        btnSubmit.layer.masksToBounds = true
        viewFields.layer.shadowRadius = 4.0
        viewFields.layer.shadowOpacity = 1.0
        viewFields.layer.shadowColor = UIColor.lightGray.cgColor
        viewFields.layer.cornerRadius = 3
        txtField1.isSecureTextEntry = (isChangePassword) ? true : false
        txtField1.keyboardType = (isChangePassword) ? .default : .numberPad
        self.navigationItem.title = (isChangePassword) ? "Reset Password" : "Set New Password"
    }

    func showCustomView(msg: String, isSuccess: Bool) {
        let viewAlert = CustomAlert(frame: self.view.bounds)
        viewAlert.loadView(customType: .TwoButton, strMsg: msg, type: .ok, image: #imageLiteral(resourceName: "Set_password")) { (success) in
            viewAlert.removeFromSuperview()
            if let isValid = success as? Bool, isValid == true && isSuccess {
                if self.isChangePassword {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    for controller in (self.navigationController?.viewControllers)! {
                        if controller.isKind(of: FRLoginViewController.self) {
                            self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }
                }
            }
        }
        self.view.addSubview(viewAlert)
    }
    
    //MARK: - IBAction Methods
    
    @IBAction func tapBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
 
    @IBAction func tapPassword(_ sender: UIButton) {
        
        self.view.endEditing(true)
        if isChangePassword {
            let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
            self.viewModel?.validateResetPwdFields(txtField1.text!, txtField2.text!, txtField3.text!, loginInfoDictionary[kCustomerId]! as AnyObject , validHandler: { [weak self] (res, msg, success) in
                guard self != nil else { return }
                if success {
                    self?.viewModel?.callApiPassword(param: res, isChangePwd: true, pwdHandler: { (isSuccess, msg) in
                        self?.showCustomView(msg: msg, isSuccess: isSuccess)
                    })
                } else {
                    alertController(controller: self!, title: "", message: msg, okButtonTitle: "OK", completionHandler: { (valid) in
                    })
                }
            })
        } else {
            self.viewModel?.validateSetPwdFields(txtField1.text!, txtField2.text!, txtField3.text!, mobileNoStr as AnyObject, validHandler: { [weak self](res, msg, success) in
                guard self != nil else { return }
                if success {
                    self?.viewModel?.callApiPassword(param: res, isChangePwd: false, pwdHandler: { (isSuccess, msg) in
                        self?.showCustomView(msg: msg, isSuccess: isSuccess)
                    })
                } else {
                    alertController(controller: self!, title: "", message: msg, okButtonTitle: "Ok", completionHandler: { (valid) in
                    })
                }
            })
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if !isChangePassword {
            if textField == txtField1 {
                return (textField.text?.count ?? 0) < 4 || string == ""
            }
        }
        let limit = 20
        return (textField.text?.count ?? 0) < limit || string == ""
    }
}
