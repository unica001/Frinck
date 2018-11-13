//
//  FAQViewC.swift
//  Frinck
//
//  Created by Meenkashi on 7/3/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import FAQView

class FAQViewC: UIViewController, UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    var strHeader = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = strHeader
        var url : URL!
        if strHeader == "FAQs" {
            url = URL(string: ContentUrl.FAQ.rawValue)
        } else if strHeader == "How Do I Level Up?" {
            url = URL(string: ContentUrl.HowDoILevelUp.rawValue)
        } else if strHeader == "How it Works?" {
            url = URL(string: ContentUrl.HowItWorks.rawValue)
        } else if strHeader == "Refund" {
            url = URL(string: ContentUrl.Refund.rawValue)
        }
        
        let request = URLRequest(url: url!)
        webView.delegate = self
        webView.loadRequest(request)
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

    @IBAction func tapBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
