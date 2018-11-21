//
//  FRMyPointsViewController.swift
//  Frinck
//
//  Created by vineet patidar on 14/06/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

enum MyPointsSelection : Int {
    case redeem = 0
    case myTransaction
    case purchasedOffer
    case howToEarnPoints
    
    
}
class FRMyPointsViewController:UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate {

    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collecrtionViewWidth: NSLayoutConstraint!
    @IBOutlet weak var pointsLogoImage: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    
    var pointCirculeHeight : CGFloat
        = 0.38 // iphne X
    
    var offerType : NSString = ""
    let moreArray = [["moreText": "Redeem", "moreImage" : #imageLiteral(resourceName: "Redeem")],["moreText": "My Transactions", "moreImage" : #imageLiteral(resourceName: "Transaction")],["moreText": "My Purchased Offers", "moreImage" : #imageLiteral(resourceName: "PurchasedOffer")],["moreText": "How it Works" ,"moreImage":#imageLiteral(resourceName: "how-it-works")]]
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = kLightGrayColor
        let pointGif = UIImage.gifImageWithName("Points")
        pointsLogoImage.image = pointGif
        
        if DeviceType.iPhone5orSE || DeviceType.iPhone4orLess{
            pointCirculeHeight = 0.35
            collecrtionViewWidth.constant = self.view.frame.size.width * 0.70
            logoWidthConstraint.constant =  (self.view.frame.size.width * 0.25) * 2
        }
        else if DeviceType.iPhone678{
            pointCirculeHeight = 0.33
            collecrtionViewWidth.constant = self.view.frame.size.width * 0.70
            logoWidthConstraint.constant =  (self.view.frame.size.width * pointCirculeHeight) * 2
        }
        else if DeviceType.iPhone678p{
            pointCirculeHeight = 0.35
            collecrtionViewWidth.constant = self.view.frame.size.width * 0.70
            logoWidthConstraint.constant =  (self.view.frame.size.width * pointCirculeHeight) * 2
        }
        else{
            collecrtionViewWidth.constant = self.view.frame.size.width * 0.80
//            logoWidthConstraint.constant =  (self.view.frame.size.width * pointCirculeHeight) * 2
        }
        collectionViewHeight.constant = (self.view.frame.size.width * pointCirculeHeight) * 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getMyPoits()
    }
    
    // MARK:- Collection view Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moreArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MoreCollectionViewCell
        let dict = moreArray[indexPath.row]
        cell.setInitialData(dictionary: dict, isMoreView: false)
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if DeviceType.iPhone5orSE{
            return CGSize(width: (collectionView.frame.size.width-25)/2, height: (collectionView.frame.size.width-25)/2) // The size of one cell
        } else {
            return CGSize(width: self.view.frame.size.width*pointCirculeHeight, height: self.view.frame.size.width*pointCirculeHeight) // The size of one cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0) // margin between cells
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case MyPointsSelection.redeem.rawValue :
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let redeemOfferViewController = storyboard.instantiateViewController(withIdentifier: "RedeemOfferStoryBoardID") as? FRRedeemViewController
            self.navigationController?.pushViewController(redeemOfferViewController!, animated: true)
        case MyPointsSelection.myTransaction.rawValue:
            let sb = UIStoryboard(name: "Profile", bundle: nil)
            let transactionViewC = sb.instantiateViewController(withIdentifier: "FRTransactionViewC") as? FRTransactionViewC
            self.navigationController?.pushViewController(transactionViewC!, animated: true)
        case MyPointsSelection.purchasedOffer.rawValue:
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let purchaseOffer = storyboard.instantiateViewController(withIdentifier: "FRMyPurchaseViewC") as? FRMyPurchaseViewC
            self.navigationController?.pushViewController(purchaseOffer!, animated: true)
        case MyPointsSelection.howToEarnPoints.rawValue:
            let sb = UIStoryboard(name: "Profile", bundle: nil)
            let howItWorkViewC = sb.instantiateViewController(withIdentifier: "HowItWorkViewC") as? HowItWorkViewC
            howItWorkViewC?.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(howItWorkViewC!, animated: true)
        default:
            break
        }
    }

    // MARK : Get Points
    func getMyPoits()  {
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId: loginInfoDictionary[kCustomerId]!,
        ]
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kusermypoint))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                let dict  = response!
                let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                if index == "200"
                {
                    if let payLoadDictionary = dict.value(forKey: kPayload) as? [String : Any]{
                        DispatchQueue.main.async {

                        let points : NSInteger = payLoadDictionary[kCustomerTotalPoint] as! NSInteger
                            self.pointsLabel.text = "\(String(points)) FRINCKS" }
                    }
                    
                }
            }
        }
    }
}
