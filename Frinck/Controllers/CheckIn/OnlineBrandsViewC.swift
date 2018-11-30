//
//  OnlineBrandsViewC.swift
//  Frinck
//
//  Created by Shilpa Sharma on 13/11/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SDWebImage

class OnlineBrandsViewC: UIViewController {

    @IBOutlet weak var collectionOnline: UICollectionView!
    var arrOnlineBrand = [[String : AnyObject]]()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionOnline.emptyDataSetDelegate = self
        collectionOnline.emptyDataSetSource = self
        self.getOnlineBrandList()
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
    
    @IBAction func tapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func getOnlineBrandList()
    {
        var params: NSMutableDictionary = [:]
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            kpageNo : "0",
//            kSearchKey: self.searchBarFavouritBrands.text as Any
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,konlineBrand))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            self.arrOnlineBrand = payload["storeList"] as! [[String : AnyObject]]
                            self.collectionOnline.reloadData()
                            
                        }
                    }
                    else
                    {
                        self.collectionOnline.reloadData()
                        //                        let message = dict[kMessage]
                        //
                        //                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                        //
                        //                        })
                        
                    }
                }
            }
        }
    }
    
}

extension OnlineBrandsViewC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // Mark : Collection Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrOnlineBrand.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onlineCell", for: indexPath)
        let dict = self.arrOnlineBrand[indexPath.row]
        let img = cell.contentView.viewWithTag(10) as! UIImageView
        if let urlString = dict[kstoreImage] as? String {
//            urlString = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let url = URL(string: urlString)
            img.sd_setImage(with:url , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
        } else {
            img.image = UIImage(named: "placeHolder")
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (ScreenSize.width-30)/2, height: 100) // The size of one cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(10, 10, 0, 10) // margin between cells
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let dict = arrOnlineBrand[indexPath.row]
        if let onlineUrl = dict[kstoreWebsite] as? String {
            let url : URL = URL(string: onlineUrl)!
            UIApplication.shared.open(url, options:[:] , completionHandler: nil)
        } else {
            alertController(controller: self, title: "", message: "No URL", okButtonTitle: "Ok") { (index) -> Void in
                
            }
        }
    }
}

extension OnlineBrandsViewC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let txtAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font: UIFont(name: kFontTextSemibold, size: 15.0)! , NSAttributedStringKey.foregroundColor: UIColor.black]
        let placeholderText = NSAttributedString(string: "There are no online brands.", attributes: txtAttributes)
        return placeholderText
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attString = NSAttributedString(string: "Refresh", attributes: [ NSAttributedStringKey.font: UIFont(name: kFontTextMedium, size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.red])
        return attString
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
    }
}
