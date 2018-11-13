//
//  CheckInStatusViewController.swift
//  Frinck
//
//  Created by vineet patidar on 22/05/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import CropViewController

class CheckInStatusViewController: UIViewController {
    
    @IBOutlet var storeNameLable: UILabel!
    @IBOutlet var levelupImage: UIImageView!
    @IBOutlet var levelLable: UILabel!
    @IBOutlet var pointLable: UILabel!
    var timer : Timer!
    var isMyCheckin : Bool = false
    @IBOutlet var slider: UISlider!
    
    var loginInfoDictionary :NSMutableDictionary!
    var statusDictioinary = [String:Any]()
    var selectedDictioinary = [String:Any]()
    var showMsg : String = ""
    var checkinPoints : NSNumber = 0
    var titleView : TitleView!
    var expireTime : TimeInterval!
    var remainsExpireTime : String = ""
    var storeId : String = ""
    var brandId : String = ""
    
    @IBOutlet var statusTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        slider.setMaximumTrackImage(#imageLiteral(resourceName: "sliderW"), for: .normal)
        slider.setMinimumTrackImage(#imageLiteral(resourceName: "sliderR"), for: .normal)
        
        statusTable.register(UINib(nibName: "CheckInStatusCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        if !isMyCheckin {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.addPopUp()
            }
        }
//        else {
            checkStatus()
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if timer != nil {
            timer.invalidate()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addPopUp() {
        let viewAlert = CustomAlert(frame: self.view.bounds)
        viewAlert.loadView(customType: .DailyCheckInSuccess , strMsg: showMsg, type: .success, checkInpoints: "\(checkinPoints)", image: #imageLiteral(resourceName: "congratulationsCheckin")) { (success) in
            self.checkStatus()
            if let isSucess = success as? Bool, isSucess == true {
                viewAlert.removeFromSuperview()
            } else {
                viewAlert.removeFromSuperview()
            }
        }
        let window = UIApplication.shared.keyWindow!
        window.addSubview(viewAlert)
    }
    
    // MARK BUTTON ACTION
    @IBAction func cameraButtonAction(_ sender: Any) {
        
        let cameraActionSheet = UIAlertController(title: "", message: "Choose Gallery Type", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: {(index)-> Void in
            //   self.dismiss(animated: true, completion: nil)
            self.mediaTypeicker(type: 1)
            
        })
        
        let gallery = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default, handler: {(index)-> Void in
            // self.dismiss(animated: true, completion: nil)
            self.mediaTypeicker(type: 0)
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(index)-> Void in
            // self.dismiss(animated: true, completion: nil)
        })
        
        cameraActionSheet.addAction(gallery)
        cameraActionSheet.addAction(camera)
        cameraActionSheet.addAction(cancel)
        
        self.present(cameraActionSheet, animated: true, completion: nil)
    }
    
    @IBAction func writeStoryButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: kcreatStorySegueIdentifier, sender: nil)
    }
    @IBAction func backButtonAction(_ sender: Any) {
        if (self.navigationController?.viewControllers.count)! > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            AppDelegate.delegate.goToHomeScreen()
        }
    }
    
    // MARK get expire Time
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.getExpireTime), userInfo: nil, repeats: true)
    }
    
    @objc func getExpireTime(){
        
        let remainingTime  = self.expireTime
        let currentTimeStamp = Date().toMillis()
        
        let diff = Int(remainingTime! - currentTimeStamp!)
//        print("Expire Time \(String(describing: remainingTime))")
//        print("Current Time \(String(describing: currentTimeStamp))")
//        print("Difference \(diff)")
        let indexPath : IndexPath  = IndexPath.init(row: 1, section: 0)
        let cell : CheckInStatusCell = self.statusTable.cellForRow(at: indexPath as IndexPath) as! CheckInStatusCell
        if diff > 0 {
            let hours = diff / 3600
            let minutes = (diff - hours * 3600) / 60
            let sec = diff % 60
            cell.timeLable.text = "\(hours) : \(minutes) : \(sec)"
            print("\(hours) : \(minutes) : \(sec)")
            cell.clockImage.isHidden = false
        } else {
            cell.timeLable.text = "Expire"
            cell.timeLable.textColor = .red
            cell.clockImage.isHidden = true
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kcreatStorySegueIdentifier {
            let statusViewController : CreatStoryViewController = (segue.destination as? CreatStoryViewController)!
            if sender  is UIImage {
                statusViewController.previousImage = sender as? UIImage
            }
            else if  sender is NSURL {
                statusViewController.previousVideoUrl = sender as? NSURL
            }
            
            statusViewController.selectedDictioinary = self.selectedDictioinary
        }
    }
    
    //MARK: - API Call    
    func checkStatus(){
        
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            kStoreId : selectedDictioinary[kStoreId] ?? ""
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kcheckinStatus))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        print("Checkin status \(dict)")
                        self.statusDictioinary = dict.value(forKey: kPayload) as! [String : Any]
                        print(self.statusDictioinary)
                        let storeName : String = self.statusDictioinary[kStoreName] as? String ?? ""
                        
                        self.storeNameLable.text = storeName
                        self.expireTime = (self.statusDictioinary["expireTime"] as? TimeInterval)!
                        self.statusTable.reloadData()
                        
//                        let isStoryPost : Int = self.statusDictioinary[kisStoryPost] as? Int ?? 0
                        
//                        if isStoryPost == 0 {
                            self.startTimer()
//                        }
                        
                    }
                    else
                    {
                        let message = dict[kMessage]
                        
//                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
//                            
//                        })
                        
                    }
                }
            }
        }
    }
}

extension CheckInStatusViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CheckInStatusCell
        cell?.selectionStyle = .none
        
        let isStoryPost : Int = self.statusDictioinary[kisStoryPost] as? Int ?? 0
        cell?.clockImage.isHidden = true
        
        if indexPath.row  == 0 {
            cell?.clockImage.isHidden = true
            cell?.timeLable.isHidden = true
            cell?.checkMarkImage.image = UIImage(named : "redcheck")
            cell?.textLable.text = "You have successfully checked in"
        } else {            
            if isStoryPost == 1 {
                cell?.checkMarkImage.image = UIImage(named : "redcheck")
                cell?.textLable.text = "You have successfully post story"
                slider.value = 2
            } else {
                if let postHours = self.statusDictioinary["postHours"] {
                    cell?.textLable.text = "Earn more by posting a story within \(String(describing: postHours)) hours"
                }
                cell?.checkMarkImage.image = UIImage(named : "roundCheckGray")
                                slider.value = 1
            }
            cell?.clockImage.isHidden = false
            cell?.timeLable.isHidden = false
        }
        
        return cell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (statusDictioinary.count != 0) ? 2 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row  == 0{
            return 70
        }
        return 80
    }
}

extension CheckInStatusViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
extension CheckInStatusViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil);
            self.presentCropViewController(image: image)

        }
        else if let videoUrl = info[UIImagePickerControllerMediaURL] as! NSURL?{
            picker.dismiss(animated: true, completion: nil);
            self.performSegue(withIdentifier: kcreatStorySegueIdentifier, sender: videoUrl)

            
        }
    }
    
    func mediaTypeicker (type : NSInteger) {
        
        let imag = UIImagePickerController()
        imag.delegate = self
        imag.mediaTypes = [kUTTypeImage as String, kUTTypeVideo as String, kUTTypeMovie as String]
        imag.allowsEditing = false
        
        if type == 1 {
            imag.sourceType = UIImagePickerControllerSourceType.camera;
        }
        else {
            imag.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
        }
        self.present(imag, animated: true, completion: nil)
    }
    
   
}

extension CheckInStatusViewController :CropViewControllerDelegate {
    
    func presentCropViewController(image : UIImage) {
        
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil);
        self.uploadData(image: image)
    }
    
    func uploadData(image : UIImage){
        
        self.performSegue(withIdentifier: kcreatStorySegueIdentifier, sender: image)

    }
}
extension Date {
    func toMillis() -> Double! {
        return Double(self.timeIntervalSince1970)
    }
}

