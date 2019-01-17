//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
import Flutter
import UIKit
import AVFoundation
import Photos
import CoreLocation
import CoreMotion
import Contacts

public class SwiftSimplePermissionsPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    var whenInUse = false
    var result: FlutterResult? = nil
    var locationManager = CLLocationManager()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "simple_permissions", binaryMessenger: registrar.messenger())
        let instance = SwiftSimplePermissionsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        locationManager.delegate = self
        let method = call.method
        let dic = call.arguments as? [String: Any]
        
        switch(method) {
        case "checkPermission":
            if let permission = dic?["permission"] as? String {
                checkPermission(permission, result: result)
            } else {
                result(FlutterError(code: "permission missing", message: nil, details: nil))
            }
            
        case "getPermissionStatus":
            if let permission = dic?["permission"] as? String {
                getPermissionStatus(permission, result: result)
            } else {
                result(FlutterError(code: "permission missing", message: nil, details: nil))
            }
            
        case "requestPermission":
            if let permission = dic?["permission"] as? String {
                requestPermission(permission, result: result)
            } else {
                result(FlutterError(code: "permission missing", message: nil, details: nil))
            }
            
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            
        case "openSettings":
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        result(true)
                    } else {
                        // Fallback on earlier versions
                        result(FlutterMethodNotImplemented)
                    }
                }
            }
            
        default:
            result(FlutterMethodNotImplemented)
            
        }
        
    }
    
    // Request permission
    private func requestPermission(_ permission: String, result: @escaping FlutterResult) {
        switch(permission) {
        case "RECORD_AUDIO":
            requestAudioPermission(result: result)
            
        case "CAMERA":
            requestCameraPermission(result: result)
            
        case "PHOTO_LIBRARY":
            requestPhotoLibraryPermission(result: result)
            
        case "ACCESS_COARSE_LOCATION", "ACCESS_FINE_LOCATION", "WHEN_IN_USE_LOCATION":
            self.result = result
            requestLocationWhenInUsePermission()
            
        case "ALWAYS_LOCATION":
            self.result = result
            requestLocationAlwaysPermission()
            
        case "READ_CONTACTS", "WRITE_CONTACTS":
            requestContactPermission(result: result)
            
        case "READ_SMS":
            result("ready")
            
        case "SEND_SMS":
            result("ready")
        
        case "MOTION_SENSOR":
            self.result = result
            requestMotionPermission()
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Check permissions
    private func checkPermission(_ permission: String, result: @escaping FlutterResult) {
        switch(permission) {
        case "RECORD_AUDIO":
            result(checkAudioPermission())
            
        case "CAMERA":
            result(checkCameraPermission())
            
        case "PHOTO_LIBRARY":
            result(checkPhotoLibraryPermission())
            
        case "ACCESS_COARSE_LOCATION", "ACCESS_FINE_LOCATION", "WHEN_IN_USE_LOCATION":
            result(checkLocationWhenInUsePermission())
            
        case "READ_CONTACTS", "WRITE_CONTACTS":
            result(checkContactPermission())
            
        case "ALWAYS_LOCATION":
            result(checkLocationAlwaysPermission())
          
        case "READ_SMS":
            result(true)
            
        case "SEND_SMS":
            result(true)
            
        case "MOTION_SENSOR":
            result(checkMotionSensorPermission())
            
        default:
            result(FlutterMethodNotImplemented)
            
        }
    }
    
    // Get permissions status
    private func getPermissionStatus (_ permission: String, result: @escaping FlutterResult) {
        switch(permission) {
        case "RECORD_AUDIO":
            result(getAudioPermissionStatus().rawValue)
            
        case "READ_CONTACTS", "WRITE_CONTACTS":
            result(getContactPermissionStatus().rawValue)
            
        case "CAMERA":
            result(getCameraPermissionStatus().rawValue)
            
        case "PHOTO_LIBRARY":
            result(getPhotoLibraryPermissionStatus().rawValue)
            
        case "ACCESS_COARSE_LOCATION", "ACCESS_FINE_LOCATION", "WHEN_IN_USE_LOCATION":
            let status = CLLocationManager.authorizationStatus()
            if (status == .authorizedAlways || status == .authorizedWhenInUse) {
                result(3)
            }
            else {
                result(status.rawValue)
            }
            
        case "ALWAYS_LOCATION":
            let status = CLLocationManager.authorizationStatus()
            if (status == .authorizedAlways) {
                result(3)
            }
            else if (status == .authorizedWhenInUse) {
                result(1)
            }
            else {
                result(status.rawValue)
            }
            
        case "READ_SMS":
            result(1)
            
        case "SEND_SMS":
            result(1)
            
        case "MOTION_SENSOR":
            result(getMotionSensorPermissionStatus())
            
        default:
            result(FlutterMethodNotImplemented)
            
        }
    }
    
    //-----------------------------------------
    // Location
    private func checkLocationAlwaysPermission() -> Bool {
        return CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    private func checkLocationWhenInUsePermission() -> Bool {
        let authStatus = CLLocationManager.authorizationStatus()
        return  authStatus == .authorizedAlways  || authStatus == .authorizedWhenInUse
    }
    
    private func requestLocationWhenInUsePermission() -> Void {
        if (CLLocationManager.authorizationStatus() == .notDetermined) {
            self.whenInUse = true
            locationManager.requestWhenInUseAuthorization()
        }
        else  {
            self.result?(checkLocationWhenInUsePermission())
        }
    }
    
    private func requestLocationAlwaysPermission() -> Void {
        if (CLLocationManager.authorizationStatus() == .notDetermined) {
            self.whenInUse = false
            locationManager.requestAlwaysAuthorization()
        }
        else  {
            self.result?(checkLocationAlwaysPermission())
        }
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        if (whenInUse)  {
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.result?(true)
                
            default:
                self.result?(false)
            }
        }
        else {
            self.result?(status == .authorizedAlways)
        }
    }
    
    //-----------------------------
    // Contact
    
    private func getContactPermissionStatus() -> CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: CNEntityType.contacts)
    }
    
    private func checkContactPermission() -> Bool {
        return getContactPermissionStatus() == .authorized
    }
    
    private func requestContactPermission(result: @escaping FlutterResult) -> Void {
        CNContactStore().requestAccess(for: CNEntityType.contacts) { (access, error) in
            result(access)
        }
    }
    
    //---------------------------------
    // Audio
    private func checkAudioPermission() -> Bool {
        return getAudioPermissionStatus() == .authorized
    }
    
    private func getAudioPermissionStatus() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
    }
    
    private func requestAudioPermission(result: @escaping FlutterResult) -> Void {
        if (AVAudioSession.sharedInstance().responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({granted in
                result(granted)
            })
        }
    }
    
    //-----------------------------------
    // Camera
    private func checkCameraPermission()-> Bool {
        return getCameraPermissionStatus() == .authorized
    }
    
    private func getCameraPermissionStatus() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    }
    
    
    private func requestCameraPermission(result: @escaping FlutterResult) -> Void {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            result(response)
        }
    }
    
    //-----------------------------------
    // Photo Library
    private func checkPhotoLibraryPermission()-> Bool {
        return getPhotoLibraryPermissionStatus() == .authorized
    }
    
    private func getPhotoLibraryPermissionStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    private func requestPhotoLibraryPermission(result: @escaping FlutterResult) {
        PHPhotoLibrary.requestAuthorization { (status) in
            result(status == PHAuthorizationStatus.authorized)
        }
    }
    
    //-----------------------------------
    // Motion
    private func checkMotionSensorPermission() -> Bool {
        return getMotionSensorPermissionStatus() == 3
    }
    
    private func getMotionSensorPermissionStatus() -> Int {
        if #available(iOS 11.0, *) {
            return CMPedometer.authorizationStatus().rawValue
        } else {
            // Fallback on earlier versions
            return CMSensorRecorder.isAuthorizedForRecording() ? 3 : 2
        }
    }
    
    private var pedometer: CMPedometer?
    private func requestMotionPermission() {
        let now = Date()
        if getMotionSensorPermissionStatus() == 0 {
            pedometer = CMPedometer()
            pedometer?.queryPedometerData(from: now, to: now.addingTimeInterval(-1.0)) { [weak self] (data, error) in
                if let error = error as NSError? {
                    if error.code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
                        self?.result?(false)
                    } else {
                        self?.result?(false)
                    }
                } else {
                    self?.result?(true)
                }
                
                self?.pedometer = nil
            }
        } else {
            result?(checkMotionSensorPermission())
        }
    }
}
