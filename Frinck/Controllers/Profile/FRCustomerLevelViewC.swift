
import UIKit

class FRCustomerLevelViewC: UIViewController {

    @IBOutlet var lblLevel: UILabel!
    @IBOutlet var lblCongrats: UILabel!
    @IBOutlet var tblLevel: UITableView!
    @IBOutlet var btnLevelUp: UIButton!
    
    var arrCustomerLevel = [[String : AnyObject]]()
    
    //MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    //MARK: - Private Methods
    private func setUpView() {
        callApiCustomerLevel()
        
        btnLevelUp.layer.cornerRadius = btnLevelUp.frame.size.height/2
        btnLevelUp.layer.masksToBounds = true
        tblLevel.register(UINib(nibName: "CustomerLevelCell", bundle: nil), forCellReuseIdentifier: "CustomerLevelCell")
    }
    
    func customerLevelSet(dict: [String : AnyObject]) {
        if let completeLevel = dict["completeLevel"] as? [String : AnyObject] {
            let customerValue : Int = (completeLevel["CustomerLevel"] as? Int)!
            lblLevel.isHidden = false
            lblLevel.text = "Level " + String(customerValue)
            lblCongrats.isHidden = (customerValue == 0) ? true : false
        }
        
        self.arrCustomerLevel = dict["remainLevel"] as! [[String : AnyObject]]
        tblLevel.reloadData()
    }
    
    
    //MARK: - IBAction Methods
    
    @IBAction func tapBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapLevelUp(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let faqViewC = sb.instantiateViewController(withIdentifier: "FAQViewC") as? FAQViewC
        faqViewC?.strHeader = "How Do I Level Up?"
        self.navigationController?.pushViewController(faqViewC!, animated: true)
    }
    
    //MARK: - API call
    func callApiCustomerLevel() {
        lblLevel.isHidden = true
        lblCongrats.isHidden = true
        var params: NSMutableDictionary = [:]
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        params = [ kCustomerId : loginInfoDictionary[kCustomerId]! as AnyObject]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kcustomerLevel))!        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let list = dict.value(forKey: kPayload) as? [String : Any] {
                            self.customerLevelSet(dict: list as [String : AnyObject])
                        }
                    } else {
                        let message = dict[kMessage] as? String
                        alertController(controller: self, title: "", message: message!, okButtonTitle: "Ok", completionHandler: { (value) in
                        })
                    }
                }
            }
        }
    }
}

extension FRCustomerLevelViewC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCustomerLevel.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerLevelCell") as? CustomerLevelCell
        let dict = arrCustomerLevel[indexPath.row]
        
        let customerValue : Int = (dict["CustomerLevel"] as? Int)!
        let requiredPoint = dict["RequiredPoint"] as! Int
        let isComplete = dict["isComplete"] as! Bool
        
        if isComplete {
            cell?.lblLevel.text = (customerValue == 0) ? "LEVEL 0" : "LEVEL \(customerValue) COMPLETE"
            cell?.lblPoints.text = ""
            cell?.imgLevel.image = (customerValue == 0) ? #imageLiteral(resourceName: "congratulations-2") : #imageLiteral(resourceName: "congratulations-1")
            cell?.lblLevel.textColor = UIColor.red
        } else {
            cell?.lblPoints.text = "Need \(requiredPoint) Points"
            cell?.imgLevel.image = #imageLiteral(resourceName: "congratulations-2")
            cell?.lblLevel.text = "LEVEL \(customerValue)"
            cell?.lblLevel.textColor = UIColor.black
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = arrCustomerLevel[indexPath.row]
        let customerValue : Int = (dict["CustomerLevel"] as? Int)!
        if customerValue != 0 {
            alertController(controller: self, title: "Level " + String(customerValue), message: dict["description"] as! String, okButtonTitle: "Ok") { (value) in
                
            }
        }
    }
}
