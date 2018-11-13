//
//  FRMyPurchaseViewC.swift
//  Frinck
//
//  Created by Meenkashi on 7/30/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class FRMyPurchaseViewC: UIViewController {

    @IBOutlet var collectionPurchase: UICollectionView!
    var arrPuchaseOffer = [[String : Any]]()
    var showHude : Bool = false
    var pageIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionPurchase.emptyDataSetSource = self
        collectionPurchase.emptyDataSetDelegate = self
        callApiPurchaseOffer()
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
    
    @IBAction func tapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func callApiPurchaseOffer() {
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        let params: NSMutableDictionary = [ kCustomerId : loginInfoDictionary[kCustomerId]! as AnyObject,
                                            "PageNo" : pageIndex ]
        
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kmyPurchaseVoucher))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            if self.pageIndex == 1 {
                            self.arrPuchaseOffer = payload["purchasedVoucher"] as! [[String : AnyObject]]
                            } else {
                                let arr = payload["purchasedVoucher"] as! [[String : AnyObject]]
                                for i in 0 ..< arr.count {
                                    let dict = arr[i]
                                    self.arrPuchaseOffer.append(dict)
                                }
                            }
                            self.collectionPurchase.reloadData()
                        }
                    } else {
                        
                        let message = dict[kMessage] as? String
//                        let offerDetails   =    Mapper<RedeemOfferDetailModel>().map(JSON: dict.value(forKey: kPayload) as! [String : Any])
//                        redeemOfferHandelling(offerDetails!, false, message!)
                    }
                }
            }
        }
    }
    
}


extension FRMyPurchaseViewC : UICollectionViewDelegate{
    
    // MARK:- Collection view Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPuchaseOffer.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyPurchaseOfferCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.setOfferData(dict:arrPuchaseOffer[indexPath.row])        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (ScreenSize.width-30)/2, height: 180) // The size of one cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 0, 10) // margin between cells
    }
}

extension FRMyPurchaseViewC : UICollectionViewDataSource {
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let dict = offerFilterArray[indexPath.row]
//        self.performSegue(withIdentifier: kRedeemSegueIdentifier, sender: dict)
//    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if maximumOffset - currentOffset <= -40 && arrPuchaseOffer.count != 0 {
            pageIndex = pageIndex + 1
            showHude = true
            callApiPurchaseOffer()
        }
    }
}

extension FRMyPurchaseViewC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let txtAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font: UIFont(name: kFontTextSemibold, size: 15.0)! , NSAttributedStringKey.foregroundColor: UIColor.black]
        let placeholderText = NSAttributedString(string: "No purchased offer found", attributes: txtAttributes)
        return placeholderText
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attString = NSAttributedString(string: "Refresh", attributes: [ NSAttributedStringKey.font: UIFont(name: kFontTextMedium, size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.red])
        return attString
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.pageIndex = 1
        callApiPurchaseOffer()
    }
}

