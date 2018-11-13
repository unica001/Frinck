//
//  LNBeaconDataManager.swift
//  BeaconSample
//
//  Created by LN-MCMI-005 on 11/06/18.
//  Copyright © 2018 LN-iMAC-003. All rights reserved.
//

import Foundation
import CoreLocation

@objc public protocol LNBeaconDataManagerDelegate : NSObjectProtocol {
    
    
    /**
     This function will be called stop Timer of  Notification
     */
    @objc optional func stopNotificationTimer()
    
    /**
     This callback function will be called to get Notification
    */
    
    @objc optional func getNotification()
    
    /**
     This callback function will be called to reload  Data
     */
    @objc optional func didReceiveBeaconData(data: AnyObject?)
    
    /**
     This callback function will be called to store  Data
     */

    @objc optional func storeDetectData() -> [BeaconData]?
    
    /**
     This callback function will be called to revieve Notification
     */
    @objc optional func beaconWillRecieveNotification(data: AnyObject?)

    /**
     The callback function when the beacon region has failed.
     
     - parameter region   : region that encounters error.
     -parameter  error    : Error which is encountered.
     */
    @objc optional func rangingBeaconsDidFailFor(region : CLBeaconRegion, withError_error : Error)
    
    /**
     The callback function location unables to retrieve a location value.
     
     - parameter  error   : Error which is encountered.
     */
    @objc optional func didFailWithError(error : Error)
    
    /**
     The  callback function when the authorization status has changed.
     
     -parameter status   : new authorization status for application.
     */
    @objc optional func didChangeAuthorization(status : CLAuthorizationStatus)
    
    /**
     The callback function when new data location is available.
     
     -parameter locations : An array of CLLocation objects containing location data.
     */
    @objc optional func didUpdateLocations(locations: [CLLocation])
    
    /**
     The callback function which tells the delegate about the region that is being monitored.
     
     -parameter region : region(CLRegion) that is beinf monitored.
     */
    @objc optional func didStartMonitoringFor(region: CLRegion)
   
    /**
      The callback function which tells the delegate about the authorization status used by location services.
     
     -parameter status : authorization status used in location
    */
    
    @objc optional func didChangeAuthorizationStatus(monitor : LNBeaconManager, status: CLAuthorizationStatus)
    
    
    /**
     The callback function which tells the delegate about the beacons which comes  in range
     
     -parameter _manager : _manager reporting the event.
     -parameter beacons  : An array of Beacons(CLbeacon) which comes in range.
     -parameter region   : region (CLBeaconRegion) that were used to locate beacon.
     */
    @objc optional func didRangeBeacons(monitor : LNBeaconManager,beacons: [CLBeacon], in_region: CLBeaconRegion)
    
    /**
     The callback function which tells the delegate whether the beacon has entered the specific region with its specific states.
     
     -parameter _manager : _manager reporting the event.
     -parameter state    : state of the specified region.
     -parameter region   : region whose state was determined.
     
     */
    @objc optional func didDetermineState(monitor : LNBeaconManager,state: CLRegionState, for_region: CLRegion)
    
    /**
     The callback function which tells the delegate that beacon has entered to a specific region.
     
     -parameter _manager : _manager reporting the event.
     -parameter region   : An object containing information that beacon has entered.
     */
    @objc optional  func didEnterRegion(monitor : LNBeaconManager,region: CLRegion)
    /**
     The callback function which tells the delegate that beacon has exited to a specific region.
     
     -parameter _manager : _manager reporting the event.
     _parameter _region  : An object containing information that beacon has exited the region.
     */
    @objc optional func didExitRegion(_ monitor : LNBeaconManager,region: CLRegion)
    
    
    /**
     The callback function which tells the delegate that updates will no longer be deferred.
     
     -parameter : error which is generated
     */
    @objc optional func didFinishDeferredUpdatesWithError(_ monitor : LNBeaconManager,error : Error?)
    
    /**
     The callback function  that generated the update event
     
     -parameter newLocation : The new location data.
     -parameter oldLocation : The location data from the previous update
     */
    @objc optional func didUpdateToLocation(_ monitor : LNBeaconManager,newLocation : CLLocation, oldLocation: CLLocation)
    
    /**
     The callback function tells the delegate that locatin updates has paused.
     
     -parameter _manager : _manager reporting the event
     */
    @objc optional func didPauseLocationUpdates(_ monitor : LNBeaconManager)
    
    /**
     The callback function which tells the delegate that the delivery of location updates has resumed.
     
     -parameter _manager : _manager reporting the event
     */
    @objc optional func didResumeLocationUpdates(_ monitor : LNBeaconManager,_manager : CLLocationManager)
    
    
    /**
     The callback function which tells the delegate  that the location manager received updated heading information.
     
     -parameter newHeading : new heading data
     */
    @objc optional func didUpdateHeading(heading : CLHeading)
    
    
    /**
     The callback function which asks the delegate whether the heading calibration  alert should be displayed.
     
     -parameter _manager : _manager reporting the event
     */
    @objc optional func shouldDisplayHeadingCalibration(_ monitor : LNBeaconManager) -> Bool
    
    /**
     The callback function tells the delegate that a region monitoring error occurred
     
     -parameter region    : The region for which the error occurred.
     -parameter withError : An error object containing the error code that indicates why region monitoring failed.
     */
    @objc optional func monitoringDidFailFor(_ monitor : LNBeaconManager, region : CLRegion?, withError : Error)
    
    /**
     The callback function tells the delegate that a new visit-related event was received.
     
     -parameter visit: The visit object that contains the information about the event
     */
    
    @objc optional func didVisit(_ monitor : LNBeaconManager,visit : CLVisit)

    
}


public class LNBeaconDataManager : NSObject {
    
    /// This will contain all methods related to CoreLocation Manager
    let locationManager = LNBeaconManager.getInstance()
    
    /// This will assign LNBeaconDataManagerDelegate
    public var delegate : LNBeaconDataManagerDelegate!
    
    ///This will contains an instance of CLRegion
    public var connectedPeripheral : CLRegion?
    
    //sharedInsstance of LNBeaconDataManager class
    
    public static let sharedInstance = LNBeaconDataManager()
    
    func startTimer() {
        LNBeaconManager.getInstance().startTimer()
    }
    
    func foundBeacons() {
        LNBeaconManager.getInstance().WS_GetBeaconsListAPI()
    }
    
    func updateLocation() {
        LNBeaconManager.getInstance().startToUpdateLocation()
    }
    
    func stopRange() {
        LNBeaconManager.getInstance().stopToRange()
    }
    
    func stopTiming() {
        LNBeaconManager.getInstance().stopTimer()
    }
    
    func stopNotificationTimer() {
        LNBeaconManager.getInstance().stopNotificationTimer()
    }
    
    
    func getNotification() {
         LNBeaconManager.getInstance().callNotification()
        delegate?.getNotification?()
    }
}
