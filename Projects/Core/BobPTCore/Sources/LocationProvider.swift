//
//  LocationProvider.swift
//  BobPT
//
//  Created by Codex on 5/19/26.
//

import CoreLocation
import Foundation

@MainActor
public final class LocationProvider: NSObject, ObservableObject {
    @Published public var userLocation = "서초구"
    @Published public var latitude: Double?
    @Published public var longitude: Double?

    private let manager = CLLocationManager()

    public override init() {
        super.init()
        manager.delegate = self
    }

    public func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}

extension LocationProvider: CLLocationManagerDelegate {
    public nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
