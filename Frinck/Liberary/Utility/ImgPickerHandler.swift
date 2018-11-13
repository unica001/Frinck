//
//  ImgPickerHandler.swift
//  Frinck
//
//  Created by meenakshi on 5/29/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

enum PickerMediaType {
    case ImageOnly
    case VideoOnly
    case AllMedia
}

class ImgPickerHandler: NSObject
{
    static let sharedHandler = ImgPickerHandler()
    weak var guestInstance: UIViewController? = nil
    var imageClosure: ((UIImage?, Bool)->())? = nil
    var imgInfoClosure: (([String: Any], Bool)->())? = nil
    
    // Public Methods
    func getImage(instance: UIViewController, rect: CGRect?, completion: ((_ myImage: UIImage?, _ success: Bool)->())?) {
        guestInstance = instance
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.videoQuality = .typeMedium
        imgPicker.allowsEditing = true
        imgPicker.mediaTypes = [(kUTTypeImage) as String]
        let actionSheet = UIAlertController(title: "Choose" , message: "Select to upload" , preferredStyle: .actionSheet)
        let actionSelectCamera = UIAlertAction(title: "Camera", style: .default, handler: {
            UIAlertAction in
            self.openCamera(picker: imgPicker)
        })
        let actionSelectGallery = UIAlertAction(title: "Gallery", style: .default, handler: {
            UIAlertAction in
            self.openGallery(picker: imgPicker)
        })
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(actionCancel)
        actionSheet.addAction(actionSelectCamera)
        actionSheet.addAction(actionSelectGallery)
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.guestInstance?.present(actionSheet, animated: true, completion: nil)
        } else {
            actionSheet.popoverPresentationController?.sourceView = guestInstance?.view
            actionSheet.popoverPresentationController?.sourceRect = rect!
            actionSheet.popoverPresentationController?.permittedArrowDirections = .any
            self.guestInstance?.present(actionSheet, animated: true, completion: nil)
        }
        imageClosure = {
            (image, success) in
            completion?(image, success)
        }
    }
    
    func getImageDict(instance: UIViewController, rect: CGRect?,mediaType: PickerMediaType = PickerMediaType.ImageOnly,completion: ((_ imgDict: [String: Any], _ success: Bool)->())?) {
        guestInstance = instance
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        switch mediaType {
        case .ImageOnly:
            imgPicker.mediaTypes = [(kUTTypeImage) as String]
        case .VideoOnly:
            imgPicker.mediaTypes = [(kUTTypeVideo) as String]
        case .AllMedia:
            imgPicker.mediaTypes = [(kUTTypeVideo) as String, (kUTTypeImage) as String]
        }
        let actionSheet = UIAlertController(title: "Choose" , message: "Select to upload", preferredStyle: .actionSheet)
        let actionSelectCamera = UIAlertAction(title: "Camera", style: .default, handler: {
            UIAlertAction in
            
            self.openCamera(picker: imgPicker)
        })
        let actionSelectGallery = UIAlertAction(title: "Gallery", style: .default, handler: {
            UIAlertAction in
            self.openGallery(picker: imgPicker)
        })
        let actionCancel = UIAlertAction(title: "Cancel" , style: .cancel, handler: nil)
        actionSheet.addAction(actionCancel)
        actionSheet.addAction(actionSelectCamera)
        actionSheet.addAction(actionSelectGallery)
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.guestInstance?.present(actionSheet, animated: true, completion: nil)
        } else {
            actionSheet.popoverPresentationController?.sourceView = guestInstance?.view
            actionSheet.popoverPresentationController?.sourceRect = rect!
            actionSheet.popoverPresentationController?.permittedArrowDirections = .up
            self.guestInstance?.present(actionSheet, animated: true, completion: nil)
        }
        imgInfoClosure = {
            (dictInfo, success) in
            completion?(dictInfo, success)
        }
    }
    
    func getImage(instance: UIViewController,isSourceCamera: Bool, completion: ((_ myImage: UIImage?, _ success: Bool)->())?) {
        guestInstance = instance
        let imgPicker = UIImagePickerController()
        imgPicker.navigationBar.isHidden = false
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        imgPicker.mediaTypes =  [(kUTTypeImage) as String]
        if isSourceCamera {
            self.openCamera(picker: imgPicker)
            imgPicker.videoMaximumDuration = TimeInterval(5)
        } else {
            self.openGallery(picker: imgPicker)
        }
        imageClosure = {
            (image, success) in
            completion?(image, success)
        }
    }
    
    func getImageDict(instance: UIViewController,isSourceCamera:Bool,rect: CGRect?, mediaType: PickerMediaType = PickerMediaType.ImageOnly, completion: ((_ imgDict: [String: Any], _ success: Bool)->())?) {
        guestInstance = instance
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        
        switch mediaType {
        case .ImageOnly:
            imgPicker.mediaTypes = [(kUTTypeImage) as String]
        case .VideoOnly:
            imgPicker.mediaTypes = [(kUTTypeMovie) as String]
        case .AllMedia:
            imgPicker.mediaTypes = [(kUTTypeMovie) as String, (kUTTypeImage) as String]
        }
        if isSourceCamera {
            self.openCamera(picker: imgPicker)
        } else {
            self.openGallery(picker: imgPicker)
        }
        
        imgInfoClosure = {
            (dictInfo, success) in
            completion?(dictInfo, success)
        }
    }
    
    //Private Methods
    private func openCamera(picker: UIImagePickerController) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.videoMaximumDuration = 5
            self.guestInstance?.present(picker, animated: true, completion: nil)
        } else {
            imgInfoClosure?([:], false)
            imageClosure?(nil, false)
            let alert = UIAlertController(title: "Warning" , message: "Camera not available", preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "Ok" , style: .default, handler: nil)
            alert.addAction(actionOK)
            self.guestInstance?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func openGallery(picker: UIImagePickerController)
    {
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        DispatchQueue.main.async {
            self.guestInstance?.present(picker, animated: true, completion: nil)
        }
    }
    
}

//MARK: - UIImagePicker Delegates
extension ImgPickerHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) //Cancel button  of imagePicker
    {
        imgInfoClosure?([:], false)
        imageClosure?(nil, false)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) //Picking Action of ImagePicker
    {
        picker.dismiss(animated: true, completion: nil)
        
        imgInfoClosure?(info, true)
        var img: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            img = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            img = originalImage
        }
        
        if img != nil {
            imageClosure?(img, true)
        }
    }
    
}
