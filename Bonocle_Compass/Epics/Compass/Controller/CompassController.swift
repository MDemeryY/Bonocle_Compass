//
//  CompassController.swift
//  CompassExample
//
//  Created by Mahmoud ELDemery on 01/11/2021.
//

import UIKit
import CoreLocation
import Contacts
import BonocleKit
import CoreBluetooth

class CompassController: UIViewController {

    
    var peripheral: CBPeripheral? = nil
    var currentDirection:String?
    var currentAngle:String?

    // MARK: - Lazy Loading View
    
    private lazy var locationManager : CLLocationManager = CLLocationManager()
    private lazy var currLocation: CLLocation = CLLocation()
    
    private lazy var dScaView: DegreeScaleView = {
        let viewF = CGRect(x: 0, y: 123, width: screenW, height: screenW)
        let scaleV = DegreeScaleView(frame: viewF)
        scaleV.backgroundColor = .white
        return scaleV
    }()
    
    private lazy var geographyInfoView: GeographyInfoView = {
        let geo = GeographyInfoView.loadingGeographyInfoView()
        geo.frame = CGRect(x: 0, y: 617, width: screenW, height: 165)
        return geo
    }()
    
    
    private lazy var headerView: HeaderView = {
        let headerScale = HeaderView.loadingHeaderView()
        headerScale.frame = CGRect(x: 0, y: 0, width: screenW, height: 110)
        return headerScale
    }()
    
    
    
   
    // MARK: - Destroy
    deinit {
        locationManager.stopUpdatingHeading()
        locationManager.delegate = nil
    }
}

//MARK: - View Life Cycle
extension CompassController {
    
    
    override func viewWillAppear(_ animated: Bool) {
        BonocleCommunicationHelper.shared.deviceDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.peripheral = BonocleCommunicationHelper.shared.connectedPeripheral
        Liblouis.loadTable()
        configUI()
        createLocationManager()
    }
}

//MARK: - Configure
extension CompassController {
    
    /// 配置UI界面
    private func configUI() {
        view.backgroundColor = .white
        view.addSubview(headerView)
        view.addSubview(dScaView)
        view.addSubview(geographyInfoView)
    }
    
    private func createLocationManager() {
        
        /**
         *
         * currLocation.coordinate.longitude
         * currLocation.coordinate.latitude
         * currLocation.altitude
         * currLocation.course
         * currLocation.speed
         *  ……
         */
        
        locationManager.delegate = self
        
      
        locationManager.distanceFilter = 0
        
      
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.allowsBackgroundLocationUpdates = true
        
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.headingAvailable() {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            print("")
        }else {
            print("")
        }
    }
    
}

// MARK: - Update location information
extension CompassController {
    
    private func update(_ newHeading: CLHeading) {
        
        let theHeading: CLLocationDirection = newHeading.magneticHeading > 0 ? newHeading.magneticHeading : newHeading.trueHeading
        
        let angle = Int(theHeading)
        
        switch angle {
        case 0:
            geographyInfoView.directionLabel.text = "N"
            currentDirection = "N"
        case 90:
            geographyInfoView.directionLabel.text = "E"
            currentDirection = "E"

        case 180:
            geographyInfoView.directionLabel.text = "S"
            currentDirection = "S"

        case 270:
            geographyInfoView.directionLabel.text = "W"
            currentDirection = "W"

        default:
            break
        }
        
        if angle > 0 && angle < 90 {
            geographyInfoView.directionLabel.text = "NE"
            currentDirection = "NE"

        }else if angle > 90 && angle < 180 {
            geographyInfoView.directionLabel.text = "ES"
            currentDirection = "ES"

        }else if angle > 180 && angle < 270 {
            geographyInfoView.directionLabel.text = "SW"
            currentDirection = "SW"

        }else if angle > 270 {
            geographyInfoView.directionLabel.text = "WN"
            currentDirection = "WN"

        }
    }
    
    ///
    /// - Parameters:
    ///   - heading:
    ///   - orientation:
    /// - Returns: Float
    private func heading(_ heading: Float, fromOrirntation orientation: UIDeviceOrientation) -> Float {
        
        var realHeading: Float = heading
        
        switch orientation {
        case .portrait:
            break
        case .portraitUpsideDown:
            realHeading = heading - 180
        case .landscapeLeft:
            realHeading = heading + 90
        case .landscapeRight:
            realHeading = heading - 90
        default:
            break
        }
        if realHeading > 360 {
            realHeading -= 360
        }else if realHeading < 0.0 {
            realHeading += 366
        }
        return realHeading
    }
}


// MARK: - CLLocationManagerDelegate
extension CompassController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        currLocation = locations.last!
        
        
        let longitudeStr = String(format: "%3.4f", currLocation.coordinate.longitude)
        
        
        let latitudeStr = String(format: "%3.4f", currLocation.coordinate.latitude)
        
       
        let altitudeStr = "\(Int(currLocation.altitude))"
        
        let newLongitudeStr = longitudeStr.DegreeToString(d: Double(longitudeStr)!)
        
        let newlatitudeStr = latitudeStr.DegreeToString(d: Double(latitudeStr)!)
        
        print("：\(newlatitudeStr)")
        print("：\(newLongitudeStr)")
        
        geographyInfoView.latitudeAndLongitudeLabel.text = "LAT \(newlatitudeStr)  LONG \(newLongitudeStr)"
        geographyInfoView.altitudeLabel.text = "\(altitudeStr)"
        
  
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(currLocation) { (placemarks, error) in

            guard let placeM = placemarks else { return }
            guard placeM.count > 0 else { return }
        
            let placemark: CLPlacemark = placeM[0]

            let addressDictionary = placemark.postalAddress

            guard let country = addressDictionary?.country else { return }

            guard let city = addressDictionary?.city else { return }

            guard let subLocality = addressDictionary?.subLocality else { return }

            guard let street = addressDictionary?.street else { return }

            self.geographyInfoView.positionLabel.text = "\(country)\(city) \(subLocality) \(street)"
        }
 
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        /*
            trueHeading
            magneticHeading
         */
    
        let device = UIDevice.current
        
        if newHeading.headingAccuracy > 0 {
            
            let magneticHeading: Float = heading(Float(newHeading.magneticHeading), fromOrirntation: device.orientation)
            
            //let trueHeading: Float = heading(Float(newHeading.trueHeading), fromOrirntation: device.orientation)
         
            let headi: Float = -1.0 * Float.pi * Float(newHeading.magneticHeading) / 180.0
            geographyInfoView.angleLabel.text = "\(Int(magneticHeading))"
            currentAngle = "\(Int(magneticHeading))"
            dScaView.resetDirection(CGFloat(headi))
            
            update(newHeading)
        }
    }
   
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error....\(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
 
        switch status {
        case .notDetermined:
            print("Nor Determined")
        case .restricted:
            print("")
        case .denied:
            if CLLocationManager.locationServicesEnabled() {
                print("Location enabled")
            }else {
                print("")
            }
        case .authorizedAlways:
            print("always alow")
        case .authorizedWhenInUse:
            print("when in use")
        @unknown default:
            fatalError()
        }
    }
    
}
