//
//  OfferBannerViewC.swift
//  Frinck
//
//  Created by Meenkashi on 9/11/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class OfferBannerViewC: UIViewController {

    @IBOutlet var imgBanner: UIImageView!
    var imgBannerOffer = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let imgUrl = UserDefaults.standard.object(forKey: "bannerImgUrl")
        {
            let urlString = imgUrl as? String
            let urlStrings = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let url = URL(string: urlStrings!)
            self.imgBanner.sd_setImage(with:url , placeholderImage: UIImage(named : ""), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
        }
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserDefaults.standard.set(imgBannerOffer, forKey: "bannerImgUrl")
        let urlStrings = imgBannerOffer.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlStrings!)
        self.imgBanner.sd_setImage(with:url , placeholderImage: UIImage(named : ""), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
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

}
