//
//  FRReportViewC.swift
//  Frinck
//
//  Created by Meenkashi on 6/25/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class FRReportViewC: UIViewController, UITextViewDelegate {
    
    @IBOutlet var lblFeedback: UILabel!
    @IBOutlet var btnSubmit: UIButton!
    @IBOutlet var txtFeedback: UITextView!
    var loginInfoDictionary :NSMutableDictionary!
    var isFromReportUser : Bool = false
    var userId : Int = 0
    var storyId : Int = 0
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        btnSubmit.layer.cornerRadius = btnSubmit.frame.size.height/2
        btnSubmit.layer.masksToBounds = true
        txtFeedback.delegate = self
//        txtFeedback.layer.borderWidth = 1.0
//        txtFeedback.layer.borderColor = UIColor.lightGray.cgColor
//        txtFeedback.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - IBAction Methods
    @IBAction func tapBack(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapSubmit(_ sender: UIButton) {
        if txtFeedback.text == "" {
            alertController(controller: self, title: "", message: "Please enter feedback", okButtonTitle: "Ok", completionHandler: { (value) in
            })
            return
        }
        if isFromReportUser {
            callApiReportUser()
        } else {
            callApiFlagInappropriate()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //        self.view.endEditing(true)
        lblFeedback.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.endEditing(true)
        lblFeedback.isHidden = (textView.text == "") ? false : true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        lblFeedback.isHidden = (textView.text == "") ? false : true
        return true
    }
    
    //MARK: - API Call
    
    func callApiReportUser() {
        
        let params: NSMutableDictionary = [kCustomerId : loginInfoDictionary[kCustomerId]!,
                                            "userId" : self.userId,
                                            "feedBack" : txtFeedback.text]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kreportUser))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    let message = dict[kMessage] as? String
                    if index == "200" {
                        alertController(controller: self, title: "", message: message!, okButtonTitle: "Ok", completionHandler: { (value) in
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        let message = dict[kMessage] as? String
//                        unfollowReqHandler([:], false, message!)
                    }
                }
            }
        }
    }
    
    func callApiFlagInappropriate() {
        
        let params: NSMutableDictionary = [kCustomerId : loginInfoDictionary[kCustomerId]!,
                                           "storyId" : self.storyId,
                                           "userId" : self.userId,
                                           "feedBack" : txtFeedback.text]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kreportUser))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    let message = dict[kMessage] as? String
                    if index == "200" {
                        alertController(controller: self, title: "", message: message!, okButtonTitle: "Ok", completionHandler: { (value) in
                            _ = self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        let message = dict[kMessage] as? String
                        //                        unfollowReqHandler([:], false, message!)
                    }
                }
            }
        }
    }
}

