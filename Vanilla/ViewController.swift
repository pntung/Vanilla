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
    
    var polyline: MKPolyline?
    
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.sendLogButton.isHidden = true
        setupMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK: MapView Method
    func setupMapView() {
        self.vanillaMapView.showsUserLocation = true
        self.vanillaMapView.showsCompass = true
        self.vanillaMapView.showsScale = true
        self.vanillaMapView.isZoomEnabled = true
        self.vanillaMapView.delegate = self
        currentLocation()
    }
    
    func currentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            if #available(iOS 11.0, *) {
                locationManager.showsBackgroundLocationIndicator = true
            }
            else {
                
            }
            
            
        }
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        locationManager.startUpdatingLocation()
        LogManager.sharedInstance.saveLogInfo("Start GPS")
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        LogManager.sharedInstance.saveLogInfo("Stop GPS and draw path with co-ordinates")
        drawLine(VanillaDataManager.sharedInstance.getLocationArray())
    }
    
    @IBAction func sendlogButtonPressed(_ sender: Any) {
    }
    
    func drawLine(_ coordinateArr: [CLLocationCoordinate2D]) {
        drawLineSubroutine(coordinateArr)
    }
    
    func drawLineSubroutine(_ coordinateArr: [CLLocationCoordinate2D]) {
        // remove polyline if one exists
        if let polyline = self.polyline {
            self.vanillaMapView.removeOverlay(polyline)
        }
        
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 800, longitudinalMeters: 800)
        self.vanillaMapView.setRegion(coordinateRegion, animated: true)
        
        LogManager.sharedInstance.saveLogCurrentLocation(currentLocation)
        
        // save current location to DB
        let pos = PositionInfo();
        pos.longtitude = currentLocation.longitude
        pos.latititude = currentLocation.latitude
        pos.posTime = NSDate()
        VanillaDataManager.sharedInstance.addNewPosition(pos)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("---------- error: %s", error.localizedDescription)
    }
}

