//
//  FRSavedOfferViewC.swift
//  Frinck
//
//  Created by meenakshi on 6/6/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import ObjectMapper
import FirebaseDynamicLinks
import DZNEmptyDataSet

class FRSavedOfferViewC: UIViewController {

    @IBOutlet weak var collectionOffer: UICollectionView!
    var arrSavedOffer = [SavedOfferModel]()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionOffer.register(UINib(nibName: "CellOffer", bundle: nil), forCellWithReuseIdentifier: "CellOffer")
        collectionOffer.emptyDataSetDelegate = self
        collectionOffer.emptyDataSetSource = self
        self.callApiSavedOffer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: IBAction Method
    
    @IBAction func tapBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Api call
    
    func callApiSavedOffer() {
        var params: NSMutableDictionary = [:]
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        params = [ kCustomerId : loginInfoDictionary[kCustomerId]! as AnyObject]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,ksavedOffer))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let list = dict.value(forKey: kPayload) as? [String : Any] {
                            let list = list["offer"] as? [[String : Any]]
                            self.arrSavedOffer = Mapper<SavedOfferModel>().mapArray(JSONArray: list!)
                            self.collectionOffer.reloadData()
                        }
                    } else {
                        let message = dict[kMessage] as? String
//                        alertController(controller: self, title: "", message: message!, okButtonTitle: "Ok", completionHandler: { (value) in
//
//                            self.navigationController?.popViewController(animated: true)
//                        })
                    }
                }
            }
        }
    }
    
}

extension FRSavedOfferViewC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSavedOffer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellOffer", for: indexPath) as? CellOffer
        cell?.setOfferData(dictInfo: arrSavedOffer[indexPath.row])
        cell?.btnShare.tag = indexPath.row
        cell?.btnShare.addTarget(self, action: #selector(tapShareOffer(_:)), for: .touchUpInside)
        cell?.layer.cornerRadius = 10
        cell?.layer.masksToBounds = true
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (ScreenSize.width-30)/2, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 0, 10) 
    }
    
    @objc func tapShareOffer(_ button: UIButton) {
        let dict = arrSavedOffer[button.tag]
        let link = createURLWithString(dict: dict as SavedOfferModel)
        createDnamicLink(link: link!)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    }
}

extension FRSavedOfferViewC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let txtAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font: UIFont(name: kFontTextSemibold, size: 15.0)! , NSAttributedStringKey.foregroundColor: UIColor.black]
        let placeholderText = NSAttributedString(string: "No saved offers.", attributes: txtAttributes)
        return placeholderText
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attString = NSAttributedString(string: "Refresh", attributes: [ NSAttributedStringKey.font: UIFont(name: kFontTextMedium, size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.red])
        return attString
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.callApiSavedOffer()
    }
}

extension FRSavedOfferViewC {
    
    //Create and Share URL
    func createURLWithString(dict: SavedOfferModel) -> URL? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https";
        urlComponents.host = "frinck.page.link";
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        // add params
        let offerid  = String(dict.offerId as! Int)
        let typeQuery = NSURLQueryItem(name: "link_type", value: "offer")
        let storyIdQuery = NSURLQueryItem(name: kOfferId, value: offerid)
        let inviteQuery = NSURLQueryItem(name: "invited_by", value: "\(loginInfoDictionary[kCustomerUserName] ?? "")")
        urlComponents.queryItems = [typeQuery as URLQueryItem, storyIdQuery as URLQueryItem, inviteQuery as URLQueryItem]
        return urlComponents.url
    }
    
    func createDnamicLink(link: URL) {
        let components = DynamicLinkComponents(link: link, domain: "frinck.page.link")
        let iOSParams = DynamicLinkIOSParameters(bundleID: "frinck.com.frinckapp")
        iOSParams.appStoreID = "987654321"
        iOSParams.customScheme = "frinck.com.frinckapp"
        components.iOSParameters = iOSParams
        
        // Android params
        let androidParams = DynamicLinkAndroidParameters(packageName: "com.frinck")
        components.androidParameters = androidParams
        
        //social tag params
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        let socialParams = DynamicLinkSocialMetaTagParameters()
        if let name = loginInfoDictionary[kCustomerUserName] {
            socialParams.descriptionText = "\(name) shared a offer with you."
        }
        //        var metaImage = Constant.appLogoUrl
        //        if let shareAs = topic.shareAs, shareAs == ShareAs.showIdentity.rawValue {
        //            if let userPic = topic.userPicture, userPic != "" {
        //                metaImage = userPic
        //            }
        //        }
        //        socialParams.imageURL = URL(string: metaImage)
        components.socialMetaTagParameters = socialParams
        
        components.shorten { (shortURL, warnings, error) in
            // Handle shortURL.
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let shortLink = shortURL
            if let link = shortLink?.absoluteString, link != "" {
                self.sendLink(shortLinkStr: link)
            }
        }
    }
    
    func sendLink(shortLinkStr: String) {
        if let myWebsite = NSURL(string: shortLinkStr) {
            let objectsToShare = [myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}
