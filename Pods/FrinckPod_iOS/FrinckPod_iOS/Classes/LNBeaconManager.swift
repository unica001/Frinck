
//  LNBeaconManager.swift
//  Created by LN-MCMI-005 on 04/06/18.

import Foundation
import CoreLocation
import CoreData
import UIKit

let kNotificationCenter_Local = "NotificationLocal"

open class LNBeaconManager : NSObject {
    
    open var locationManager: CLLocationManager?
    internal var isAnyUpdate = false
    internal var timer : Timer?
    internal var timerNotification : Timer?
    internal var notificationTime : Date!
    internal var region : CLBeaconRegion!
    public var BeaconRegion : CLRegion!
    open var proximityUUID : UUID?
    open var uuid: UUID?
    open var minor: NSNumber?
    open var major: NSNumber?
    open var identifier : String?
    internal var strNearBeaconUuid = ""
    internal var isBeaconId  = false
    internal var strGetBeaconURL = ""
    internal var bundleIdentifier = Bundle.main.bundleIdentifier!
    var isfirstTimeURLCalled = true
    var objCurrent:BeaconData!
    
    //MARK : - Delegate Declaration
    open var delegateManager : LNBeaconDataManagerDelegate?
    
    internal var BeaconArray  = [BeaconData]()
    internal var arrNewDetectBeacon = [BeaconData]()
    internal var arrOldDetectBeacon = [BeaconData]()
    internal var arrSavedBeacon  = [BeaconData]()
    open var userOBj = [String:Any]()
    
    static let sharedInstance = LNBeaconManager()
    
    public override init() {
        super.init()
        self.startToRange()
    }
    
    //    /// Save the single instance
    static var instance : LNBeaconManager {
        return sharedInstance
    }
    
    /**
     Singleton pattern method
     
     - returns: Bluetooth single instance
     */
    static func getInstance() -> LNBeaconManager {
        return instance
    }
    
    /**
     reports user's location
     */
    
    public func startToUpdateLocation() {
        locationManager?.startUpdatingLocation()
    }
    
    /**
     Stop Ranging for all regions.
     */
    public func stopToRange() {
        locationManager?.stopRangingBeacons(in: region)
    }
    
    /**
     Stops  giving location updates
     */
    
    public func stopToUpdateLocation() {
        locationManager?.stopUpdatingLocation()
    }
    
    /**
     Start Ranging for Beacons.
     */
    public func startToRange() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
        }
        else{
            self.startToUpdateLocation()
        }
    }
    
    
    /**
       Recieve Userdata
     */
    
    public func passUserData(userData : [String:Any]) {
        userOBj = userData
    }
    
    // MARK: - Helper
    public func regionForUUID(_ uuid: UUID) -> CLBeaconRegion {
        let region = CLBeaconRegion(proximityUUID: uuid as UUID, identifier: "\(uuid.uuidString)-\(uuid.uuidString)")
        region.notifyEntryStateOnDisplay = true
        return region
    }
    
    public func regionForBeacon() -> CLBeaconRegion {
        let region = CLBeaconRegion(proximityUUID: self.uuid!, major: CLBeaconMajorValue(truncating: self.major!), minor: CLBeaconMinorValue(truncating: self.minor!), identifier: "\(self.uuid!.uuidString)")
        region.notifyEntryStateOnDisplay = true
        return region
    }

    
    /**
     To show timer
     */
    
    internal func startTimer() {
        scheduledNotifyAfterInterval()
        scheduledApiTimerWithInterval()
    }
    
    /**
     To stop API Timer
     */
    internal func stopTimer() {
        timer?.invalidate()
    }
    
    /**
      To stop Notification Timer
    */
    public func stopNotificationTimer() {
        timerNotification?.invalidate()
    }
    
    /** Calls the Notification method, used in showing Notification */
    @objc  func callNotification()
    {
        if objCurrent != nil
        {
            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: objCurrent)
        }
    }
    
    func scheduledNotifyAfterInterval() {
        let min = 10
        timerNotification  = Timer.scheduledTimer(timeInterval: TimeInterval(min * 60), target: self, selector: #selector(callNotification), userInfo: nil, repeats: true)
    }

    /**
     The callback function to store data,and call delegate method
     */
    public func storeData(data : [BeaconData])  {
        _ = delegateManager?.storeDetectData?()
    }
    
    /*
     Check Internet status whether it is Connected or not.
     **/
    public func checkInternet() -> Bool
    {
        let status = CheckInternetStatus().connectionStatus()
        switch status {
        case .unknown, .offline:
            return false
        case .online(.wwan), .online(.wiFi):
            return true
        }
    }
    
    /******************************* GET & POST API Calls *******************************/
    
    /**
     Method: GET
     - Returns list of beacons
     */
    
   
    @objc  func WS_GetBeaconsListAPI() {
        if checkInternet() { //beacon_id=0
            if isBeaconId == false {
                strGetBeaconURL = BASE_URL  + URLS.URL_BeaconList.rawValue+"beacon_id=0&app_id=\(bundleIdentifier)"
                isfirstTimeURLCalled = true
            }

            else {
                isfirstTimeURLCalled = false
                strGetBeaconURL = BASE_URL  + URLS.URL_BeaconList.rawValue+"beacon_id=\(strNearBeaconUuid)&app_id=\(bundleIdentifier)"
            }
            
            print(strGetBeaconURL)
            let beaconListURL = URL(string: strGetBeaconURL)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let request = URLRequest(url: beaconListURL!)
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
                
                guard let data = data, error == nil else { return }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    print(json)
                    
                    if let status = json["status"] as? Int {
                        if status == 0 {
                            print("No Data Found")
                            DispatchQueue.main.async {
                                let bundleIdentifier = Bundle.main.bundleIdentifier!
                                let dict = ["data":["app_id": bundleIdentifier, "app_type":iOSDevice, "sdkownername": "google.in"]]
                                self.WS_PostUnauthorizedUser(param: dict)
                            }
                        }
                        else if status == 1 {
                            let obj = BeaconObject.init(objBeacon: json)
                            for data in obj.data.enumerated() {
                                if self.isfirstTimeURLCalled {
                                    self.BeaconArray.append(data.element)
                                }
                            }
                            print("API return data \(self.BeaconArray)")
                            self.refreshBeacon()
                        }
                        else {
                            DispatchQueue.main.async {
                                let dict = ["data":["app_id": self.bundleIdentifier, "app_type":iOSDevice, "sdkownername": "google.in"]]
                                self.WS_PostUnauthorizedUser(param: dict)
                            }
                        }
                    }
                }
                catch let error as NSError {
                    print(error)
                }
            })
            task.resume()
        }
        else {
            print("No Internet Connection")
        }
    }
    
    /**
     Method: POST
     Parameters: ["data":["app_id":"com.letsnurture.beaconsdk","app_type":"ios","sdkownername":"google.in"]]
     - Adds the data to the database
     */
    private func WS_PostUnauthorizedUser(param: [String : [String : String]]) {
        if checkInternet() {
            // Prepare JSON Data
            let jsonData = try? JSONSerialization.data(withJSONObject: param)
            
            // create post request
            let url = URL(string: BASE_URL + URLS.URL_UnAuthorizedUser.rawValue)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData // insert json data to the request
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else { return }
                print(data)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    print(json)
                    
                    if let status = json["status"] as? Int {
                        if status == 0 {
                            print("No Data Found")
                        }
                        else {
                            print("Data has been added successfully")
                        }
                    }
                }
                catch let error as NSError {
                    print(error)
                }
            }
            task.resume()
        }
        else {
            print("No Internet Connection")
        }
    }
    
    /**
     Method: POST
     Parameters: ["data":["user_id":"1", "device_id":"30e50cb43f4905bf", "device_type":iOSDevice, "in":"44,43", "out":"41", "client_id":"1", "first_name":"Jhon", "last_name":"Cagua"]]
     - Adds the data to the database
     */
    private func WS_PostBeaconHistory(param: [String : [String : String]]) {
        if checkInternet() {
            // Prepare JSON Data
            let jsonData = try? JSONSerialization.data(withJSONObject: param)
            
            // create post request
            let url = URL(string: BASE_URL + URLS.URL_BeaconHistory.rawValue)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData // insert json data to the request
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else { return }
                print(data)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    print(json)
                    
                    if let status = json["status"] as? Int {
                        if status == 0 {
                            print("No Data Found")
                        }
                        else {
                            print("Data has been added successfully")
                        }
                    }
                }
                catch let error as NSError {
                    print(error)
                }
            }
            task.resume()
        }
        else {
            print("No Internet Connection")
        }
    }
    
    public func didAnalysisClick(param : [String : [String : String]]) {
        WS_PostAnalysis(param: param)
    }
    
    /**
     Method: POST
     Parameters: ["data": ["beacon_id":"1", "link":"30e50cb43f4905bf", "type":"ios"]]
     - Analyse the data on admin panel
     */
    private func WS_PostAnalysis(param: [String : [String : String]]) {
        if checkInternet() {
            // Prepare JSON Data
            let jsonData = try? JSONSerialization.data(withJSONObject: param)
            
            // create post request
            let url = URL(string: BASE_URL + URLS.URL_Analysis.rawValue)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData // insert json data to the request
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else { return }
                print(data)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    print(json)
                    
                    if let status = json["status"] as? Int {
                        if status == 0 {
                            print("No Data Found")
                        }
                        else {
                            print("Data has been added successfully")
                        }
                    }
                }
                catch let error as NSError {
                    print(error)
                }
            }
            task.resume()
        }
        else {
            print("No Internet Connection")
        }
    }
    
    
    /**
     Function which converts data to json
     */
    private func convertDataToJson(data: NSData) -> AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as AnyObject
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    
    /** This callback function will be called in GetBeaconsAPI to get list of all beacons */
    private func refreshBeacon(){
        //isfirstTimeURLCalled = false
        if isAnyUpdate {
            var inStr = ""
            var outStr = ""
            var arrOutID = [Int]()
            var arrIDSNew = [Int]()
            for new in arrNewDetectBeacon {
                arrIDSNew.append(new.id)
            }
            
            if arrNewDetectBeacon.count == 0 {
                for oldID in arrOldDetectBeacon {
                    outStr =  outStr + "," + String(oldID.id)
                    arrOutID.append(oldID.id)
                    
                }
                arrSavedBeacon.removeAll()
                arrNewDetectBeacon.removeAll()
                if delegateManager != nil {
                    
                    delegateManager?.didReceiveBeaconData!(data: arrSavedBeacon as AnyObject)
                }
            }
            else {
                for (index,_) in arrNewDetectBeacon.enumerated() {
                    
                    if  index < arrNewDetectBeacon.count {
                        arrNewDetectBeacon.remove(at: index)
                        arrSavedBeacon.remove(at: index)
                    }
                }
                if delegateManager != nil {
                    delegateManager?.didReceiveBeaconData!(data: arrSavedBeacon as AnyObject)
                }
                
            }
            for newID in arrNewDetectBeacon {
                inStr =  inStr + "," + String(newID.id)
                arrOldDetectBeacon = arrNewDetectBeacon
            }
            print("in str" + inStr.dropFirst())
            print( "out str" + outStr.dropFirst())
            print(" New Array of Detected Beacons \(arrNewDetectBeacon)")
            print(" Old Array of Detected beacons \(arrOldDetectBeacon)")
            
            let strInBeacons = inStr.dropFirst()
            let strOutBeacons = outStr.dropFirst()
            
            
            /* API Call to update Beacon List */
            let dataHistory = ["data":["device_id": UIDevice.current.identifierForVendor!.uuidString,
                                       "device_type":iOSDevice,
                                       "in": strInBeacons,
                                       "out":strOutBeacons,
                                       "user_data":userOBj]]
            print(dataHistory)
            self.WS_PostBeaconHistory(param: dataHistory as [String : [String : AnyObject]])
            
        }
        
        for obj in BeaconArray {
        //    print(obj.uuid)
            ///Beacon uuid always contain 128 bits if it is less than 128(36), it would return else it will start detecting the beacons
            if obj.uuid.count < 36 {
                print("UUID constains less than 128 bits which is not proper \(obj.id)")
                return
            }
            else {
                
                for (index,item) in arrNewDetectBeacon.enumerated()
                {
                    if item.uuid == obj.uuid
                    {    if  arrNewDetectBeacon.count > index {
                        arrNewDetectBeacon.remove(at: index)
                        }
                        if delegateManager != nil {
                            delegateManager?.didReceiveBeaconData!(data: arrSavedBeacon as AnyObject)
                        }
                    }
                }
                
                let major = CLBeaconMajorValue(obj.major) //28766
                let minor = CLBeaconMinorValue(obj.minor) //24713
                ///check in beaconRegion which comes in api response
                let beaconRegion  = CLBeaconRegion(proximityUUID: UUID(uuidString: obj.uuid)!, major: major!, minor: minor!, identifier: obj.uuid)
                print("\(beaconRegion)")
              //  print("OBJ UUID \(obj.uuid)")
             // let beaconRegion = CLBeaconRegion.init(proximityUUID: UUID.init(uuidString: obj.uuid)!, identifier: obj.uuid)
               // let beaconRegion  = CLBeaconRegion(proximityUUID: UUID.init(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")!, major: major, minor: minor, identifier: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
                print("allocating beacon region \(beaconRegion)")
                beaconRegion.notifyOnEntry = true
                beaconRegion.notifyOnExit = true
                beaconRegion.notifyEntryStateOnDisplay = true
                self.locationManager?.requestState(for: beaconRegion)
                self.locationManager!.startRangingBeacons(in: beaconRegion)
                self.locationManager?.startMonitoring(for: beaconRegion)
               // self.locationManager?.startUpdatingLocation()
            }
        }
        isAnyUpdate = false
    }
    
    /**
     Method: POST
     Parameters: ["data":[["user_data":"client_id":"11", "first_name":"Jhon","last_name":"Cagua"], "device_id":"30e50cb43f4905bf", "device_type":iOSDevice, "in":"44,43", "out":"41"]]
     - Update the Beacon data
     */
    private func WS_PostBeaconHistory(param: [String : [String : AnyObject]]) {
        
        // Prepare JSON Data
        let jsonData = try? JSONSerialization.data(withJSONObject: param)
        
        // create post request
        let url = URL(string: BASE_URL + URLS.URL_BeaconHistory.rawValue)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData // insert json data to the request
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            print(data)
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                print(json)
                
                if let status = json["status"] as? Int {
                    if status == 0 {
                        print("No Data Found")
                    }
                    else {
                        print("Data has been added successfully")
                    }
                }
            }
            catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
    
    /**
     Call Api after every 30 seconds
     */
    private func scheduledApiTimerWithInterval() {
        print("Timer Start")
       // timer  = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(WS_GetBeaconsListAPI), userInfo: nil, repeats: true)
    }
    
}

// MARK: - CLLocationManagerDelegate
extension LNBeaconManager : CLLocationManagerDelegate {
    /*
     Check the autorization status
     */
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
        }
        else if status == .authorizedWhenInUse ||  status == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        }
        else if status == .notDetermined {
        }
        
        
        delegateManager?.didChangeAuthorization?(status: status)
    }
    
    /*
     Check CLRegionState either if it is inside then ranging of beacon will start else will stop ranging
     */
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        let beacon = region as! CLBeaconRegion
        print("didDetermineState \(beacon)")
        if (state == .inside) {
            region.notifyOnEntry = true
            region.notifyOnExit = true
             manager.startRangingBeacons(in: region as! CLBeaconRegion)
        }
        else if (state == .outside){
            print("outside")
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.stopRangingBeacons(in: region as! CLBeaconRegion)
        }
        else {
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
        }
        delegateManager?.didDetermineState?(monitor: self, state: state, for_region: region)
    }
    
    /*
     In case of error of location failure
     */
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let error = error
        delegateManager?.didFailWithError!(error : error)
    }
    
    /*
     In case Beacon ranging failed
     */
    public func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("rangingBeaconsDidFailFor \(region)")
        delegateManager?.rangingBeaconsDidFailFor!(region : region, withError_error : error)
    }
    
    /*
     Method will start monitoring surrounded beacons
     */
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("didStartMonitoringFor \(region)")
        locationManager?.requestState(for: region)
        delegateManager?.didStartMonitoringFor?(region: region)
    }
    
    /*
     DidEnterRegion will notify you in case you are in region of the beacon
     */
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion \(region)")
        delegateManager?.didEnterRegion?(monitor: self, region: region)
    }
    
    /*
     DidExitRegion will notify you in case you are out of region of the beacon
     */
    open func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion \(region)")
        delegateManager?.didExitRegion?(self, region: region)
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        /** when new beacon is being detected */
        
        print("didRangeBeacons \(beacons)")
        if beacons.count > 0{
            _ = BeaconArray.filter({ (obj) -> Bool in
                print(beacons[0].major)
                print(beacons[0].minor)
                if beacons[0].proximityUUID.uuidString == obj.uuid.uppercased() , String(describing: beacons[0].major) ==  obj.major, String(describing: beacons[0].minor) == obj.minor {
                    if !arrSavedBeacon.contains(obj) {
                        arrSavedBeacon.append(obj)
                        print(arrSavedBeacon)
                        self.isAnyUpdate = true
                        arrNewDetectBeacon = arrSavedBeacon
                        
                        //ReloadData
                        if delegateManager != nil {
                            print("Save Beacon\(arrSavedBeacon.count)")
                            delegateManager?.didReceiveBeaconData?(data: arrSavedBeacon as AnyObject)
                        }
                        
                        if !self.arrSavedBeacon.isEmpty {
                            self.strNearBeaconUuid = String(self.arrSavedBeacon[0].id)
                            isBeaconId = true
                            print("Near Beacon Id \(self.strNearBeaconUuid)")
                        }
                    }
                    
                    notificationTime = getCurrentTime()
                    objCurrent = obj
                    callNotification()
                    storeData(data: arrSavedBeacon)
                }
                return false
            })
        }
    }
}


