//
//  MapViewController.swift
//  BobPT
//
//  Created by 윤해수 on 4/6/24.
//

import UIKit
import NMapsMap
class MapViewController: UIViewController {
    
    var receivedData : [String:Any]?//dictionary type로 받을 걸 상정하고 제작함. key:value는 각각 coordinate ->double array, name: 음식점 이름
    
    @IBOutlet weak var localAddress: UILabel!
    @IBOutlet weak var bobPTMapView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let receivedData,
              let coordinate = receivedData["coordinate"] as? [Double] else {return}
        
        let lat: CLLocationDegrees = coordinate[0]
        let lon: CLLocationDegrees = coordinate[1]
        let mapView = NMFMapView(frame: bobPTMapView.bounds)
        bobPTMapView.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: bobPTMapView.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: bobPTMapView.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: bobPTMapView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: bobPTMapView.trailingAnchor)
        ])
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lon))
        mapView.moveCamera(cameraUpdate)
        
        let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: lon))
        marker.mapView = mapView
        
        let infoWindow = NMFInfoWindow()
        let datasource = NMFInfoWindowDefaultTextSource.data()
        guard case datasource.title = receivedData["name"] as? String else {return}
        infoWindow.open(with: marker)
        localAddress.text = receivedData["address"] as? String
        // Do any additional setup after loading the view.
    }
}
