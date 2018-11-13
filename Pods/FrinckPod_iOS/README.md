# FrinckPod_iOS

[![CI Status](https://img.shields.io/travis/LetsNurtureGit/FrinckPod.svg?style=flat)](https://travis-ci.org/LetsNurtureGit/FrinckPod)
[![Version](https://img.shields.io/cocoapods/v/FrinckPod.svg?style=flat)](https://cocoapods.org/pods/FrinckPod)
[![License](https://img.shields.io/cocoapods/l/FrinckPod.svg?style=flat)](https://cocoapods.org/pods/FrinckPod)
[![Platform](https://img.shields.io/cocoapods/p/FrinckPod.svg?style=flat)](https://cocoapods.org/pods/FrinckPod)


## Overview
FrinckPod SDK is a wrapper library to detect beacons nearby you and present detailed information about beacons properties. It detects beacons near you and provide information like UUID, Major, Minor, Store/Mall Image/Video, Title and Description of store/mall as well as redirection url. You can get every analysed data on the Admin Panel.

## Installing the iOS SDK
To use the FrinkPod SDK in your project, the minimum deployment target must be iOS 8.0

### CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. It can be installed with the following command:
```swift

$ gem install cocoapods
```

To integrate the FrinkPod SDK into your Xcode project using CocoaPods, specify it in your Podfile:
```ruby
platform :ios, '8.0'
use_frameworks!

pod 'FrinckPod_iOS'
```

Then, run the following command:
```swift
$ pod install
```

## Usage


### Pod Import
To import FrinckPod, you need to mention it with import tag as well as you will also need to import CoreLocation library in your class.

```swift
import FrinckPod_iOS
import CoreLocation
import CoreBluetooth
```

### Assign LNBeaconDataManagerDelegate to ViewController
To use functions, it is mandatory to define LNBeaconDataManagerDelegate with UIViewController.
```swift
class ViewController: UIViewController, LNBeaconDataManagerDelegate, CBCentralManagerDelegate {
..
..
..
}
```

### Get Shared Instance of LNBeaconDataManager and LNBeaconManager
To use functionality of Beacons, you need to take shared instance of LNBeaconDataManager and LNBeaconManager. You need to declare instance of CBCentralManager. Apart from that, you will have to declare array which returns list of beacons.
```swift
var arrBeacons = [BeaconData]()
let beaconManager = LNBeaconDataManager.sharedInstance
let beacondata = LNBeaconManager.sharedInstance
var manager : CBCentralManager!

```

### Pass Logged-in Userdata in centralManagerDidUpdateState() method of CoreBluetooth 
```swift
let userData = ["client_id" : "101", "first_name" : "Tim", "last_name" : "Cook"]
beacondata.passUserData(userData: userData)
```

### Mention required methods in ViewDidLoad()
In ViewDidLoad method, you will have to mention delegate to self and  need to give permission of Bluetooth to detect Kontakt iBeacons as mentioned below:
```swift
   override func viewDidLoad() {
   super.viewDidLoad()
   
        beacondata.delegateManager = self
        // Give Permission of Bluetooth
        let opts = [CBCentralManagerOptionShowPowerAlertKey: false]
        manager = CBCentralManager(delegate: self, queue: nil, options: opts)
        beaconManager.delegate = self

}
```

### Add didReceiveBeaconData delegate method
This is the main implemented method in which all nearby beacons will be received. Implement this mehtod as mentioned below and get your reqired data:
```swift
func didReceiveBeaconData(data: AnyObject?)  {
      arrBeacons = data as! [BeaconData]
  }
```

### Get Analysis of Beacons
If you want to show user analysis on dashboard of your Admin Panel then you need to define it and pass parameters like Beacon Id, URL and Type and then call didAnalysisClick method to post analysis data on the server which is define as follows:

Suppose If you're managing data on TableView then on click of table view cell, you can define under didSelectRowAt delegate method of TableView as follows:
```swift
  let obj = self.arrBeacons[indexPath.row]
  let data = ["data": ["beacon_id":obj.id, "link":obj.link, "type":"2"]]  // type = 2 for iOS Device
  beacondata.didAnalysisClick(param: data as! [String : [String : String]] )
```

### To Start Detect Kontakt iBeacons
Required Methods To be declared in centralManagerDidUpdateState() to detect Kontakt iBeacons i.e mentioned below:

```swift
 func centralManagerDidUpdateState(_ central: CBCentralManager) {
      
    let userData = ["client_id" : "101",
                        "first_name" : "Tim",
                        "last_name" : "Cook"]
        
    switch central.state {
        case .resetting:
            print(" State : Resetting")
            break
            
        case .poweredOn:
            beacondata.startToRange()
            beaconManager.foundBeacons()
            beaconManager.startTimer()
            beacondata.passUserData(userData: userData)
            
        case .poweredOff:
            print("State : Powered Off")
            fallthrough
            
        case .unauthorized:
            print("State : Unauthorized")
            fallthrough
            
        case .unknown:
            print("State : Unknown")
            fallthrough
            
        case .unsupported:
            print("State : Unsupported")
        }
        
    }
```
 
### Store Detected iBeacons
 You can manage and store Detected Beacons with required method:
 
```swift
func storeDetectData() -> [BeaconData]? {
        let obj = arrBeacons
         beacondata.storeData(data: arrBeacons)
        return obj
 }
```

### To manage Notifications 

```swift
func getNotification() {
  print("Your Notification Code")
  // Your Notification Code
}
```

### Delegate Calls
Now we'll add the the delegate methods for beaconManager, and get them to log some output.

```swift
 func didRangeBeacons(beacons: [CLBeacon], in_region: CLBeaconRegion) {
    print("Ranging Beacon \(beacons)")
 }
 
 func didEnterRegion(monitor: LNBeaconManager, region: CLRegion) {
   print("Enter Region \(region)")
 }

 func didExitRegion(_ monitor: LNBeaconManager, region: CLRegion) {
   print("Exit Region \(region)")
 }

  func didChangeAuthorizationStatus(monitor: LNBeaconManager, status: CLAuthorizationStatus) {
    switch status {
        case .authorizedAlways, .authorizedWhenInUse:
                  beacondata.startToUpdateLocation()
				   
        default:
                print("default")
              }
}
```




## Author

letsnurturegit, android.letsnurture@gmail.com

## License

FrinckPod is available under the MIT license. See the LICENSE file for more info.

