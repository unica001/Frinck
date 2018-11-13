

import UIKit
import DZNEmptyDataSet

class FRFavouriteBrandsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    @IBOutlet weak var favouriteCollectionView: UICollectionView!
    @IBOutlet weak var searchBarFavouritBrands: UISearchBar!
    
    var brandArray = [[String:Any]]()
    var brandList : NSMutableArray = []
    var searchText : NSString = ""
    var loginInfoDictionary :NSMutableDictionary!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchBarFavouritBrands.delegate = self
        favouriteCollectionView.reloadData()
        favouriteCollectionView.emptyDataSetDelegate = self
        favouriteCollectionView.emptyDataSetSource = self
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        getFavBrandList()

    }
  
    // Mark : Collection Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return brandArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favouriteBrandCell", for: indexPath) as! FRFavouriteBrandsCollectionViewCell
        let dict = brandArray[indexPath.row]
        cell.setFavouritBrandData(dictionary:dict)
        cell.favouriteButton.setImage(UIImage(named :"heart_h"), for: .normal)
        cell.favouriteButton.tag = indexPath.row
        cell.favouriteButton.addTarget(self, action:#selector(tapUnfavourite(_:)), for: .touchUpInside)
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
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let brandDetailView : FRBrandDetailViewController = storyboard.instantiateViewController(withIdentifier: kFRBrandDetailViewController) as! FRBrandDetailViewController
        brandDetailView.brandDictionary = brandArray[indexPath.row]
        self.navigationController?.pushViewController(brandDetailView, animated: true)
    }
    
    @objc func tapUnfavourite(_ sender: UIButton) {
        let index = sender.tag
        var dict  =  brandArray[index]
        dict["isFavourite"] = 0
        var filterArray = [[String:Any]]()
        filterArray.append(dict)
        callApiUnfav(arrUnFav: filterArray, indexPath: index)
    }
    
    func callApiUnfav(arrUnFav: [[String : Any]], indexPath: Int) {
        var params: NSMutableDictionary = [:]

        guard let data = try? JSONSerialization.data(withJSONObject: arrUnFav, options: []) else {
            return
        }
        let favBrandList =  String(data: data, encoding: String.Encoding.utf8)
        
        params = [ kCustomerId: loginInfoDictionary[kCustomerId]!,
                kBrandList : favBrandList!]
    
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kBrandFavourite))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200"
                    {
                        self.brandArray.remove(at: indexPath)
                        self.favouriteCollectionView.reloadData()
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
    
//    // MARK: - Search bar delegate
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//
//            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.getFavBrandList), object: nil)
//            self.perform(#selector(self.getFavBrandList), with: nil, afterDelay: 0.5)
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        self.searchBarFavouritBrands.resignFirstResponder()
//
//    }
//
    
    
    // MARK : Button action
    @IBAction func PlusButtonAction(_ sender: Any)
    {
        var cityId : Int = 0
        
        if let cityid = loginInfoDictionary[kCityId] as? Int {
            cityId = cityid
        } else {
            cityId = Int((loginInfoDictionary[kCityId] as! NSString).floatValue)
        }

        let storyboard = UIStoryboard(name: "Home", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "selectControllerID") as? FRBrandViewController
        viewController?.cityID = cityId
        viewController?.selectedBrandArray =  brandList
        viewController?.fromView = "FRFavouriteBrandsViewController"
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    //MARK: - API Call
    
    @objc func getFavBrandList()
    {
        brandArray = [[String:Any]]()
        brandList = []
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            kpageNo : "0",
            kSearchKey: self.searchBarFavouritBrands.text as Any
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kMyFavouriteBrand))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        
                        if let payload = dict.value(forKey: kPayload) as? [String : Any] {
                            self.brandList = payload["brandList"] as! NSMutableArray
                            self.brandArray = (payload["brandList"] as? [[String : Any]])!
                            self.favouriteCollectionView.reloadData()

                            }
                    }
                    else
                    {
                        self.favouriteCollectionView.reloadData()
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

extension FRFavouriteBrandsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let str = (searchBar.text as NSString?)?.replacingCharacters(in: range, with: text)
        let newLength = (searchBar.text?.count)! + text.count - range.length
        if let text = str {
            if newLength >= 3 || newLength == 0 {
                self.getFavBrandList()
            }
        }
        return true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            self.getFavBrandList()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}

extension FRFavouriteBrandsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let txtAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font: UIFont(name: kFontTextSemibold, size: 15.0)! , NSAttributedStringKey.foregroundColor: UIColor.black]
        let placeholderText = NSAttributedString(string: "There are no favourite brands.", attributes: txtAttributes)
        return placeholderText
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attString = NSAttributedString(string: "Refresh", attributes: [ NSAttributedStringKey.font: UIFont(name: kFontTextMedium, size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.red])
        return attString
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
//        self.pageIndex = 1
        getFavBrandList()
    }
}
