//
//  FRPostListViewC.swift
//  Frinck
//
//  Created by meenakshi on 5/29/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SJSegmentedScrollView
import SDWebImage
import DZNEmptyDataSet
import ObjectMapper

class FRPostListViewC: UIViewController {
    
    @IBOutlet weak var tblPostList: UITableView!
    var rowHeight = [Int : CGFloat]()
    internal var viewModel : PostViewModelling?
    var loginInfoDictionary : NSMutableDictionary!
    var pageIndex : Int = 1
    var totalCount : Int = 0
    internal var userId: Int? = nil
    var isBlock: Int = 0
    var arrPostList = [PostListModel]()
    var commentString : String = ""
    
    @IBOutlet var collectionStory: UICollectionView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        setUpView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
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
            self.viewModel = PostListVM()
        }
    }
    
    private func setUpView() {
        self.recheckVM()
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
//        self.tblPostList.register(UINib(nibName: "StoryViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.collectionStory.emptyDataSetSource = self
        self.collectionStory.emptyDataSetDelegate = self
        getUserPostList()
    }
    
    
    //MARK: - API Call
    
    func getUserPostList() {
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        let customerId = loginInfoDictionary[kCustomerId]! as AnyObject
        var params: NSMutableDictionary = [:]
        if userId == nil {
            params = [ kCustomerId :customerId,
                       kpageNo : pageIndex]
        } else {
            params = [ kCustomerId :customerId,
                       kpageNo : pageIndex,
                       "ProfileId" : userId!]
        }
        
        self.viewModel?.getUserPostList(param: params, postListHandler: { [weak self](response, total, isSuccess, msg) in
            guard self != nil else { return }
            if isSuccess {
                self?.totalCount = total                
                if self?.pageIndex == 1 {
                    self?.arrPostList = response
                } else {
                    for i in 0 ..< response.count {
                        let dict = response[i]
                        self?.arrPostList.append(dict)
                    }
                }
                self?.collectionStory.reloadData()
            } else {
//                alertController(controller: self!, title: "", message: msg, okButtonTitle: "OK", completionHandler: { (value) in
//                    
//                })
            }
        })
        
    }
    
  /*  func postComment(textField: UITextField)
    {
        let dict = arrPostList[textField.tag]
        let storeId : Int = dict.storyId!
        
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            StoryId : String(storeId),
            kComment : self.commentString
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kcommentpost))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        self.commentString = ""
                    } else {
                        let message = dict[kMessage]
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                        })
                        
                    }
                }
            }
        }
    }
    func callApiDeleteStory(storyId: AnyObject, index: Int) {
        
        let customerId = loginInfoDictionary[kCustomerId]! as AnyObject
        
        self.viewModel?.deleteStory(storyId: storyId, customerId: customerId, deleteStoryHandler: { [weak self](response, isSuccess, msg) in
            guard self != nil else { return }
            if isSuccess {
                self!.arrPostList.remove(at: index)
                self!.tblPostList.reloadData()
            } else {
                alertController(controller: self!, title: "", message: msg, okButtonTitle: "OK", completionHandler: { (value) in
                    
                })
            }
        })
    }*/

}

//extension FRPostListViewC: UITableViewDelegate, UITableViewDataSource, delegateReloadCell {
//    func reloadCellData(dict: [String : Any], rowHeight: CGFloat, index: Int) {
//
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return arrPostList.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 10.0
//    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        let dict = arrPostList[section]
//
//        if  dict.isShowComment == "1"  &&  dict.isShowComment != nil{
//            return 60
//        }
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//
//        let dict = arrPostList[section]
//
//        if  dict.isShowComment == "1"  &&  dict.isShowComment != nil{
//
//            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSize.width - 30, height: 60))
//            headerView.backgroundColor = UIColor.clear
//
//            let commnetTextField = UITextField(frame: CGRect(x: 10, y: 5, width: ScreenSize.width-50, height: 30))
//            commnetTextField.backgroundColor = UIColor.clear
//            commnetTextField.font = UIFont(name: kFontTextRegular, size: 15.0)
//            commnetTextField.placeholder = "Write a comment"
//            commnetTextField.returnKeyType = .done
//            commnetTextField.delegate = self
//            commnetTextField.tag = section
//            commnetTextField.borderStyle = .roundedRect
//            headerView.addSubview(commnetTextField)
//
//            let commnetButton = UIButton(frame: CGRect(x: ScreenSize.width-180, y: 40, width: 150, height: 15))
//            commnetButton.setTitleColor(.red, for: .normal)
//            commnetButton.setTitle("View Comments", for: .normal)
//            commnetButton.titleLabel?.font = UIFont(name: kFontTextMedium, size: 15.0)
//            commnetButton.tag = section
//            commnetButton.addTarget(self, action: #selector(viewAllcommentAction(_:)), for: .touchUpInside)
//            headerView.addSubview(commnetButton)
//
//            return headerView
//        }
//        return nil
//
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let identifier = "cell"
//
//        var cell: StoryViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? StoryViewCell
//
//        tableView.register(UINib(nibName: "StoryViewCell", bundle: nil), forCellReuseIdentifier: identifier)
//        cell = (tableView.dequeueReusableCell(withIdentifier: identifier) as? StoryViewCell)!
//        cell.selectionStyle = UITableViewCellSelectionStyle.none
//
//        // Button Action
//        cell.commentButton.tag = indexPath.section
//        cell.shareButton.tag = indexPath.section
//        cell.commentButton.addTarget(self, action:  #selector(commentButtonAction(_:)), for: .touchUpInside)
//        cell.shareButton.addTarget(self, action:  #selector(shareButtonAction(_:)), for: .touchUpInside)
//
//        cell.dotButton.isHidden = (userId == nil) ? false : true
//        cell.dotButton.tag = indexPath.section
//        cell.dotButton.addTarget(self, action: #selector(dotButtonAction(_:)), for: .touchUpInside)
//        cell.reloadDelegate = self
//        cell.setPostInfoWithModel(arrPost: &arrPostList, index: indexPath.section, tableView: tableView)
//        cell.readMoreButton.addTarget(self, action: #selector(readMoreButtonAction(_:)), for: .touchUpInside)
//        return cell
//    }
//
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        var height : Float = 0.0
//        let dict = arrPostList[indexPath.section]
//
//        // description
//
//        let description : String = dict.desc!
//        height = Float(description.height(withConstrainedWidth: ScreenSize.width - 40, font: UIFont(name: kFontTextRegular, size: 14)!))
//
//        if height > Float(descriptioHeight) && (dict.isReadMore == nil ||  dict.isReadMore == "1") {
//            height = Float(descriptioHeight) + 20 // read more button
//        }
//
//        let locality : String =  dict.storeAddress!
//        height = Float(locality.height(withConstrainedWidth: ScreenSize.width - 170, font: UIFont(name: kFontTextRegular, size: 13)!)) + height
//
//        if  dict.meditaType == kVideo {
//            height = height + Float(imageHeight)
//        } else {
//            if let ht = self.rowHeight[indexPath.section] {
//                height = Float(ht) + height
//            } else {
//                let cache : SDImageCache = SDImageCache.shared()
//
//                let image : UIImage? = cache.imageFromDiskCache(forKey: dict.mediaUrl)
//
//                if let image = image {
//                    let aspectRatio = (image as UIImage).size.height/(image as UIImage).size.width
//                    let imgHeight = self.view.frame.width*aspectRatio
//                    self.rowHeight[indexPath.section] = imgHeight
//                    height = height + Float(imgHeight)
//                } else {
//                    height = height + Float(imageHeight)
//                }
//            }
//        }
//
//        return CGFloat(storyCellHeight) + CGFloat(height);
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        let currentOffset = scrollView.contentOffset.y
//        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
//        if totalCount > arrPostList.count {
//            if maximumOffset - currentOffset <= -40 && arrPostList.count != 0 && arrPostList.count%10 == 0 {
//                pageIndex = pageIndex + 1
//                getUserPostList()
//            }
//        }
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let arrVisibleCell = collection.indexPathsForVisibleRows
//        CommonAction.sharedAction.storyVisible(arrVisible: arrVisibleCell!, storyArray: arrPostList, customerId: loginInfoDictionary[kCustomerId]! as! Int)
//    }
//
//    // MARK Button Action
//
//    @objc  func readMoreButtonAction(_ button : UIButton){
//        let dict = arrPostList[button.tag]
//        dict.isReadMore = "0"
//        arrPostList[button.tag] = dict
//        tblPostList.reloadRows(at: [IndexPath(row: 0, section: button.tag)], with: .none)
//    }
//
//    func reloadCellData(dict: [String : Any], index: Int) {
//        self.tblPostList.reloadRows(at: [IndexPath(row: 0, section: index)], with: UITableViewRowAnimation.none)
//    }
//
//    @objc func commentButtonAction(_ button: UIButton) {
//        let dict = arrPostList[button.tag]
//        if  dict.isShowComment == "0" || dict.isShowComment == nil{
//            dict.isShowComment = "1"
//        } else {
//            dict.isShowComment = "0"
//        }
//        arrPostList[button.tag] = dict
//        self.tblPostList.reloadRows(at: [IndexPath(row: 0, section: button.tag)], with: .none)
//    }
//
//    @objc func shareButtonAction(_ button: UIButton) {
//        if isBlock == 1 {
//            return
//        }
//        CommonAction.sharedAction.shareStory(viewC: self, dict: arrPostList[button.tag])
//    }
//
//    @objc func dotButtonAction(_ button: UIButton) {
//        if isBlock == 1{
//            return
//        }
//        let dict = arrPostList[button.tag]
//        CommonAction.sharedAction.storyDotAction(dict: dict, logInId: loginInfoDictionary[kCustomerId] as! Int, viewC: self) { (succes, message, actionType) in
//            if succes {
//                switch actionType {
//                case .Delete:
//                    alertController(controller: self, title: "", message: "Your story deleted successfully.", okButtonTitle: "Ok", completionHandler: { (valid) in
//                        self.arrPostList.remove(at: button.tag)
//                        self.tblPostList.reloadData()
//                    })
//                case .Hide:
//                    self.arrPostList.remove(at: button.tag)
//                    self.tblPostList.reloadData()
//                case .Edit:
//                    break
//                case .Flag:
//                    break
//                }
//            } else {
//                alertController(controller: self, title: "", message:message, okButtonTitle: "OK", completionHandler: {(index) -> Void in
//
//                })
//            }
//        }
//    }
//
//    @objc func viewAllcommentAction(_ button : UIButton){
//        // view all comment
//        CommonAction.sharedAction.moveToComment(viewC: self, storyId: arrPostList[button.tag].storyId!)
//    }
//
//}

extension FRPostListViewC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPostList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellProfilePost", for: indexPath)
        let dict = arrPostList[indexPath.row]
        let imgPost = cell.viewWithTag(10) as! UIImageView
        let videoView = cell.viewWithTag(11) as! AGVideoPlayerView
        
        if dict.meditaType == kVideo {
            imgPost.isHidden = true
            videoView.isHidden = false
            let urlString = dict.mediaUrl ?? ""
            let urlStrings = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            DispatchQueue.global(qos: .background).async {
                videoView.videoUrl = URL(string: urlStrings!)
                videoView.previewImageUrl =  URL(string: urlStrings!)
                videoView.shouldAutoplay = false
                videoView.shouldAutoRepeat = true
                videoView.showsCustomControls = true
                videoView.shouldSwitchToFullscreen = true
            }
        } else {
            imgPost.isHidden = false
            videoView.isHidden = true
            let urlString = dict.mediaUrl ?? ""
            
            if let urlString = urlString as? String {
                imgPost.sd_setImage(with: URL(string: urlString), completed: { (image, err, cacheType, url) in
                        if err == nil {
                            
                        } else {
                            imgPost.image = UIImage(named : "placeHolder")
                        }
                    })
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionStory.frame.size.width - 5)/2, height: 200) // The size of one cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(2, 2, 0,2) // margin between cells
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = arrPostList[indexPath.row]
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        if let storyViewC = storyBoard.instantiateViewController(withIdentifier: "FrStoryDetailViewC") as? FrStoryDetailViewC {
            storyViewC.storyId = Int(dict.storyId!)
            self.navigationController?.pushViewController(storyViewC, animated: true)
        }
    }
}

//extension FRPostListViewC:UITextFieldDelegate{
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        self.commentString = self.commentString + string
//        return true
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField.text != "" {
//            self.postComment(textField: textField)
//        }
//        textField.text = ""
//        textField.resignFirstResponder()
//        return true
//    }
//}

extension FRPostListViewC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let txtAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font: UIFont(name: kFontTextSemibold, size: 15.0)! , NSAttributedStringKey.foregroundColor: UIColor.black]
        let placeholderText = NSAttributedString(string: "No Posts yet", attributes: txtAttributes)
        return placeholderText
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attString = NSAttributedString(string: "Refresh", attributes: [ NSAttributedStringKey.font: UIFont(name: kFontTextMedium, size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.red])
        return attString
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.pageIndex = 1
        self.getUserPostList()
    }
}

extension FRPostListViewC: SJSegmentedViewControllerViewSource {
    
    func viewForSegmentControllerToObserveContentOffsetChange() -> UIView {
        return collectionStory
    }
}
