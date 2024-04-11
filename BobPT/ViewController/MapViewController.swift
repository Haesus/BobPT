//
//  MapViewController.swift
//  BobPT
//
//  Created by 윤해수 on 4/6/24.
//

import UIKit
import NMapsMap

class MapViewController: UIViewController {
    
    var receivedData : Restaurant?
    var userLocation : String?
    
    @IBOutlet weak var naverBtnOut: UIButton!
    @IBOutlet weak var localAddress: UILabel!
    @IBOutlet weak var bobPTMapView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let receivedData else {return}
        let coordinateX = (Double(receivedData.mapx) ?? 0)/10000000
        let coordinateY = (Double(receivedData.mapy) ?? 0)/10000000
        mapViewLoad(x: coordinateY, y: coordinateX)
        let naverBtnOut = UIButton()
        naverBtnOut.addTarget(self, action: #selector(naverAppBtn), for: .touchUpInside)
        self.view.addSubview(naverBtnOut)
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
    
    @IBAction func naverAppBtn(_ sender: Any) {
        guard let searchQueryTitle = receivedData?.title,
              let searchQueryCategory = receivedData?.category.split(separator: ">").first,
              let encodedQueryTitle = searchQueryTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedQueryCategory = searchQueryCategory.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "nmap://search?query=\(encodedQueryTitle),\(encodedQueryCategory)&appname=BobPT"),
              let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.open(appStoreURL)
        }
    }
}
