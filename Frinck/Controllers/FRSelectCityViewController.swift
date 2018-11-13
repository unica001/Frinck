
import UIKit
import ActionSheetPicker_3_0

class FRSelectCityViewController: UIViewController
{
    @IBOutlet weak var selectCityButton: UIButton!
    
    var cityArray : NSMutableArray = NSMutableArray()
    var selectCityId : Int = 0
    var fromViewcontroller : String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.getCityList()
        selectCityButton.setTitle("Select City", for: .normal)
        
        if fromViewcontroller == "Home" {
            self.navigationController?.isNavigationBarHidden = false;
            let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
            print(loginInfoDictionary)
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            button.setImage(UIImage(named : "back"), for: .normal)
            button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
            let  barItem  = UIBarButtonItem(customView: button)
            self.navigationItem.leftBarButtonItem = barItem
            self.navigationItem.title = "Update City"
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationController?.isNavigationBarHidden = true;
        }
    }
    
    @objc func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false;
    }
    
    @IBAction func continueButtonAction(_ sender: Any)
    {
        updateCity()
    }
    @IBAction func selectCityButtonAction(_ sender: Any)
    {
        let cityNames = self.cityArray.value(forKey: "name")
        ActionSheetStringPicker.show(withTitle: "Select City", rows: cityNames as! [Any], initialSelection: 0, doneBlock: {
            picker, value, index in
            
            print(self.cityArray[value])
            
            let dict : NSMutableDictionary = (self.cityArray[value] as? NSMutableDictionary)!
            self.selectCityButton.setTitle(dict.value(forKey: "name") as? String, for: .normal)
            let selectCityIdInt = (dict.value(forKey: "id") as! Int)
            self.selectCityId = selectCityIdInt
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: self.view)
    }
    
    
    func updateCity(){
        
        let  loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        // param dictionary
        let params: NSMutableDictionary = [ kCustomerId :loginInfoDictionary[kCustomerId]!,
                                            kCityId : selectCityId ]
        
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kcityupdate))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: false, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        let  loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
                        
                        loginInfoDictionary.setValue(self.selectCityId, forKey: kCityId)
                        kUserDefault.set(NSKeyedArchiver.archivedData(withRootObject: loginInfoDictionary as Any ), forKey: kloginInfo)
                        if self.fromViewcontroller == "Home" {
                            self.navigationController?.popViewController(animated: true)
                        } else{
                            
                            let storyboard = UIStoryboard(name: "Home", bundle: Bundle.main)
                            let viewController = storyboard.instantiateViewController(withIdentifier: "selectControllerID") as? FRBrandViewController
                            viewController?.cityID = self.selectCityId
                            let nav = UINavigationController(rootViewController: viewController!)
                            self.present(nav, animated: true, completion: nil)
                        }
                    }
                    else
                    {
                        let message = dict![kMessage]
                        
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                        })
                        
                    }
                }
            }
                
            else {
                
                // show alert
            }
            
        }
        
    }
    
    // MARK: - Select city
    
    func getCityList(){
        
        // param dictionary
        var params : NSMutableDictionary = [:]
        params = [:]
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kGetcity))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: false,isAuthentication: false, showSystemError: false, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let list = response?[kPayload] as? [String : Any] {
                            print(list)
                            let cityList = list["cityList"] as? NSMutableArray
                            self.cityArray = cityList!
                            
                            if self.fromViewcontroller == "Home" {
                                
                                self.navigationController?.isNavigationBarHidden = false;
                                let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
                                print(loginInfoDictionary)
                                let cityId : Int = loginInfoDictionary.value(forKey: kCityId) as! Int
                                let cityIdInt = cityId
                                let predicate : NSPredicate = NSPredicate(format: "id = \(cityIdInt)")
                                let filterArray : NSArray = self.cityArray.filtered(using: predicate) as NSArray
                              
                                if filterArray.count > 0 {
                                    let dict : NSMutableDictionary = (filterArray[0] as? NSMutableDictionary)!
                                    self.selectCityButton.setTitle(dict.value(forKey: "name") as? String, for: .normal)
                                    
                                }
                                
                                
                                
                            }
                        }
                    }
                    else
                    {
                        let message = dict![kMessage]
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                        })
                    }
                }
            }
                
            else {
                
                // show alert
            }
            
        }
        
    }
    
}
