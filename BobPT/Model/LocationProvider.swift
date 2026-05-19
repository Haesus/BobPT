//
//  LocationProvider.swift
//  BobPT
//
//  Created by Codex on 5/19/26.
//

import CoreLocation
import Foundation

@MainActor
final class LocationProvider: NSObject, ObservableObject {
    @Published var userLocation = "서초구"
    @Published var latitude: Double?
    @Published var longitude: Double?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}

extension LocationProvider: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            return
        }

        manager.stopUpdatingLocation()

        Task { @MainActor in
            latitude = currentLocation.coordinate.latitude
            longitude = currentLocation.coordinate.longitude
        }

        CLGeocoder().reverseGeocodeLocation(currentLocation) { placemarks, error in
            if let error {
                print("지오코딩 에러: \(error.localizedDescription)")
                return
            }

            guard let subLocality = placemarks?.first?.subLocality else {
                return
            }

            Task { @MainActor in
                self.userLocation = subLocality
            }
        }
    }
}
