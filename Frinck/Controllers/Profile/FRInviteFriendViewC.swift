//
//  FRInviteFriendViewC.swift
//  Frinck
//
//  Created by Meenkashi on 6/19/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import SDWebImage

class FRInviteFriendViewC: UIViewController {

    @IBOutlet var imgInvite: UIImageView!
    @IBOutlet var tblInvite: UITableView!
    @IBOutlet var lblPoints: UILabel!
    @IBOutlet var lblInvite: UILabel!
    @IBOutlet var lblCode: UILabel!
    @IBOutlet var btnShare: UIButton!
    @IBOutlet var btnTerms: UIButton!
    @IBOutlet var viewInvite: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var strInviteCode : String = ""
    var arrInvite = [[String : Any]]()
    var pointSend = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if DeviceType.iPhone5orSE || DeviceType.iPhone4orLess {
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height+50)
            scrollView.isScrollEnabled = true
        }
        else {
            scrollView.isScrollEnabled = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK: - Private Methods
    private func setUpView() {
//        tblInvite.register(UINib(nibName: "CellInvite", bundle: nil), forCellReuseIdentifier: "cell")
        btnShare.layer.cornerRadius = btnShare.frame.size.height/2
        btnShare.layer.masksToBounds = true
        btnTerms.layer.cornerRadius = btnTerms.frame.size.height/2
        btnTerms.layer.masksToBounds = true
        
        viewInvite.layer.shadowColor = UIColor.gray.cgColor
        viewInvite.layer.shadowRadius = 15
        viewInvite.layer.cornerRadius = 10
        viewInvite.layer.shadowOffset = CGSize(width: 10, height: 20)
        viewInvite.layer.masksToBounds = true
        
        callApiInvite()
    }
    
    private func setData(payload: [String : Any]) {
        if let heading = payload["heading"] as? String {
            lblInvite.text = heading
        }
        if let image = payload["imageUrl"] as? String {
            imgInvite.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: ""), options: .cacheMemoryOnly, completed: nil)
        }
        if let subHeading = payload["subHeading"] as? String {
            lblPoints.text = subHeading
        }
        if let inviteCode = payload["referalCodewithMsg"] as? String {
            strInviteCode = inviteCode
            lblCode.text = inviteCode
        }
        if let point = payload["point"] as? Int {
            pointSend = "\(point)"
        }
        if let arr = payload["inviteMessage"] as? [[String : Any]] {
            arrInvite = arr
            tblInvite.reloadData()
        }
    }
    
    //MARK: - IBActionMethods
    @IBAction func tapBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapShare(_ sender: UIButton) {
        let urlString = "Sign up using code \(strInviteCode) and get \(pointSend) points."
        
        let linkToShare = [urlString]
        let share = UIActivityViewController(activityItems: linkToShare, applicationActivities: nil)
        self.present(share, animated: true, completion: nil)
    }
    
    @IBAction func tapTermsCondition(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Profile", bundle: nil)
        let termsViewC = sb.instantiateViewController(withIdentifier: "FRWebViewC") as? FRWebViewC
        termsViewC?.strHeader = "Terms and Conditions"
        self.navigationController?.pushViewController(termsViewC!, animated: true)
    }
    
    
    
    //MARK - API Call
    func callApiInvite() {
        var params: NSMutableDictionary = [:]
        let loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        params = [ kCustomerId : loginInfoDictionary[kCustomerId]! as AnyObject]
        
        let requestURL = URL(string: String(format: "%@%@",kBaseUrl,kInvite))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                DispatchQueue.main.async {
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        if let list = dict.value(forKey: kPayload) as? [String : Any] {
                            self.setData(payload: list)
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

extension FRInviteFriendViewC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrInvite.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 77
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CellInvite
        let dict = arrInvite[indexPath.row]
        if let urlString = dict["icon"] as? String {
            cell.imgInvite.sd_setImage(with: URL(string: urlString), completed: { (image, err, cacheType, url) in
                if err == nil {
                    
                } else {
                }
            })
        }
        cell.lblInvite.text = dict["message"] as? String
        return cell
    }
}
