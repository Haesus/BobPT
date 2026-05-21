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
    @Published public private(set) var errorMessage: String?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    public override init() {
        super.init()
        manager.delegate = self
    }

    public func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
        case .denied, .restricted:
            errorMessage = "위치 권한이 꺼져 있어 기본 지역으로 추천합니다."
        @unknown default:
            errorMessage = "위치 정보를 확인하지 못해 기본 지역으로 추천합니다."
        }
    }

    public func clearErrorMessage() {
        errorMessage = nil
    }

    private func startUpdatingLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            errorMessage = "위치 서비스가 꺼져 있어 기본 지역으로 추천합니다."
            return
        }

        manager.startUpdatingLocation()
    }
}

extension LocationProvider: CLLocationManagerDelegate {
    public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            Task { @MainActor in
                self.errorMessage = "위치 권한이 꺼져 있어 기본 지역으로 추천합니다."
            }
        case .notDetermined:
            break
        @unknown default:
            Task { @MainActor in
                self.errorMessage = "위치 정보를 확인하지 못해 기본 지역으로 추천합니다."
            }
        }
    }

    public nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            return
        }

        manager.stopUpdatingLocation()

        Task { @MainActor in
            latitude = currentLocation.coordinate.latitude
            longitude = currentLocation.coordinate.longitude
        }

        geocoder.reverseGeocodeLocation(currentLocation) { placemarks, error in
            if error != nil {
                Task { @MainActor in
                    self.errorMessage = "현재 행정동을 찾지 못해 기본 지역으로 추천합니다."
                }
                return
            }

            guard let locationName = placemarks?.first?.subLocality ?? placemarks?.first?.locality else {
                return
            }

            Task { @MainActor in
                self.userLocation = locationName
            }
        }
    }

    public nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()

        Task { @MainActor in
            self.errorMessage = "현재 위치를 가져오지 못해 기본 지역으로 추천합니다."
        }
    }
}
