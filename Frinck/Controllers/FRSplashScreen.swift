
import UIKit
import SwiftGifOrigin

class FRSplashScreen: UIViewController {

    @IBOutlet var imgView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        imgView.loadGif(name: "splash01")
        self.perform(#selector(animationFinish), with: nil, afterDelay: 3)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func animationFinish() {
        
        // set auto login data
        
        if kUserDefault.value(forKey: kloginInfo) != nil {
            let loginInfoDictionary  = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
            
       
            let cityId = loginInfoDictionary.value(forKey: kCityId) as? Int ?? 0
            let isMobile = loginInfoDictionary.value(forKey: "CustomerIsMobileVerified") as? Bool
            
            if (loginInfoDictionary.value(forKey: kCustomerUserName) != nil && !(isMobile!)) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let otpVerify = storyboard.instantiateViewController(withIdentifier: "FROTPViewController") as? FROTPViewController
                otpVerify?.isSplash = true
                self.navigationController?.pushViewController(otpVerify!, animated: true)
            } else {
                if (loginInfoDictionary.value(forKey: kCustomerUserName) != nil && cityId != 0)
                {
                    let storyboard = UIStoryboard(name: "Home", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "tabbarController")
                    if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
                        window.rootViewController = initialViewController
                    }
                }
                else if (cityId == 0){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "citySelectionStoryboardID")
                    self.present(initialViewController, animated: true, completion: nil)
                }
            }
        }
        
        else{
        
        let viewC = self.storyboard?.instantiateViewController(withIdentifier: "FRWelcomeViewController")
        self.navigationController?.pushViewController(viewC!, animated: true)
        }
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
