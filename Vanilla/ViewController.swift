//
//  ViewController.swift
//  Vanilla
//
//  Created by Tung Pham on 6/3/20.
//  Copyright © 2020 Terralogic. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController {
    @IBOutlet weak var vanillaMapView: MKMapView!
    @IBOutlet weak var sendLogButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var tvVersion: UILabel!
    
    var polyline: MKPolyline?
    
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.
        self.sendLogButton.isEnabled = true
        self.startButton.isEnabled = true
        self.stopButton.isEnabled = false
        self.tvVersion.text = self.version()
        setupMapView()
    }
    
    //MARK: MapView Method
    func setupMapView() {
        self.vanillaMapView.showsUserLocation = true
        self.vanillaMapView.showsCompass = true
        self.vanillaMapView.showsScale = true
        self.vanillaMapView.isZoomEnabled = true
        self.vanillaMapView.delegate = self
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        let isBackgroundRefreshEnabled = UIApplication.shared.backgroundRefreshStatus == .available
        LogVC.save("[START EXERCISE] Battery Level = \(UIDevice.current.batteryLevel * 100)% -- BackgrounRefresh enabled = \(isBackgroundRefreshEnabled)", force: true)
        printMemoryUsage()
        
        //clear the map
        self.clearMap()
        
        
        self.startButton.isEnabled = false
        self.stopButton.isEnabled = true
        
        self.startLocationUpdate()
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        let isBackgroundRefreshEnabled = UIApplication.shared.backgroundRefreshStatus == .available
        LogVC.save("[STOP EXERCISE] Battery Level = \(UIDevice.current.batteryLevel * 100)% -- BackgrounRefresh enabled = \(isBackgroundRefreshEnabled)", force: true)
        printMemoryUsage()
        
        self.startButton.isEnabled = true
        self.stopButton.isEnabled = false
        
        self.stopLocationUpdate()
        
        drawLine(VanillaDataManager.shared.getLocationArray())
        
        VanillaDataManager.shared.getPositionsFromDB(at: "[STOP EXERCISE]")
        
        //remove all record in DB when starting new exercise
        VanillaDataManager.shared.removeAllRecord()
    }
    
    func clearMap() {
        // remove polyline if one exists
        if let polyline = self.polyline {
            self.vanillaMapView.removeOverlay(polyline)
        }
    }
    
    @IBAction func sendlogButtonPressed(_ sender: Any) {
        LogVC.uploadLogFile(completion: {
            [weak self] (error, res) in
            guard let self = self else {return}

            let alert = UIAlertController(title: nil, message: "Upload succeeded! Log url is copied to clipboard.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            let pasteBoard = UIPasteboard.general
            pasteBoard.string = res?.url ?? ""
        })
    }
    
    func drawLine(_ coordinateArr: [CLLocationCoordinate2D]) {
        clearMap()
        
        let cordinates = coordinateArr
        
        // create a polyline with all cooridnates
        let mkPolyLine: MKPolyline = MKPolyline(coordinates: cordinates, count: cordinates.count)
        self.vanillaMapView.addOverlay(mkPolyLine)
        self.polyline = mkPolyLine
    }
}

//MARK: - MKMapViewDelegate method
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = UIColor.red
            polylineRenderer.lineWidth = 3
            
            return polylineRenderer
        }
        
        fatalError("Something wrong...")
        //return MKPolylineRenderer()
    }
    
}

//MARK: - CLLocationManagerDelegate Methods
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //setup location manager
        self.setupLocationManager(status:status)
    }
    
    func setupLocationManager(status:CLAuthorizationStatus) {
        
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            if #available(iOS 11.0, *) {
                self.locationManager.showsBackgroundLocationIndicator = true
            }
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.pausesLocationUpdatesAutomatically = false
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.distanceFilter = 10
            self.locationManager.activityType = .fitness
        } else {
            print(">>>>> Location manager is disabled")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 800, longitudinalMeters: 800)
        self.vanillaMapView.setRegion(coordinateRegion, animated: true)
        
        let text = String(format: "curent location with Latitude: %f - Longitude: %f \n", currentLocation.latitude, currentLocation.longitude)
        LogVC.save(text)
        
        // save current location to DB
        let pos = PositionInfo();
        pos.longtitude = currentLocation.longitude
        pos.latititude = currentLocation.latitude
        pos.posTime = NSDate()
        VanillaDataManager.shared.addNewPosition(pos)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        LogVC.save( "Getting location error \(error)", force: true)
        switch error {
        case CLError.Code.denied:
            self.stopLocationUpdate()
            break
        default:
            break
        }
    }
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, // UIApplication.didBecomeActiveNotification for swift 4.2+
            object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillResignActive),
                                               name: UIApplication.willResignActiveNotification, // UIApplication.didBecomeActiveNotification for swift 4.2+
            object: nil)
    }
    
    @objc func appDidBecomeActive(){
        self.showBackgroundLocationIndicator(inBackground: false)
        
        //draw the map when getting back from Background
        drawLine(VanillaDataManager.shared.getLocationArray())
        printMemoryUsage()
    }
    
    @objc func appWillResignActive(){
        self.showBackgroundLocationIndicator(inBackground: true)
        printMemoryUsage()
    }
    
    func startLocationUpdate() {
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdate() {
       self.locationManager.allowsBackgroundLocationUpdates = false
       locationManager.stopUpdatingLocation()
    }
    
    public func showBackgroundLocationIndicator(inBackground:Bool) {
        if #available(iOS 11.0, *) {
            self.locationManager.showsBackgroundLocationIndicator = inBackground
        }
    }
    
    func printMemoryUsage(warning: Bool = false) {
        // The `TASK_VM_INFO_COUNT` and `TASK_VM_INFO_REV1_COUNT` macros are too
        // complex for the Swift C importer, so we have to define them ourselves.
        let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(MemoryLayout.offset(of: \task_vm_info_data_t.min_address)! / MemoryLayout<integer_t>.size)
        var info = task_vm_info_data_t()
        var count = TASK_VM_INFO_COUNT
        let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard
            kr == KERN_SUCCESS,
            count >= TASK_VM_INFO_REV1_COUNT
        else { return }
        
        let value = info.phys_footprint / (1024*1024)
        if (!warning) {
            LogVC.save( ">>>>> Memory used = \(value) MB", force: true)
        } else {
            LogVC.save( ">>>>> Memory warning used = \(value) MB", force: true)
        }
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "Version \(version) (\(build))"
    } 
}

