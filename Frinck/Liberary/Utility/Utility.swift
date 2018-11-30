//
//  Utility.swift
//  Hoopoun
//
//  Created by vineet patidar on 16/08/17.
//  Copyright © 2017 Ramniwas Patidar. All rights reserved.
//

import UIKit


class Utility: NSObject {

    class var sharedInstance: Utility {
        struct Static {
            static let instance = Utility()
        }
        return Static.instance
    }
    
    func getDateFromTimeStamp(timeStamp : Double) -> Date {
        let date = NSDate(timeIntervalSince1970: timeStamp)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        
        return dayTimePeriodFormatter.date(from: dateString)!
    }
    
    func localDate(date : Date) -> Date {
        if let timeZone = TimeZone(abbreviation: "UTC") {
            let seconds = TimeInterval(timeZone.secondsFromGMT(for: date))
            return Date(timeInterval: seconds, since: date)
        }
        return date
    }
    
    func relativePast(for date : Date) -> String
    {
        let todayDate = NSDate(timeIntervalSince1970:Constant.Time().nowTime())
        
        let units = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second,.timeZone, .weekOfYear])
        
        let components = Calendar.current.dateComponents(units, from: date, to: todayDate as Date)
        
        if components.year! > 0 {
            let strTime = "\(components.year!) " + (components.year! > 1 ?"years ago"  : "year ago")
            return strTime
        } else if components.month! > 0 {
            let strTime = "\(components.month!) " + (components.month! > 1 ? "months ago": "month ago")
            return strTime
        } else if components.weekOfYear! > 0 {
            let strTime = "\(components.weekOfYear!) " + (components.weekOfYear! > 1 ? "weeks ago" : "week ago")
            return strTime
        } else if (components.day! > 0) {
            let strTime = (components.day! > 1 ? "\(components.day!) days ago" :"Yesterday")
            return strTime
        }
        else if components.hour! > 0
        {
            let strTime = "\(components.hour!) " + (components.hour! > 1 ? "hours ago" : "hour ago")
            return strTime
        }
        else if components.minute! > 0
        {
            let strTime = "\(components.minute!) " + (components.minute! > 1 ?"mins ago" : "min ago")
            return strTime
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
    }
}

class Constant {
    struct Time {
        let nowTime = { round(Date().timeIntervalSince1970) } // seconds
    }
}

func calculateHeightForString(_ inString:String,_width :CGFloat) -> CGFloat
{
    let messageString = inString
    let attrString:NSAttributedString? = NSAttributedString(string: messageString, attributes: nil)
    let rect:CGRect = attrString!.boundingRect(with: CGSize(width: _width,height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context:nil )//hear u will get nearer height not the exact value
    let requredSize:CGRect = rect
    return requredSize.height  //to include button's in your tableview
}

func calculateHeightForlblText(_ inString:String,  _width :CGFloat) -> CGFloat
{
    let constraintRect = CGSize(width: _width, height: CGFloat.greatestFiniteMagnitude)
    
    let boundingBox = inString.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [ NSAttributedStringKey.font: UIFont(name: kFontTextRegular, size: 14.2)! ], context: nil)
    
    return boundingBox.height
}

func calculateHeightForlblTextWithFont(_ inString:String,  _width :CGFloat, font : UIFont) -> CGFloat
{
    let constraintRect = CGSize(width: _width, height: CGFloat.greatestFiniteMagnitude)
    
    let boundingBox = inString.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [ NSAttributedStringKey.font: font], context: nil)
    return boundingBox.height
}

func getVersion() -> String {
    let dictionary = Bundle.main.infoDictionary!
    let version = dictionary["CFBundleShortVersionString"] as! String
    let build = dictionary["CFBundleVersion"] as! String
    return "\(version) build \(build)"
}

func createHttpBody(sharingDictionary : NSMutableDictionary) -> Data
{
    let parameterArray : NSMutableArray = []
    
    for keyValue in sharingDictionary.allKeys
    {
        let keyString = "\(keyValue)=\(sharingDictionary[keyValue]!)"
        parameterArray.add(keyString)
    }
    var postString = String()
    
    postString = parameterArray.componentsJoined(by: "&")
    print(postString)
    return postString.data(using: .utf8)!
}

func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}

func isValidlPassword(testStr: String) -> Bool
{
    let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[0-9])(?=.*[!@#$%^&*.])(?=.*[a-z]).{6,}")
    //"(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,}"
    return passwordTest.evaluate(with: testStr)
}

func checkSpecialCharacter(string : String)-> Bool {
  var isSpecialCharacter = false
    let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    if string.rangeOfCharacter(from: characterset.inverted) != nil {
        isSpecialCharacter = true
    }
    return isSpecialCharacter
}

// MARK Alert View

func alertController(controller:UIViewController,title:String, message:String,okButtonTitle:String,completionHandler:@escaping (_ index: NSInteger) -> ()){
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: okButtonTitle, style: UIAlertActionStyle.default, handler:{ (action: UIAlertAction!) in
        completionHandler(0)
}))
   controller.present(alert, animated: true, completion: nil)

}

// MARK Alert for show 2 button action
func alertController(controller:UIViewController,title:String, message:String,okButtonTitle:String,cancelButtonTitle: String,completionHandler:@escaping (_ index: NSInteger) -> ()){
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
     alert.addAction(UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.default, handler:{ (action: UIAlertAction!) in
        completionHandler(0)
    }))
    alert.addAction(UIAlertAction(title: okButtonTitle, style: UIAlertActionStyle.default, handler:{ (action: UIAlertAction!) in
        completionHandler(1)
    }))
    controller.present(alert, animated: true, completion: nil)
    
}

//MARK: Archive And Unarchive

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func archive(filename :String, dict:NSDictionary){

    let data = NSKeyedArchiver.archivedData(withRootObject: dict)
    let fullPath = getDocumentsDirectory().appendingPathComponent(filename)
    
    do {
        try data.write(to: fullPath)
    } catch {
        print("Couldn't write file")
    }
}

func unArchive(fileName :String)-> NSDictionary{
    let fullPath = getDocumentsDirectory().appendingPathComponent(fileName)
    let loadedStrings = NSKeyedUnarchiver.unarchiveObject(withFile: fullPath.absoluteString) as? [String]
    return loadedStrings as Any as! NSDictionary
}

func convertArrayIntoJsonString(from object: Any) -> String? {
    if let objectData = try? JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions(rawValue: 0)) {
        let objectString = String(data: objectData, encoding: .utf8)
        return objectString
    }
    return nil
}

func convetDateIntoString(date :String)-> String{
    print(date)
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    let date: Date? = dateFormatterGet.date(from: date)
    return (dateFormatter.string(from: date!))
}
