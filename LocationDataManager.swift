//
//  LocationDataManager.swift
//  HamGrid
//
//  Created by Steven Anderson on 5/9/23.
//

import Foundation
import CoreLocation
import SwiftUI

class LocationDataManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var location: CLLocation?
    
    var isPaused = false
    var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
            manager.startUpdatingLocation()
            break
            
        case .restricted, .denied:
            authorizationStatus = .restricted
            break
            
        case .notDetermined:
            authorizationStatus = .notDetermined
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isPaused && location != locationManager.location {
            location = locationManager.location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}
