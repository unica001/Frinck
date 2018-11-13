
import UIKit
import IQKeyboardManagerSwift
import DZNEmptyDataSet

class FRCommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate
{
    @IBOutlet weak var enterTextViewBottonConstraints: NSLayoutConstraint!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet var sendCommentButton: UIButton!
    
    var loginInfoDictionary :NSMutableDictionary!
    var commentListArray = [[String:Any]]()
    var storyDictionary = [String:Any]()
    var pageIndex : Int = 1
    var storyId : Int? = nil
    var totalCount : Int = 0
    var refreshControl = UIRefreshControl()

    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        commentTextView.delegate = self
        commentTableView.register(UINib(nibName: "FRCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "FRCommentTableViewCell")
        commentTableView.emptyDataSetSource = self
        commentTableView.emptyDataSetDelegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FRLoginViewController.myviewTapped(_:)))
        view.addGestureRecognizer(tap)
        
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        commentTableView.addSubview(refreshControl)
        getcommentList(isFromLoadMore: true)
    }
    
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
    }
   
    @objc func pullToRefresh() {
        if totalCount > commentListArray.count {
            pageIndex = pageIndex + 1
            getcommentList(isFromLoadMore: false)
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    // MARK : Table view delegates
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
      return  0.001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return commentListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FRCommentTableViewCell", for: indexPath) as! FRCommentTableViewCell
        if self.commentListArray.count > 0 {
            cell.setData(dict: self.commentListArray[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK : Textview Delegates
    @objc func myviewTapped(_ sender: UITapGestureRecognizer)
    {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        commentTextView.text = ""
        commentTextView.textColor = .black
    
        if commentListArray.count == 0 {
            return
        }
        scrollToBottom()
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        let pointInTable:CGPoint = textField.superview!.convert(textField.frame.origin, to:commentTableView)
        var contentOffset:CGPoint = commentTableView.contentOffset
        contentOffset.y  = pointInTable.y
        if let accessoryView = textField.inputAccessoryView
        {
            contentOffset.y -= accessoryView.frame.size.height
        }
        commentTableView.contentOffset = contentOffset
        return true;
    }
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            if self.commentListArray.count > 0 {
                let indexPath = IndexPath(row: self.commentListArray.count-1, section: 0)
                self.commentTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }

    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        if (self.navigationController?.viewControllers.count)! > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            AppDelegate.delegate.goToHomeScreen()
        }
    }
    @IBAction func sendCommentButtonAction(_ sender: Any) {
        
        postComment()
    }
    
    //MARK: - API Call
    
    func getcommentList(isFromLoadMore : Bool)
    {
        let storyId : Int = (self.storyId == nil) ? storyDictionary[kStoryId] as! Int : self.storyId!
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            StoryId : String(storyId),
            kpageNo : pageIndex,
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kcommentlist))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: isFromLoadMore,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    self.containerDependOnKeyboardBottomConstrain = self.enterTextViewBottonConstraints
                    self.watchForKeyboard()
                    self.commentTableView.tableFooterView?.isHidden = true

                    if index == "200" {
                        
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            let arr = payload["commentList"] as! [[String : Any]]
                            if self.pageIndex == 1 {
                                self.commentListArray = arr.reversed()
                            } else {
                                let prevArr = self.commentListArray
                                self.commentListArray = arr.reversed()
                                self.commentListArray.append(contentsOf: prevArr)
                            }
                            self.totalCount = payload["total"] as! Int
                        }
                        if self.commentListArray.count == 0 {
                        } else {
                            self.scrollToBottom()
                        }
                        self.commentTableView.reloadData()
                    }
                    else
                    {
                        let message = dict[kMessage]
                        
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                        })
                        
                    }
                }
            }
        }
    }
    
    func postComment()
    {
        
        let storeId : Int = (storyId == nil) ? storyDictionary[kStoryId] as! Int : storyId!

        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            StoryId : String(storeId),
            kComment : commentTextView.text
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kcommentpost))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        self.commentTextView.text = ""
                        if let res = dict["payloads"] as? [String : Any] {
                            if self.commentListArray.count == 0 {
                                self.commentListArray.insert(res, at: 0)
                            } else {
                                self.commentListArray.append(res)
                            }
                            self.commentTableView.isHidden = false
                            self.commentTableView.reloadData()
                            self.scrollToBottom()
                        }
                    }
                    else
                    {
                        let message = dict[kMessage]
                        
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                        })
                        
                    }
                }
            }
        }
    }
    
}

extension FRCommentViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let txtAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font: UIFont(name: kFontTextSemibold, size: 15.0)! , NSAttributedStringKey.foregroundColor: UIColor.black]
        let placeholderText = NSAttributedString(string: "There are no comment in this story.", attributes: txtAttributes)
        return placeholderText
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attString = NSAttributedString(string: "Refresh", attributes: [ NSAttributedStringKey.font: UIFont(name: kFontTextMedium, size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.red])
        return attString
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.pageIndex = 1
        getcommentList(isFromLoadMore: true)
    }
}



private var xoAssociationKeyForBottomConstrainInVC: UInt8 = 0

extension UIViewController {
    
    var containerDependOnKeyboardBottomConstrain :NSLayoutConstraint! {
        get {
            return objc_getAssociatedObject(self, &xoAssociationKeyForBottomConstrainInVC) as? NSLayoutConstraint
        }
        set(newValue) {
            objc_setAssociatedObject(self, &xoAssociationKeyForBottomConstrainInVC, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func watchForKeyboard () {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.containerDependOnKeyboardBottomConstrain.constant = keyboardFrame.height-50
            self.view.layoutIfNeeded()
        })
    }   
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.containerDependOnKeyboardBottomConstrain.constant = 0
            self.view.layoutIfNeeded()
        })
    }
}
