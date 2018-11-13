
import UIKit
import Quickblox
import Firebase

class FRHomeViewController: UIViewController {
    
    var loginInfoDictionary : NSMutableDictionary!
    @IBOutlet weak var offerLabel: UILabel!
    @IBOutlet weak var userStoryLabel: UILabel!
    @IBOutlet weak var brandStoryLabel: UILabel!
//    @IBOutlet var bannerImageView: UIImageView!
    let subViewY_axis : CGFloat = 164
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = kLightGrayColor
        navigationController?.navigationBar.barTintColor = UIColor.white
        highlightLSelection(index: 0)
        setSegmentViewController(index: 0)
        
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        let navigationBottomImage = UIImage()
        self.navigationController?.navigationBar.shadowImage = navigationBottomImage
       self.navigationController?.navigationBar.setBackgroundImage(navigationBottomImage, for: .default)
        
        AppDelegate.delegate.dailyCheckInApi()

    }

    @IBAction func locationButionAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let cityViewController : FRSelectCityViewController =  storyboard.instantiateViewController(withIdentifier: "citySelectionStoryboardID") as! FRSelectCityViewController
        cityViewController.fromViewcontroller = "Home"
        self.navigationController?.pushViewController(cityViewController, animated: true)
    }
    
    @IBAction func tapOffer(_ sender: UIButton) {
        highlightLSelection(index: 0)
        setSegmentViewController(index: 0)
    }
    
    @IBAction func tapUserStory(_ sender: UIButton) {
        highlightLSelection(index: 1)
        setSegmentViewController(index: 1)
    }
    @IBAction func tapBrandStory(_ sender: UIButton) {
        highlightLSelection(index: 2)
        setSegmentViewController(index: 2)
    }
    
    func highlightLSelection(index : NSInteger){
        if index == 0 {
            offerLabel.textColor = kRedColor
            userStoryLabel.textColor  = UIColor.lightGray
            brandStoryLabel.textColor  =  UIColor.lightGray
        }
        else  if index == 1 {
            offerLabel.textColor = UIColor.lightGray
            userStoryLabel.textColor  = kRedColor
            brandStoryLabel.textColor  =  UIColor.lightGray
        }
        else  if index == 2 {
            offerLabel.textColor = UIColor.lightGray
            userStoryLabel.textColor  = UIColor.lightGray
            brandStoryLabel.textColor  = kRedColor
        }
        
        
    }
    
    func setSegmentViewController(index : Int){
        if index == 0 {
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: kofferSegmentStoryBoard) as? FROfferSegmentViewController
            addChildViewController(controller!)
            controller?.view.frame = CGRect(x: 0, y: subViewY_axis, width: ScreenSize.width, height: ScreenSize.height - subViewY_axis)
            view.addSubview((controller?.view)!)
            controller?.didMove(toParentViewController: self)
        }
        else if index == 1 {
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: kstoryStoryboardID)
            addChildViewController(controller)
            controller.view.frame = CGRect(x: 0, y: subViewY_axis, width: ScreenSize.width, height: ScreenSize.height - subViewY_axis)
            view.addSubview(controller.view)
            controller.didMove(toParentViewController: self)
        }
        else if index == 2 {
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: kstoryStoryboardID) as? FRStoryViewController
            controller?.fromViewController = kBrandStories
            addChildViewController(controller!)
            controller?.view.frame = CGRect(x: 0, y: subViewY_axis, width: ScreenSize.width, height: ScreenSize.height-subViewY_axis)
            view.addSubview((controller?.view)!)
            controller?.didMove(toParentViewController: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}



