//
//  MyCheckInViewController.swift
//  Frinck
//
//  Created by vineet patidar on 21/05/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class MyCheckInViewController: UIViewController {

    @IBOutlet var noRecordLable: UILabel!
    @IBOutlet var checkInTable: UITableView!
    
    var loginInfoDictionary :NSMutableDictionary!
    var storeList = [[String:Any]]()
    var pageIndex = 1
    var totalCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        checkInTable.emptyDataSetDelegate = self
        checkInTable.emptyDataSetSource = self
//        getStoreList()
        
        checkInTable.register(UINib(nibName: "MyCheckInCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStoreList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Button Action
    
    @IBAction func backButtonAction(_ sender: Any) {
        if (self.navigationController?.viewControllers.count)! > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            AppDelegate.delegate.goToHomeScreen()
        }
    }
    
    @objc func postStoryButtonAction(_ sender: Any){
//        let sb = UIStoryboard(name: "Home", bundle: nil)
//        let createViewC = sb.instantiateViewController(withIdentifier: "CreatStoryViewController") as? CreatStoryViewController
//        createViewC?.selectedDictioinary = storeList[(sender as AnyObject).tag]
//        self.navigationController?.pushViewController(createViewC!, animated: true)
        self.performSegue(withIdentifier: kstatusSegueIdentifier, sender: storeList[(sender as AnyObject).tag])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == kstatusSegueIdentifier {
            let statusViewController : CheckInStatusViewController = (segue.destination as? CheckInStatusViewController)!
            statusViewController.selectedDictioinary = sender as! [String : Any]
            statusViewController.isMyCheckin = true
        }
    }
    
    //MARK: - API Call
    
    func getStoreList()
    {
        let appDelegate : AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            kLatitude : appDelegate.lat,
            kLongitude : appDelegate.long,
            kpageNo : pageIndex
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kmycheckinstore))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        
                        if let payload = dict.value(forKey: kPayload) as? [String : Any]{
                            self.totalCount = payload["total"] as! Int
                        if self.pageIndex == 1 {
                            self.storeList = payload["storeList"] as! [[String : Any]]
                        } else {
                            let addMoreArray = payload["storeList"] as! [[String : Any]]
                            self.storeList.append(contentsOf: addMoreArray)
                        }
                        }
                        print("My check in \(self.storeList)")
                        if self.storeList.count == 0 {
                            self.checkInTable.isHidden = true
//                            self.noRecordLable.isHidden = false
                        }
                        else {
                            self.checkInTable.isHidden = false
//                            self.noRecordLable.isHidden = true
                        }
                        self.checkInTable.reloadData()
                    }
                    else
                    {
                        let message = dict[kMessage]
                        self.checkInTable.reloadData()
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

extension MyCheckInViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MyCheckInCell
        cell?.selectionStyle = .none
        
//        if self.storeList.count > 0 {
            cell?.setData(dict: storeList[indexPath.row])
//        }
        
        cell?.postStoryButton.addTarget(self, action: #selector(postStoryButtonAction), for: .touchUpInside)
        cell?.postStoryButton.tag = indexPath.row
        return cell!
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if totalCount > storeList.count {
            if maximumOffset - currentOffset <= -40 && storeList.count != 0 && storeList.count%10 == 0 {
                pageIndex = pageIndex + 1
                getStoreList()
            }
        }
    }
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return self.storeList.count
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storeList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
////        if self.storeList.count == 0 {
////            return 0
////        }
//
//        let storeName = self.storeList[indexPath.section][kStoreName] as? String
//        let isExpire : Int = (self.storeList[indexPath.section][kIsExpire] as? Int)!
//
//
//        var cellHeight : Float = 0.0
//        if  String(isExpire) == "1" {
//            cellHeight = 20
//        }
//
//        let height = Float((storeName?.height(withConstrainedWidth: ScreenSize.width - 200, font: UIFont(name: kFontTextRegularBold, size: 13)!))!)
//        if height > 32{
//            return CGFloat(height + 52.0 + cellHeight)
//        }
        return UITableViewAutomaticDimension;
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
}

extension MyCheckInViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let txtAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font: UIFont(name: kFontTextSemibold, size: 15.0)! , NSAttributedStringKey.foregroundColor: UIColor.black]
        let placeholderText = NSAttributedString(string: "Your check in are not available to any store till now.", attributes: txtAttributes)
        return placeholderText
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attString = NSAttributedString(string: "Refresh", attributes: [ NSAttributedStringKey.font: UIFont(name: kFontTextMedium, size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.red])
        return attString
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.pageIndex = 1
        self.getStoreList()
    }
}


extension MyCheckInViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
