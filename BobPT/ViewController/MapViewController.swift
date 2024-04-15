//
//  MapViewController.swift
//  BobPT
//
//  Created by 윤해수 on 4/6/24.
//

import UIKit
import NMapsMap

class MapViewController: UIViewController {
    
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var button: UIButton!
    var receivedData : Restaurant?
    var userLatitude : Double?
    var userLongitude : Double?
    var userLocation : CLLocation?
    
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var naverBtnOut: UIButton!
    @IBOutlet weak var localAddress: UILabel!
    @IBOutlet weak var bobPTMapView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        restaurantImage.image = UIImage(named: "restaurant")
        locationImage.image = UIImage(named: "location")
        self.button.layer.masksToBounds = true
        self.button.layer.cornerRadius = 10
        if let image = UIImage(named: "Map_Service_Icon") {
            
            let resizedImage = image.resized(to: CGSize(width: 50, height: 50))
            var config = UIButton.Configuration.plain()
            config.image = resizedImage
            config.showsActivityIndicator = false
            button.configuration = config

            button.setImage(resizedImage, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
                    button.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside])
            view.addSubview(button)
            
        }
        guard let uvc = self.storyboard?.instantiateViewController(identifier: "MapViewController"), let mapVC = uvc as? MapViewController else {return}
                
        guard let receivedData else {return}
        let coordinateX = (Double(receivedData.mapx) ?? 0)/10000000
        let coordinateY = (Double(receivedData.mapy) ?? 0)/10000000
        mapViewLoad(x: coordinateY, y: coordinateX)
        let naverBtnOut = UIButton()
        naverBtnOut.addTarget(self, action: #selector(naverAppBtn), for: .touchUpInside)
        self.view.addSubview(naverBtnOut)
    }
    @objc func buttonTouchDown() {
            UIView.animate(withDuration: 0.2) {
                self.button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) // 버튼을 5% 줄임
            }
        }

        @objc func buttonTouchUp() {
            UIView.animate(withDuration: 0.2) {
                self.button.transform = CGAffineTransform.identity // 원래 크기로 복원
            }
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
        
        let userLocation = CLLocation(latitude: userLatitude ?? 37.494529, longitude: userLongitude ?? 127.027562)
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude)
        marker.iconTintColor = .red
        marker.mapView = mapView
        print("User location marker set at \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: latLng)
        mapView.moveCamera(cameraUpdate)
        
        let destinationMarker = NMFMarker(position: latLng)
        destinationMarker.mapView = mapView
        
        let infoWindow = NMFInfoWindow()
        let datasource = NMFInfoWindowDefaultTextSource.data()
        datasource.title = receivedData?.title ?? " "
        infoWindow.open(with: destinationMarker)
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

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

