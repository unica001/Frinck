//
//  FRWebViewC.swift
//  Frinck
//
//  Created by Meenkashi on 6/18/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import WebKit

enum ContentUrl: String {
    case TermsCondition = "http://api.frinck.com/v1/pages/getpage/terms_and_conditions"
    case AboutUs = "http://api.frinck.com/v1/pages/getpage/about_us"
    case PrivacyPolicy = "http://api.frinck.com/v1/pages/getpage/privacy_policy"
    case Refund = "http://api.frinck.com/v1/pages/getpage/refund_policy"
    case HowDoILevelUp = "http://api.frinck.com/v1/pages/getpage/how_do_i"
    case HowItWorks = "http://api.frinck.com/v1/pages/getpage/how_it_works"
    case FAQ = "http://api.frinck.com/v1/pages/getpage/faq"
}

class FRWebViewC: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet var webView: UIWebView!
    @IBOutlet var lblHeader: UILabel!
    var strHeader = ""
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHeader.text = strHeader
        
        var url : URL!
        if strHeader == "Terms and Conditions" {
             url = URL(string: ContentUrl.TermsCondition.rawValue)
            headerImage.image = #imageLiteral(resourceName: "Terms-and-Conditions")
        }
        else  if strHeader == "Privacy Policy" {
            url = URL(string: ContentUrl.PrivacyPolicy.rawValue)
            headerImage.image = #imageLiteral(resourceName: "Privacy-Policy")

        } else {
            url = URL(string: ContentUrl.AboutUs.rawValue)
            headerImage.image = #imageLiteral(resourceName: "about-us")
        }
        
        let request = URLRequest(url: url!)
        webView.delegate = self
        webView.loadRequest(request)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapBack(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
