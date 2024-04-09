//
//  MapViewController.swift
//  BobPT
//
//  Created by 윤해수 on 4/6/24.
//

import UIKit
import NMapsMap

class MapViewController: UIViewController {
    
    var receivedData : Restaurant?//dictionary type로 받을 걸 상정하고 제작함. key:value는 각각 coordinate ->double array, name: 음식점 이름
    
    @IBOutlet weak var localAddress: UILabel!
    @IBOutlet weak var bobPTMapView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let receivedData else {return}
        let coordinateX = (Double(receivedData.mapx) ?? 0)/10000000
        let coordinateY = (Double(receivedData.mapy) ?? 0)/10000000
        mapViewLoad(x: coordinateX, y: coordinateY)
    }
    
    func mapViewLoad(x:Double, y:Double){
        let latLng = NMGLatLng(lat: x, lng: y)
        
        
        let mapView = NMFMapView(frame: bobPTMapView.bounds)
        bobPTMapView.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: bobPTMapView.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: bobPTMapView.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: bobPTMapView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: bobPTMapView.trailingAnchor)
        ])
        let cameraUpdate = NMFCameraUpdate(scrollTo: latLng)
        mapView.moveCamera(cameraUpdate)
        
        let marker = NMFMarker(position: latLng)
        marker.mapView = mapView
        
        let infoWindow = NMFInfoWindow()
        let datasource = NMFInfoWindowDefaultTextSource.data()
        datasource.title = receivedData?.title ?? " "
        infoWindow.open(with: marker)
        localAddress.text = receivedData?.address
    }
}
