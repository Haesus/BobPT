//
//  MapScreen.swift
//  RecommendationFeature
//
//  Created by Codex on 5/19/26.
//

import CoreLocation
import NMapsMap
import SwiftUI
import BobPTDomain
import DesignSystem
import Utils

struct MapScreen: View {
    let restaurant: Restaurant
    let userLatitude: Double?
    let userLongitude: Double?
    @State private var alertMessage: String?

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
                        .foregroundStyle(DesignSystem.Colors.secondaryText)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            if let destinationCoordinate {
                NaverMapView(
                    restaurant: restaurant,
                    destinationCoordinate: destinationCoordinate,
                    userLatitude: userLatitude,
                    userLongitude: userLongitude
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("지도 좌표를 불러오지 못했습니다.")
                    .font(.headline)
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

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
                .buttonStyle(.bobPTPrimary)

                Button {
                    openAppleMap()
                } label: {
                    Text("Apple Map으로 이동")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bobPTSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(DesignSystem.Colors.background.ignoresSafeArea())
        .navigationTitle("지도")
        .navigationBarTitleDisplayMode(.inline)
        .alert("알림", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var destinationCoordinate: CLLocationCoordinate2D? {
        guard let mapX = Double(restaurant.mapx),
              let mapY = Double(restaurant.mapy) else {
            return nil
        }

        let longitude = mapX / 10_000_000
        let latitude = mapY / 10_000_000

        guard (-90...90).contains(latitude),
              (-180...180).contains(longitude),
              latitude != 0,
              longitude != 0 else {
            return nil
        }

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    private func openNaverMap() {
        guard let queryTitle = restaurant.title.htmlEscaped.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
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
        guard let destinationCoordinate else {
            alertMessage = "지도 좌표가 없어 Apple Map을 열 수 없습니다."
            return
        }

        let urlString = "http://maps.apple.com/?ll=\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)&q=\(restaurant.title.htmlEscaped)"

        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else {
            alertMessage = "지도 앱을 열 수 없습니다."
            return
        }

        UIApplication.shared.open(url)
    }
}

struct NaverMapView: UIViewRepresentable {
    let restaurant: Restaurant
    let destinationCoordinate: CLLocationCoordinate2D
    let userLatitude: Double?
    let userLongitude: Double?

    func makeUIView(context: Context) -> NMFMapView {
        NMFMapView(frame: .zero)
    }

    func updateUIView(_ mapView: NMFMapView, context: Context) {
        context.coordinator.update(
            mapView: mapView,
            restaurant: restaurant,
            destinationCoordinate: destinationCoordinate,
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

        func update(
            mapView: NMFMapView,
            restaurant: Restaurant,
            destinationCoordinate: CLLocationCoordinate2D,
            userLatitude: Double?,
            userLongitude: Double?
        ) {
            let destination = NMGLatLng(
                lat: destinationCoordinate.latitude,
                lng: destinationCoordinate.longitude
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
