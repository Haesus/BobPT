//
//  ViewController.swift
//  BobPT
//
//  Created by 윤해수 on 4/5/24.
//

import Alamofire
import CoreLocation
import NMapsMap
import UIKit
import UniformTypeIdentifiers

class MainViewController: UIViewController {
    // TODO: - 사용자와 매장 사이의 거리 계산하기 위해 필요...
    var latitude: Double?
    var longitude: Double?
    var userLocation: String?
    var selectedFood: [String] = []
    var save: [Root] = []
    var map: [Restaurant]?
    
    var koreaFoodBool = false
    @IBOutlet weak var koreaFoodButtonLabel: UIButton!
    var chinaFoodBool = false
    @IBOutlet weak var chinaFoodButtonLabel: UIButton!
    var japanFoodBool = false
    @IBOutlet weak var japanFoodButtonLabel: UIButton!
    var bunsikFoodBool = false
    @IBOutlet weak var bunsikFoodButtonLabel: UIButton!
    var burgerFoodBool = false
    @IBOutlet weak var burgerFoodButtonLabel: UIButton!
    var noodleFoodBool = false
    @IBOutlet weak var noodleFoodButtonLabel: UIButton!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let target = urlWithFilename("SelectedList.plist", type: .propertyList), let source = Bundle.main.url(forResource: "SelectedList.plist", withExtension: nil) {
            copyFile(target, source)
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        let image = UIImage(named: "noodle")?.resizeImage(size: CGSize(width: 20, height: 20))
        koreaFoodButtonLabel.setImage(image, for: .normal)
    }
    
    @IBAction func koreaFoodButtonAction(_ sender: Any) {
        if koreaFoodBool == false {
            koreaFoodButtonLabel.tintColor = .gray
            koreaFoodBool = true
            selectedFood.append("한식")
        } else {
            koreaFoodButtonLabel.tintColor = .link
            koreaFoodBool = false
            selectedFood = selectedFood.filter{$0 != "한식"}
        }
    }
    
    @IBAction func chinaFoodButtonAction(_ sender: Any) {
        if chinaFoodBool == false {
            chinaFoodButtonLabel.tintColor = .gray
            chinaFoodBool = true
            selectedFood.append("중식")
        } else {
            chinaFoodButtonLabel.tintColor = .link
            chinaFoodBool = false
            selectedFood = selectedFood.filter{$0 != "중식"}
        }
    }
    
    @IBAction func japanFoodButtonAction(_ sender: Any) {
        if japanFoodBool == false {
            japanFoodButtonLabel.tintColor = .gray
            japanFoodBool = true
            selectedFood.append("일식")
        } else {
            japanFoodButtonLabel.tintColor = .link
            japanFoodBool = false
            selectedFood = selectedFood.filter{$0 != "일식"}
        }
    }
    
    @IBAction func bunsikFoodButtonAction(_ sender: Any) {
        if bunsikFoodBool == false {
            bunsikFoodButtonLabel.tintColor = .gray
            bunsikFoodBool = true
            selectedFood.append("분식")
        } else {
            bunsikFoodButtonLabel.tintColor = .link
            bunsikFoodBool = false
            selectedFood = selectedFood.filter{$0 != "분식"}
        }
    }
    
    @IBAction func burgerFoodButtonAction(_ sender: Any) {
        if burgerFoodBool == false {
            burgerFoodButtonLabel.tintColor = .gray
            burgerFoodBool = true
            selectedFood.append("햄버거")
        } else {
            burgerFoodButtonLabel.tintColor = .link
            burgerFoodBool = false
            selectedFood = selectedFood.filter{$0 != "햄버거"}
        }
    }
    
    @IBAction func noodleFoodButtonAction(_ sender: Any) {
        if noodleFoodBool == false {
            noodleFoodButtonLabel.tintColor = .gray
            noodleFoodBool = true
            selectedFood.append("국수")
        } else {
            noodleFoodButtonLabel.tintColor = .link
            noodleFoodBool = false
            selectedFood = selectedFood.filter{$0 != "국수"}
        }
    }
    
    @IBAction func resultViewButtonAction(_ sender: Any) {
        if !koreaFoodBool && !chinaFoodBool && !japanFoodBool && !bunsikFoodBool && !burgerFoodBool && !noodleFoodBool {
            let alert = UIAlertController(title: "하나의 음식이라도 골라주세요.", message: "", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "확인", style: .cancel)
            
            alert.addAction(alertAction)
            present(alert, animated: true)
        }
        
        save = []
        guard let userLocation else {
            return
        }
        let dispatchGroup = DispatchGroup()
        for i in 0..<selectedFood.count {
            dispatchGroup.enter()
            let j = "\(userLocation) \(selectedFood[i])"
            naverSearch(keyword: j) { _ in
                dispatchGroup.leave()
            }
        }
        
        guard let uvc = self.storyboard?.instantiateViewController(identifier: "ResultViewController"), let result = uvc as? ResultViewController else{
            return
        }
        dispatchGroup.notify(queue: .main) {
            result.save = self.save
            self.navigationController?.pushViewController(uvc, animated: true)
        }
    }
}

// MARK: - naverSearch API Function
extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
}
extension MainViewController {
    func calculateDistanceInMeters(fromLatitude lat1: Double, fromLongitude lon1: Double, toLatitude lat2: Double, toLongitude lon2: Double) -> Double {
        let radius: Double = 500
        let earthRadius = 6371.0 // 지구의 반지름 (단위: km)
        let deltaLatitude = (lat2 - lat1).toRadians()
        let deltaLongitude = (lon2 - lon1).toRadians()
        let a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) + cos(lat1.toRadians()) * cos(lat2.toRadians()) * sin(deltaLongitude / 2) * sin(deltaLongitude / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let distance = earthRadius * c * 200 // 거리를 미터로 변환
        let locations: [(mapx: Double, mapy: Double)] = root.items[0].mapx as? Double
        //모델 mapx 접근 찾기
        // 반경 내에 있는 지점들을 저장할 배열
        var nearbyLocations: [(latitude: Double, longitude: Double)] = []
        
        // 현재 위치와 각 지점 간의 거리를 계산하여 반경 내에 있는 지점들을 찾음
        for location in locations {
            let distance = calculateDistanceInMeters(fromLatitude: latitude!, fromLongitude: longitude!, toLatitude: location.mapx, toLongitude: location.mapy)
            if distance <= radius {
                nearbyLocations.append((location.mapx, location.mapy))
            }
        }
        return distance
    }
    func naverSearch(keyword:String, completion: @escaping ([Root]) -> Void) {
        guard let idKey = Bundle.main.idKey, let secretKey = Bundle.main.secretKey else {
            print("API 키를 로드하지 못했습니다.")
            return
        }
        let endPoint = "https://openapi.naver.com/v1/search/local.json?query=\(keyword)&display=5"
        let params: Parameters = ["keyword": keyword]
        let headers: HTTPHeaders = ["X-Naver-Client-Id" : idKey, "X-Naver-Client-Secret" : secretKey]
        let alamo = AF.request(endPoint, method: .get, parameters: params, headers: headers)
        alamo.responseDecodable(of: Root.self) { response in
            print(response)
            switch response.result {
            case .success(let root):
                self.save.append(root)
                print(self.save)
                completion(self.save)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - plist File Copy Function
extension MainViewController {
    func copyFile(_ target: URL, _ source: URL) {
        guard !FileManager.default.fileExists(atPath: target.path()) else {
            print("이미 파일이 해당 위치에 존재합니다. : \(target)")
            return
        }
        try? FileManager.default.copyItem(at: source, to: target)
    }
}

// MARK: - extension CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            return
        }
        locationManager.stopUpdatingLocation()
        // TODO: - 사용자 위치 정보를 통해 추천 매장과의 거리 계산에 필요
        latitude = currentLocation.coordinate.latitude
        longitude = currentLocation.coordinate.longitude
        
        print("위도: \(latitude), 경도: \(longitude)")
        
        CLGeocoder().reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            if let error = error {
                print("지오코딩 에러: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                if let locality = placemark.subLocality {
                    self.userLocation = locality
                    print("현재 위치의 동/면: \(locality)")
                }
            }
        }
    }
}
