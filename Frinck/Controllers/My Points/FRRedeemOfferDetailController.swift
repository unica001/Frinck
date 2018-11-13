//
//  FRRedeemOfferDetailController.swift
//  Frinck
//
//  Created by vineet patidar on 19/06/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import Razorpay

class FRRedeemOfferDetailController: UIViewController,RazorpayPaymentCompletionProtocol {
    
    @IBOutlet weak var redeemTable: UITableView!
    @IBOutlet weak var checkMarkButton: UIButton!
    @IBOutlet weak var payNowButton: UIButton!
    
   var quantituTextField: UITextField!
   var pointsTextField: UITextField!
   var userPointsTextField: UITextField!
   var cashPayableTexField: UITextField!
   var loginInfoDictionary :NSMutableDictionary!
  internal var viewModel: RedeemOfferModelling?

    
    var isTermConditionSelected : Bool = false
    let keyId = "rzp_test_yHXxXqe0i9wGoA"
    var razorpay: Razorpay!
    
    var redeemOfferDict : RedeemOfferListModel!
    var offerDetailModel : RedeemOfferDetailModel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel == nil {
            viewModel = RedeemOfferModule()
        }
        
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary

        razorpay = Razorpay.initWithKey(keyId, andDelegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    @IBAction func termAndConditionButtonAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let webViewC = storyboard.instantiateViewController(withIdentifier: "FRWebViewC") as? FRWebViewC
        webViewC?.strHeader = "Terms and Conditions"
        self.navigationController?.pushViewController(webViewC!, animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkMarkButtonAction(_ sender: Any) {
        if isTermConditionSelected == false {
            isTermConditionSelected = true
            checkMarkButton.setImage(#imageLiteral(resourceName: "roundCheck"), for: .normal)
        } else {
            checkMarkButton.setImage(#imageLiteral(resourceName: "roundCheckGray"), for: .normal)
            isTermConditionSelected = false
        }
    }
    
    @IBAction func paynowButtonAction(_ sender: Any) {
        
        if validation() == true {
            
            if cashPayableTexField.text! == "0.0" {
                let customerID = loginInfoDictionary[kCustomerId]
                viewModel?.purchasePoint(customerID as AnyObject, self.redeemOfferDict.voucherId as AnyObject, cashPayableTexField.text as AnyObject, pointsTextField.text as AnyObject, quantituTextField.text as AnyObject, pointPurchaseHandelling: { (isSuccess , message) in
                    
                    if isSuccess == true {
                        
                        alertController(controller: self, title: "Point Purchase", message: message, okButtonTitle: "Ok", completionHandler: {(index) -> Void in
                            let sb = UIStoryboard(name: "Profile", bundle: nil)
                            let transactionViewC = sb.instantiateViewController(withIdentifier: "FRTransactionViewC") as? FRTransactionViewC
                            self.navigationController?.pushViewController(transactionViewC!, animated: true)
                        })
                       
                    }
                    else {
                        alertController(controller: self, title: "Point Purchase", message: message, okButtonTitle: "Ok", completionHandler: {(index) -> Void in
                            
                        })
                    }
                })
            }
            else {
                 showPaymentForm()
            }
        }
    }
    
    // MARK : Payment getway
    
    internal func showPaymentForm(){
        
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        let options: [String:Any] = [
            "amount" : String(Float(cashPayableTexField.text!)! * 100),
            "description": "testing purpose",
            "image": "https://url-to-image.png",
            "name": loginInfoDictionary.value(forKey: kCustomerName)!,
            "prefill": [
                "contact": loginInfoDictionary.value(forKey: kCustomerMobile)!,
                "email": loginInfoDictionary.value(forKey: kCustomerEmail)!,
            ],
            "theme": [
                "color": "#F37254"
            ]
        ]
        razorpay.open(options)
    }
    
    public func onPaymentError(_ code: Int32, description str: String){
        let alertController = UIAlertController(title: "FAILURE", message: str, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.view.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    public func onPaymentSuccess(_ payment_id: String){
         let customerID = loginInfoDictionary[kCustomerId]
        viewModel?.purchasePointByCash(customerID as AnyObject, payment_id as AnyObject, self.redeemOfferDict.voucherId as AnyObject, cashPayableTexField.text as AnyObject,pointsTextField.text as AnyObject, quantituTextField.text as AnyObject, pointPurchaseHandelling: {(isSuccess, message) in
            
            if isSuccess == true {
                
                let alertController = UIAlertController(title: "SUCCESS", message: message, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {(index) -> Void in
                    
                    let sb = UIStoryboard(name: "Profile", bundle: nil)
                    let transactionViewC = sb.instantiateViewController(withIdentifier: "FRTransactionViewC") as? FRTransactionViewC
                    self.navigationController?.pushViewController(transactionViewC!, animated: true)
                })
                alertController.addAction(cancelAction)
                self.view.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            } else {
                
                let alertController = UIAlertController(title: "SUCCESS", message: message, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.view.window?.rootViewController?.present(alertController, animated: true, completion: nil)
               
            }

            
        })
        
    }
    
    func validation() -> Bool{
        
        if isTermConditionSelected == false {
            alertController(controller: self, title: "", message: "Select Terms and Conditions", okButtonTitle: "OK", completionHandler: { (valid) in
            })
            return false

        }
        return true
    }
    
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
extension FRRedeemOfferDetailController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 345
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? RedeemOfferDetailCell
        cell?.offerDetailModel = self.offerDetailModel
        cell?.setData(dict: redeemOfferDict)
        
        quantituTextField = cell?.quantituTextField
        pointsTextField = cell?.pointsTextField
        userPointsTextField = cell?.userPointsTextField
        cashPayableTexField = cell?.cashPayableTexField
        
        return cell!
    }
}
