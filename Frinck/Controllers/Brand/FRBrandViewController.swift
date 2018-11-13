
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import DZNEmptyDataSet

class FRBrandViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate
{
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var searchController: UISearchBar!
    var searchText : NSString = ""
    var cityID : Int = 0
    var fromView : String = ""
    
    var brandArray = [[String:Any]]()
    var brandList = [[String:Any]]()
    var loginInfoDictionary :NSMutableDictionary!
    var selectedBrandArray : NSMutableArray = []
    
    var pageIndex : Int = 0
    var isFromSkip : Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        searchController.delegate = self
        collectionView.reloadData()
        
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        collectionView.emptyDataSetDelegate = self
        collectionView.emptyDataSetSource = self
        self.getBrandList()
        
        
        if self.fromView == "FRFavouriteBrandsViewController" {
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            button.setImage(UIImage(named : "back"), for: .normal)
            button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
            let  barItem  = UIBarButtonItem(customView: button)
            self.navigationItem.leftBarButtonItem = barItem
            
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool)
    {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func skipButtonAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.isFromSkip = true
            self.selectFavouriteBrand()
        }
    }
    
    @IBAction func doneButtonAction(_ sender: Any)
    {
        if(brandList.count>0)
        {
            DispatchQueue.main.async {
                self.isFromSkip = false
                self.selectFavouriteBrand()
            }
        }
        
    }
    
    // MARK:- Collection view Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        return brandArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BrandCollectionCell
        
        let dict = brandArray[indexPath.row]
        cell.setInitialData(dictionary:dict)
//        cell.favouriteButton.isUserInteractionEnabled = false
        
        let isFav : Int = dict["isFavourite"] as? Int ?? 0
        if isFav == 1 {
            cell.favouriteButton.setImage(UIImage(named :"heart_h"), for: .normal)
        }
        else {
            cell.favouriteButton.setImage(UIImage(named :"heart"), for: .normal)
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
        var dict  =  brandArray[indexPath.row]
        let isFav : Int = dict["isFavourite"] as? Int ?? 0
        if isFav == 1{
            dict["isFavourite"] = 0
        }
        else {
        dict["isFavourite"] = 1
        }
        brandArray[indexPath.row] = dict
        collectionView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK : APIs call
    
    
    @objc func getBrandList()
    {
        var params: NSMutableDictionary = [:]
        params = [
            kpageNo : "\(pageIndex)",
            kSearchKey: self.searchController.text as Any,
            kCustomerId: loginInfoDictionary[kCustomerId]!
            
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kBrand))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        
                        if let  payload = dict.value(forKey: kPayload) as? [String : Any] {
                            
                            self.brandArray = payload["brandList"] as! [[String : Any]]
                            self.brandList = self.brandArray
                            self.collectionView.reloadData()
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
    
    func selectFavouriteBrand()
    {
        var params: NSMutableDictionary = [:]
        
        var filterArray = [[String:Any]]()

        if isFromSkip == false {
            for dict in brandList {
                if let index = brandArray.index(where: { $0["isFavourite"]as? Int != dict["isFavourite"] as? Int && $0["BrandId"]as? Int == dict["BrandId"] as? Int }) {
                    filterArray.append(brandArray[index])
                }
            }
            guard let data = try? JSONSerialization.data(withJSONObject: filterArray, options: []) else {
                return
            }
            let favBrandList =  String(data: data, encoding: String.Encoding.utf8)
            
            
            params = [
                kCustomerId: loginInfoDictionary[kCustomerId]!,
                kBrandList : favBrandList!
            ]
        }
        else {
            params = [
                kCustomerId: loginInfoDictionary[kCustomerId]!,
                kBrandList : ""
            ]
        }
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kBrandFavourite))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200"
                    {
                        
                        if self.fromView == "FRFavouriteBrandsViewController" {
                            self.navigationController?.popViewController(animated: true)
                        }
                        else {
                           
                            self.performSegue(withIdentifier: khomeViewSegueIdentifier, sender: nil)
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(collectionView.contentOffset.x / collectionView.frame.size.width)
        pageIndex = Int(pageNumber)
        getBrandList()
    }
    
}

extension FRBrandViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let str = (searchBar.text as NSString?)?.replacingCharacters(in: range, with: text)
        let newLength = (searchBar.text?.count)! + text.count - range.length
        if let text = str {
            if newLength >= 2 || newLength == 0 {
                self.getBrandList()
            }
        }
        return true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            self.getBrandList()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}

extension FRBrandViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let txtAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font: UIFont(name: kFontTextSemibold, size: 15.0)! , NSAttributedStringKey.foregroundColor: UIColor.black]
        let placeholderText = NSAttributedString(string: "There are no brands.", attributes: txtAttributes)
        return placeholderText
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attString = NSAttributedString(string: "Refresh", attributes: [ NSAttributedStringKey.font: UIFont(name: kFontTextMedium, size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.red])
        return attString
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        //        self.pageIndex = 1
        getBrandList()
    }
}


