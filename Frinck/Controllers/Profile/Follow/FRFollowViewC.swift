//
//  FRFollowViewC.swift
//  Frinck
//
//  Created by meenakshi on 5/28/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SDWebImage
import ObjectMapper
import DZNEmptyDataSet

class FRFollowViewC: UIViewController {

    @IBOutlet weak var tblFollow: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet var btnAdd: UIBarButtonItem!
    internal var viewModel: FollowViewModelling?
    var loginInfoDictionary :NSMutableDictionary!
    var arrList = [UserListModel]()
    var isFollowers = Bool()
    var pageIndex = 1
    var totalCount = 0
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callApiFollowList(strSearch: "")
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

    //MARK: - Private Methods
    
    private func recheckVM() {
        if self.viewModel == nil {
            self.viewModel = FollowViewModel()
        }
    }
    
    private func setUpView() {
        recheckVM()
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        self.navigationItem.title = (isFollowers) ? "Followers" : "Following"
        btnAdd.isEnabled = (isFollowers) ? false : true
        btnAdd.image = (isFollowers) ? UIImage(named: "") : #imageLiteral(resourceName: "add")
//        btnAdd.tintColor = (isFollowers) ? UIColor.clear
        searchBar.placeholder = (isFollowers) ? "Search Followers" : "Search Followings"
        tblFollow.emptyDataSetSource = self
        tblFollow.emptyDataSetDelegate = self
        tblFollow.register(UINib (nibName: "CellFollow", bundle: nil), forCellReuseIdentifier: "CellFollow")
    }
    
    //MARK: - IBAction Methods
    
    @IBAction func tapBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapAdd(_ sender: Any) {
        let storyB = UIStoryboard(name: "Profile", bundle: nil)
        let searchViewC = storyB.instantiateViewController(withIdentifier: "FRSearchUserViewC") as? FRSearchUserViewC
        self.navigationController?.pushViewController(searchViewC!, animated: true)	
    }    
    
    //MARK: - API call
    
    func callApiFollowList(strSearch: String) {
        self.viewModel?.getFollowList(pageIndex: pageIndex as AnyObject, strSearch: strSearch as AnyObject, customerId: loginInfoDictionary[kCustomerId]! as AnyObject, isFollowers: isFollowers, followListHandler: { [weak self] (response, total, isSuccess, msg) in
            guard self != nil else { return }
            if isSuccess {
                self?.totalCount = total
                if self?.pageIndex == 1 {
                    self?.arrList = response
                } else {
                    for i in 0 ..< response.count {
                        let dict = response[i]
                        self!.arrList.append(dict)
                    }
                }
                self?.tblFollow.reloadData()
            } else {
                self?.arrList = []
                self?.tblFollow.reloadData()
            }
            
        })
    }
}

extension FRFollowViewC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CellFollow = tableView.dequeueReusableCell(withIdentifier: "CellFollow", for: indexPath) as! CellFollow
        cell.configureCell(dictInfo: arrList[indexPath.row], isUserList: false)
        cell.delegate = self
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if totalCount > arrList.count {
            if maximumOffset - currentOffset <= -40 && arrList.count != 0 && arrList.count%10 == 0 {
                pageIndex = pageIndex + 1
                callApiFollowList(strSearch: searchBar.text!)
            }
        }
    }

}

extension FRFollowViewC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let txtAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font: UIFont(name: kFontTextSemibold, size: 15.0)! , NSAttributedStringKey.foregroundColor: UIColor.black]
        let placeholderText = NSAttributedString(string: (isFollowers) ? "No Followers" : "No Following", attributes: txtAttributes)
        return placeholderText
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attString = NSAttributedString(string: "Refresh", attributes: [ NSAttributedStringKey.font: UIFont(name: kFontTextMedium, size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.red])
        return attString
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.pageIndex = 1
        self.callApiFollowList(strSearch: searchBar.text!)
    }
}

extension FRFollowViewC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let str = (searchBar.text as NSString?)?.replacingCharacters(in: range, with: text)
        let newLength = (searchBar.text?.count)! + text.count - range.length
        if let text = str {
            if newLength >= 3 || newLength == 0 {
                self.callApiFollowList(strSearch: text)
            }
        }
        return true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            self.callApiFollowList(strSearch: "")
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}

extension FRFollowViewC: UserDelegate {
    
    func didActionFollow(sender: UIButton, actionType: ActionType) {
        let point = tblFollow.convert(sender.bounds.origin, from: sender)
        let indexPath = tblFollow.indexPathForRow(at: point)
        if actionType == ActionType.threeDot {
            popUp(index: indexPath!)
        }
    }

    func popUp(index : IndexPath) {
        let dict = arrList[index.row]
        let strMessage = (isFollowers) ? "Are you sure you want to remove \(String(describing: dict.CustomerUserName!)) from the list?" : "Are you sure you want to unfollow \(String(describing: dict.CustomerUserName!))?"
        let viewAlert = CustomAlert(frame: self.view.bounds)
        viewAlert.loadView(customType: .TwoButton, strMsg: strMessage, type: .select, image:(isFollowers) ? #imageLiteral(resourceName: "followers") : #imageLiteral(resourceName: "following")) { (success) in
            if let isSucess = success as? Bool, isSucess == true {
                if self.isFollowers {
                    self.viewModel?.removeRequest(customerId: self.loginInfoDictionary[kCustomerId]! as AnyObject, requestID: dict.CustomerId as AnyObject, unfollowReqHandler: { [weak self] (result, isSuccess, msg) in
                        guard self != nil else { return }
                        if isSuccess {
                            viewAlert.removeFromSuperview()
                            self?.arrList.remove(at: index.row)
                            self?.tblFollow.reloadData()
                        } else {
                            viewAlert.removeFromSuperview()
                            alertController(controller: self!, title: "", message: msg, okButtonTitle: "OK", completionHandler: { (value) in
                                
                            })
                        }
                    })
                } else {
                    self.viewModel?.unfollowRequest(customerId: self.loginInfoDictionary[kCustomerId]! as AnyObject, requestID: dict.CustomerId as AnyObject, unfollowReqHandler: { [weak self] (result, isSuccess, msg) in
                        guard self != nil else { return }
                        if isSuccess {
                            viewAlert.removeFromSuperview()
                            self?.arrList.remove(at: index.row)
                            self?.tblFollow.reloadData()
                        } else {
                            viewAlert.removeFromSuperview()
                            alertController(controller: self!, title: "", message: msg, okButtonTitle: "OK", completionHandler: { (value) in
                                
                            })
                        }
                    })
                }
            } else {
                viewAlert.removeFromSuperview()
            }
        }
        let window = UIApplication.shared.keyWindow!
        window.addSubview(viewAlert)
    }
    
}
