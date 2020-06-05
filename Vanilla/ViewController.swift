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
    
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
            
            locationManager.startUpdatingLocation()
        }
    }

}

//MARK: - CLLocationManagerDelegate Methods
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 800, longitudinalMeters: 800)
        self.vanillaMapView.setRegion(coordinateRegion, animated: true)
        
        //locationManager.stopUpdatingLocation()
        print("--------- Coordinator: %@", currentLocation)
        
        let pos = PositionInfo();
        pos.longtitude = currentLocation.longitude
        pos.latititude = currentLocation.latitude
        pos.posTime = NSDate()
        VanillaDataManager.sharedInstance.addNewPosition(pos)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("---------- error: %s", error.localizedDescription)
    }
}

