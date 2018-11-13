//
//  FRSearchUserViewC.swift
//  Frinck
//
//  Created by meenakshi on 5/28/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import ObjectMapper

class FRSearchUserViewC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblSearchUser: UITableView!
    var loginInfoDictionary : NSMutableDictionary!
    
    internal var viewModel: UserViewModelling?
    var arrUserList = [UserListModel]()
    var pageIndex = 1
    var totalCount = 0
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        callApiUserList(strSearch: "")
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
            self.viewModel = UserViewModel()
        }
    }
    
    private func setUpView() {
        recheckVM()
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        self.tblSearchUser.register(UINib.init(nibName: "CellFollow", bundle: nil), forCellReuseIdentifier: "CellFollow")
//        self.callApiUserList(strSearch: "")
    }
    

    //MARK- IBAction Method
    @IBAction func tapBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - API
    func callApiUserList(strSearch: String) {
        self.viewModel?.getUserList(pageIndex: pageIndex as AnyObject, strSearch: strSearch as AnyObject, customerId: loginInfoDictionary[kCustomerId]! as AnyObject, userListHandler: { [weak self] (response, total, isSuccess, msg) in
            guard self != nil else { return }
            if isSuccess {
                self?.totalCount = total
                if self?.pageIndex == 1 {
                    self?.arrUserList = response
                } else {
                    for i in 0 ..< response.count {
                        let dict = response[i]
                        self?.arrUserList.append(dict)
                    }
                }
                self?.tblSearchUser.reloadData()
            } else {
//                alertController(controller: self!, title: "", message:msg, okButtonTitle: "OK", completionHandler: {(index) -> Void in
//                    
//                })
            }
            
        })
    }
}

extension FRSearchUserViewC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let str = (searchBar.text as NSString?)?.replacingCharacters(in: range, with: text)
        let newLength = (searchBar.text?.count)! + text.count - range.length
        if let text = str {
            if newLength >= 2 || newLength == 0 {
                self.callApiUserList(strSearch: text)
            }
        }
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}

extension FRSearchUserViewC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUserList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CellFollow = tableView.dequeueReusableCell(withIdentifier: "CellFollow", for: indexPath) as! CellFollow
        cell.configureCell(dictInfo: arrUserList[indexPath.row],isUserList: true)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = arrUserList[indexPath.row]
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let profile = storyboard.instantiateViewController(withIdentifier: "FRProfileViewC") as? FRProfileViewC
        profile?.userId = dict.CustomerId
        self.navigationController?.pushViewController(profile!, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if totalCount > arrUserList.count {
            if maximumOffset - currentOffset <= -40 && arrUserList.count != 0 && arrUserList.count%10 == 0 {
                pageIndex = pageIndex + 1
                self.callApiUserList(strSearch: searchBar.text!)
            }
        }
    }
    

}

extension FRSearchUserViewC: UserDelegate {
    
    func didActionFollow(sender: UIButton, actionType: ActionType) {
        let point = tblSearchUser.convert(sender.bounds.origin, from: sender)
        let indexPath = tblSearchUser.indexPathForRow(at: point)
        if indexPath != nil  {
            let dict = arrUserList[(indexPath?.row)!]
            if actionType == ActionType.follow {
                if dict.isBlock == 1 {
                    self.viewModel?.unBlockRequest(customerId: self.loginInfoDictionary[kCustomerId]! as AnyObject, requestId: dict.CustomerId as AnyObject, unblockReqHandler: { [weak self] (result, isSuccess, msg) in
                        guard self != nil else { return }
                        if isSuccess {
                            dict.isBlock = 0
                            self?.arrUserList[(indexPath?.row)!] = dict
                            self?.tblSearchUser.reloadData()
                        } else {
                            alertController(controller: self!, title: "", message:msg, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                                
                            })
                        }
                    })
                } else {
                    if dict.isFollow == "follow" {
                        self.viewModel?.followRequest(customerId: self.loginInfoDictionary[kCustomerId]! as AnyObject, requestID: dict.CustomerId as AnyObject, isFollow: false, unfollowReqHandler: { [weak self] (result, isSuccess, msg) in
                            guard self != nil else { return }
                            if isSuccess {
                                dict.isFollow = "unfollow"
                                self?.arrUserList[(indexPath?.row)!] = dict
                                self?.tblSearchUser.reloadData()
                            } else {
                                alertController(controller: self!, title: "", message:msg, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                                    
                                })
                            }
                        })
                    } else {
                        self.viewModel?.followRequest(customerId: self.loginInfoDictionary[kCustomerId]! as AnyObject, requestID: dict.CustomerId as AnyObject, isFollow: true , unfollowReqHandler: { [weak self] (result, isSuccess, msg) in
                            guard self != nil else { return }
                            if isSuccess {
                                dict.isFollow = "follow"
                                self?.arrUserList[(indexPath?.row)!] = dict
                                self?.tblSearchUser.reloadData()
                                
                            } else {
                                alertController(controller: self!, title: "", message:msg, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                                    
                                })
                            }
                        })
                    }
                }
               
            }
        }
    }
    
}
