//
//  FRTransactionViewC.swift
//  Frinck
//
//  Created by Meenkashi on 6/18/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class FRTransactionViewC: UIViewController {

    @IBOutlet var segmentTransaction: UISegmentedControl!
    @IBOutlet var tblTransaction: UITableView!
    var myPaidTransaction = [MyTransactionListModel]()
    var earnedTransaction = [EarnedPointModel]()
    var isEarned : Bool = false
    var pageIndex = 1
    var totalCount = 0
    
    var viewModel : MyTransactionModelling?
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let sortedViews = segmentTransaction.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        sortedViews[0].tintColor = UIColor.red
        tblTransaction.register(UINib.init(nibName: "TransactionCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
        tblTransaction.register(UINib(nibName: "EarnedCell", bundle: nil), forCellReuseIdentifier: "EarnedCell")
        tblTransaction.emptyDataSetSource = self
        tblTransaction.emptyDataSetDelegate = self
        if viewModel == nil {
            viewModel = MyTransactionModel()
        }
        
        getMyTransactionList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if isEarned {
            if totalCount > earnedTransaction.count {
                if maximumOffset - currentOffset <= -40 && earnedTransaction.count != 0 && earnedTransaction.count%10 == 0 {
                    pageIndex = pageIndex + 1
                    getEarnedList()
                }
            }
        } else {
            if totalCount > myPaidTransaction.count {
                if maximumOffset - currentOffset <= -40 && myPaidTransaction.count != 0 && myPaidTransaction.count%10 == 0 {
                    pageIndex = pageIndex + 1
                    getMyTransactionList()
                }
            }
        }
        
    }

   
    //MARK: - IBAction Methods
    
    @IBAction func tapBack(_ sender: Any) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func tapSegment(_ sender: UISegmentedControl) {
        let sortedViews = sender.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        
        for (index, view) in sortedViews.enumerated() {
            if index == sender.selectedSegmentIndex {
                view.tintColor = UIColor.red
            } else {
                view.tintColor = UIColor.black
            }
        }
        pageIndex = 1
        totalCount = 0
        if sender.selectedSegmentIndex == 0 {
            isEarned = false
            getMyTransactionList()
        } else {
            isEarned = true
            getEarnedList()
        }
    }
    
    
    func getMyTransactionList(){        
        let  loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary

        viewModel?.setPayedTransaction(customerId: loginInfoDictionary[kCustomerId]! as AnyObject, pageIndex: pageIndex as AnyObject, myTransactionHandelling: { [weak self] (isSuccess, responce, total) in
            guard self != nil else { return }
            if isSuccess {
                self?.totalCount = total
                if self?.pageIndex == 1 {
                    self?.myPaidTransaction = responce
                } else {
                    for i in 0 ..< responce.count {
                        let dict = responce[i]
                        self!.myPaidTransaction.append(dict)
                    }
                }
                self?.tblTransaction.reloadData()
            } else {
                self?.tblTransaction.reloadData()
            }
            
        })
    }
    
    func getEarnedList(){
        let  loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        viewModel?.getEarnedTransaction(customerId: loginInfoDictionary[kCustomerId]! as AnyObject, pageIndex: pageIndex as AnyObject, myEarnedTransactionHandelling: { [weak self] (isSuccess, responce, total) in
            guard self != nil else { return }
            if isSuccess {
                self?.totalCount = total
                if self?.pageIndex == 1 {
                    self?.earnedTransaction = responce
                } else {
                    for i in 0 ..< responce.count {
                        let dict = responce[i]
                        self!.earnedTransaction.append(dict)
                    }
                }
                self?.tblTransaction.reloadData()
            } else {
                self?.tblTransaction.reloadData()
            }
            
        })
    }
    
}

extension FRTransactionViewC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isEarned) ? earnedTransaction.count : myPaidTransaction.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (isEarned) ? 60 : 115
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEarned {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EarnedCell") as? EarnedCell
            cell?.setData(dict: earnedTransaction[indexPath.row])
            cell?.selectionStyle = .none
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as? TransactionCell
            cell?.setMyTransactionData(dict: myPaidTransaction[indexPath.row])
            cell?.selectionStyle = .none
            return cell!
        }
        
    }
}

extension FRTransactionViewC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let txtAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font: UIFont(name: kFontTextSemibold, size: 15.0)! , NSAttributedStringKey.foregroundColor: UIColor.black]
        let placeholderText = NSAttributedString(string: (isEarned) ? "No Earned" : "No Transaction found", attributes: txtAttributes)
        return placeholderText
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attString = NSAttributedString(string: "Refresh", attributes: [ NSAttributedStringKey.font: UIFont(name: kFontTextMedium, size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.red])
        return attString
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.pageIndex = 1
        self.totalCount = 0
        if !isEarned {
            getMyTransactionList()
        } else {
            getEarnedList()
        }
    }
}

