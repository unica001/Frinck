
import UIKit
import SDWebImage
import MobileCoreServices
import CropViewController
import AWSS3
import AWSCore
import Photos
import MobileCoreServices
import SDWebImage

class CreatStoryViewController: UIViewController,UITextViewDelegate {
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var userNameLable: UILabel!
    @IBOutlet var profileTypeLable: UILabel!
    
    @IBOutlet weak var imgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var videoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var videoPlayer: AGVideoPlayerView!
    @IBOutlet weak var headerView: UIView!
    var selectedDictioinary = [String:Any]()
    
    var videoUrl : NSURL!
    var uploadImage : UIImage!
    
    var loginInfoDictionary :NSMutableDictionary!
    var uploadDocumentType : NSInteger = 0
    
    let viewHeight = 120
    let headerViewMaxHeight = 330
    let headerViewMinHeight = 200
    
    var previousVideoUrl : NSURL?
    var  previousImage : UIImage?
    var isEdit: Bool = false
    var dictStory : PostListModel?
    var isChange : Bool = false
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary
        
        // Profile Image
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.masksToBounds = true
        
        var urlString = loginInfoDictionary["imageUrl"] as? String ?? ""
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: urlString)
        profileImage.sd_setImage(with:url , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
        // User Name
        let userName = loginInfoDictionary[kCustomerName] as? String
        userNameLable.text = userName
        
        if isEdit {
            print(dictStory?.brandId)
            headerViewHeight()
            textView.textColor = UIColor.black
            textView.text = dictStory?.desc
            
            if dictStory?.meditaType == kVideo {
                videoPlayer.isHidden = false
                imgView.isHidden = true
                
                videoPlayer.videoUrl = URL(string : (dictStory?.mediaUrl)!)
                videoPlayer.shouldAutoplay = false
                videoPlayer.shouldAutoRepeat = true
                videoPlayer.showsCustomControls = true
                videoPlayer.shouldSwitchToFullscreen = true
            } else {
                let sdCache = SDImageCache.shared()
                videoPlayer.isHidden = true
                imgView.isHidden = false
                let urlString = dictStory?.mediaUrl ?? ""
                
                if let urlString = urlString as? String {
                    if (sdCache.imageFromCache(forKey: urlString) != nil) {
                        self.imgView.sd_setImage(with: URL(string: urlString), completed: nil)
                    } else {
                        self.imgView.sd_setImage(with: URL(string: urlString), completed: { (image, err, cacheType, url) in
                            if err == nil {
                                
                            } else {
                                self.imgView.image = UIImage(named : "placeHolder")
                            }
                        })
                    }
                }
            }
            
        } else {
            // Text View
            textView.textColor = UIColor.lightGray
            textView.text = "Write Caption"
            
            headerView.frame.size.height = CGFloat(headerViewMinHeight)
            videoViewHeight.constant = 0
            imgViewHeight.constant = 0
            
            
            if previousImage != nil {
                
                imgView.image = previousImage
                videoPlayer.isHidden = true
                imgView.isHidden = false
                headerViewHeight()
                uploadDocumentType = 1
                self.uploadImage =  self.previousImage
            }
            else if previousVideoUrl != nil {
                headerViewHeight()
                
                videoPlayer.isHidden = false
                imgView.isHidden = true
                
                videoPlayer.videoUrl = self.previousVideoUrl! as URL
                videoPlayer.shouldAutoplay = false
                videoPlayer.shouldAutoRepeat = true
                videoPlayer.showsCustomControls = true
                videoPlayer.shouldSwitchToFullscreen = true
                
                self.videoUrl = self.previousVideoUrl
                uploadDocumentType = 2
            }
        }
 
    }
    
    // MARK Textview Delegates
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = UIColor.black
        if textView.text == "Write Caption" {
            textView.text = ""
        }
//        textView.text = ""
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        else if textView.text == "Write Caption" {
            textView.textColor = UIColor.black
            textView.text = ""
        }
        
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK Button Action
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func postUserStoryButtonAction(_ sender: Any) {
        
        self.textView.resignFirstResponder()
        
        if checkValidation() == true {
            uploadDocumentOnS3()
        }
        
    }
    
    // MARK  Load document on s3
    func getFileName()-> String {
        let date = Date()
        let interval = date.timeIntervalSince1970
        return String(interval)
    }
    
    
    func uploadDocumentOnS3(){
        
        // Check Interner connection
        
        if ReachabilityHelper.isConnectedToNetwork(){
            if uploadDocumentType == 1{
                SKActivityIndicator.show()
                NetworkManager.sharedInstance.uploadImageOnS3( saveImageInDirectory(), fileName: getFileName(), hude: true, fromView: "createStory", completionHandler: { (responce : String) in
                    SKActivityIndicator.dismiss()
                    if responce == "" {
                        return
                    }
                    DispatchQueue.main.async {
                        self.postStoryOnServer(responce, "image")
                    }
                })
            } else if uploadDocumentType == 2 {
                SKActivityIndicator.show()
                NetworkManager.sharedInstance.uploadVideoOnS3(saveVideoInDirectory() as URL, fileName:getFileName(), hude: true, completionHandler: {(responce : String) in
                    SKActivityIndicator.dismiss()
                    if responce == "" {
                        return
                    }
                    DispatchQueue.main.async {
                        self.postStoryOnServer(responce, "video")
                    }
                })
            } else if isEdit && !isChange {
                editStory("", "")
            }
        } else {
            let brandID : Int = (self.selectedDictioinary[kBrandId] as? Int)!
            let storeId : Int = (self.selectedDictioinary[kStoreId] as? Int)!
            let customerId : Int = (loginInfoDictionary[kCustomerId] as? Int)!
            let strDesc : String = textView.text
            var isSuccess : Bool = false
            if !isEdit {
                if uploadDocumentType == 1{
                    let imageData :Data = UIImagePNGRepresentation(uploadImage)!
                    isSuccess = insertDataInStoryTable(imageData as NSData, String(customerId), String(brandID), String(storeId), strDesc, media: "image")
                } else if uploadDocumentType == 2 {
                    do {
                        let urlData = try Data(contentsOf: videoUrl as URL)
                        isSuccess = insertDataInStoryTable(urlData as NSData, String(customerId), String(brandID), String(storeId), strDesc, media: "video")
                    } catch {
                        print("Unable to load data: \(error)")
                    }
                }
            }
            
            
            // save in BD
            
            if isSuccess == true {
                alertController(controller: self, title: "No Internet Available", message: "Your Story save successfully, When internet available it will automatically post", okButtonTitle: "Ok", completionHandler: {(index) -> Void in
                    self.navigationController?.popViewController(animated: true)
                })
                
            }
        }
    }
    
    func saveImageInDirectory() -> URL{
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(getFileName()).jpeg")
        let imageData = UIImageJPEGRepresentation(uploadImage, 0.99)
        fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
        
        let url : URL = URL(fileURLWithPath: path)
        return url
    }
    
    func saveVideoInDirectory() -> URL {
        print(videoUrl)
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(getFileName()).mov")
        print(path)
        if let videoData = NSData(contentsOf: videoUrl as URL){
            videoData.write(toFile: path, atomically: false)
        }
        return NSURL(fileURLWithPath: path) as URL
    }
    
    func postStoryOnServer(_ responce : String ,_ mediaType : String){
        if responce == "" {
            alertController(controller: self, title: "Failed", message: "Fail to upload document on AWS", okButtonTitle: "OK", completionHandler :{(index) -> Void in})
        } else{
            if isEdit {
                self.editStory(responce, mediaType)
            } else {
                self.postStory(responce, mediaType)
            }
        }
    }
    
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
    
    // Check Validation
    
    func checkValidation()-> Bool {
        
        if textView.text == "" || textView.text == "Write Caption"
        {
            alertController(controller: self, title: "", message: "Please write caption", okButtonTitle: "OK", completionHandler: {(index) ->
                Void in
            })
            return false
        }
        else  if uploadDocumentType == 0 && !isEdit
        {
            alertController(controller: self, title: "", message: "Please add photo / video", okButtonTitle: "OK", completionHandler: {(index) ->
                Void in
            })
            return false
        } else if isEdit && isChange && uploadDocumentType == 0 {
            alertController(controller: self, title: "", message: "Please add photo / video", okButtonTitle: "OK", completionHandler: {(index) ->
                Void in
            })
            return false
        }
        return true
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    //MARK: - API Call
    
    
    func postStory(_ uploadUrlString : String,_ mediaType: String ){
        
        let brandID : Int = (self.selectedDictioinary[kBrandId] as? Int)!
        let storeId : Int = (self.selectedDictioinary[kStoreId] as? Int)!
        
        
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            kBrandId : String(brandID),
            kStoreId : String(storeId),
            kMediaUrl : uploadUrlString,
            kType : "public",
            kTitle : "iOS",
            kMediaType : mediaType,
            kDescription : textView.text
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kcheckinpoststory))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let message = dict[kMessage]
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
//                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                        
                            self.uploadDocumentType = 0
                            self.navigationController?.popToRootViewController(animated: true)
//                        })
                        
                    }
                    else {
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                    }
                }
            }
        }
    }

    func editStory(_ uploadUrlString : String,_ mediaType: String ){
        
        let brandID = dictStory?.brandId
        let storeId = dictStory?.storeId
        let storyId = dictStory?.storyId
        
        
        var params: NSMutableDictionary = [:]
        params = [
            kCustomerId : loginInfoDictionary[kCustomerId]!,
            kBrandId : brandID ?? 0,
            kStoreId : storeId ?? "",
            kStoryId : storyId ?? "",
            kMediaUrl : (uploadUrlString == "") ? dictStory?.mediaUrl ?? "" : uploadUrlString ,
            kType : "public",
            kTitle : "iOS",
            kMediaType : (mediaType == "") ? dictStory?.meditaType ?? "" : mediaType,
            kDescription : textView.text
        ]
        print(params)
        let requestURL: URL = URL(string: String(format: "%@%@",kBaseUrl,kstoryEdit))!
        
        NetworkManager.sharedInstance.postRequest(requestURL, hude: true,isAuthentication: false, showSystemError: true, loadingText: false, params: params) { (response: NSDictionary?) in
            if (response != nil) {
                
                DispatchQueue.main.async {
                    
                    let dict  = response!
                    let message = dict[kMessage]
                    let index :String = String(format:"%@", response![kCode]! as! CVarArg)
                    if index == "200" {
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            
                            self.uploadDocumentType = 0
                            self.navigationController?.popViewController(animated: true)
                        })
                        
                    }
                    else {
                        alertController(controller: self, title: "", message:message! as! String, okButtonTitle: "OK", completionHandler: {(index) -> Void in
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                }
            }
        }
    }

}

extension CreatStoryViewController :CropViewControllerDelegate {
    
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
        imgView.image = image
        videoPlayer.isHidden = true
        imgView.isHidden = false
        headerViewHeight()
        uploadDocumentType = 1
        self.uploadImage = image
    }
}

extension CreatStoryViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        isChange = true
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil);
            self.presentCropViewController(image: image)
        }
        else if let videoUrl = info[UIImagePickerControllerMediaURL] as! NSURL?{
            headerViewHeight()
            
            videoPlayer.isHidden = false
            imgView.isHidden = true
            
            videoPlayer.videoUrl = videoUrl as URL
            videoPlayer.shouldAutoplay = false
            videoPlayer.shouldAutoRepeat = true
            videoPlayer.showsCustomControls = true
            videoPlayer.shouldSwitchToFullscreen = true
            
            self.videoUrl = videoUrl
            uploadDocumentType = 2
            picker.dismiss(animated: true, completion: nil);
            
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
    
    func headerViewHeight(){
        headerView.frame.size.height = CGFloat(headerViewMaxHeight)
        videoViewHeight.constant = CGFloat(viewHeight)
        imgViewHeight.constant = CGFloat(viewHeight)
    }
}


