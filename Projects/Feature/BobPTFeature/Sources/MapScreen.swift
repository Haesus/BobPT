//
//  MapScreen.swift
//  BobPT
//
//  Created by Codex on 5/19/26.
//

import CoreLocation
import NMapsMap
import SwiftUI
import BobPTDomain
import BobPTShare

struct MapScreen: View {
    let restaurant: Restaurant
    let userLatitude: Double?
    let userLongitude: Double?

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 12) {
                Image("restaurant")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.title.htmlEscaped)
                        .font(.headline)
                        .lineLimit(1)
                    Text(restaurant.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            NaverMapView(
                restaurant: restaurant,
                userLatitude: userLatitude,
                userLongitude: userLongitude
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 12) {
                Button {
                    openNaverMap()
                } label: {
                    HStack {
                        Image("Map_Service_Icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                        Text("네이버 지도로 이동")
                            .font(.headline)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    openAppleMap()
                } label: {
                    Text("Apple Map으로 이동")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(BobPTTheme.background.ignoresSafeArea())
        .navigationTitle("지도")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func openNaverMap() {
        guard let queryTitle = restaurant.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let category = restaurant.category.split(separator: ">").first,
              let queryCategory = String(category).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "nmap://search?query=\(queryTitle),\(queryCategory)&appname=BobPT"),
              let appStoreURL = URL(string: "https://itunes.apple.com/app/id311867728?mt=8") else {
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.open(appStoreURL)
        }
    }

    private func openAppleMap() {
        let coordinateX = (Double(restaurant.mapx) ?? 0) / 10_000_000
        let coordinateY = (Double(restaurant.mapy) ?? 0) / 10_000_000
        let urlString = "http://maps.apple.com/?ll=\(coordinateY),\(coordinateX)&q=\(restaurant.title)"

        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else {
            return
        }

        UIApplication.shared.open(url)
    }
}

struct NaverMapView: UIViewRepresentable {
    let restaurant: Restaurant
    let userLatitude: Double?
    let userLongitude: Double?

    func makeUIView(context: Context) -> NMFMapView {
        NMFMapView(frame: .zero)
    }

    func updateUIView(_ mapView: NMFMapView, context: Context) {
        context.coordinator.update(
            mapView: mapView,
            restaurant: restaurant,
            userLatitude: userLatitude,
            userLongitude: userLongitude
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        private let userMarker = NMFMarker()
        private let destinationMarker = NMFMarker()
        private let infoWindow = NMFInfoWindow()

        func update(mapView: NMFMapView, restaurant: Restaurant, userLatitude: Double?, userLongitude: Double?) {
            let destination = NMGLatLng(
                lat: (Double(restaurant.mapy) ?? 0) / 10_000_000,
                lng: (Double(restaurant.mapx) ?? 0) / 10_000_000
            )
            let userLocation = CLLocation(
                latitude: userLatitude ?? 37.494529,
                longitude: userLongitude ?? 127.027562
            )

            userMarker.position = NMGLatLng(
                lat: userLocation.coordinate.latitude,
                lng: userLocation.coordinate.longitude
            )
            userMarker.iconTintColor = .red
            userMarker.mapView = mapView

            destinationMarker.position = destination
            destinationMarker.mapView = mapView

            let dataSource = NMFInfoWindowDefaultTextSource.data()
            dataSource.title = restaurant.title.htmlEscaped
            infoWindow.dataSource = dataSource
            infoWindow.open(with: destinationMarker)

            mapView.moveCamera(NMFCameraUpdate(scrollTo: destination))
        }
    }
}
