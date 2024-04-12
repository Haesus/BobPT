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
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    var soupFoodBool = false
    @IBOutlet weak var soupFoodButtonLabel: UIButton!
    var meatFoodBool = false
    @IBOutlet weak var meatFoodButtonLabel: UIButton!
    var sushiFoodBool = false
    @IBOutlet weak var sushiFoodButtonLabel: UIButton!
    var ramenFoodBool = false
    @IBOutlet weak var ramenFoodButtonLabel: UIButton!
    var kimbapFoodBool = false
    @IBOutlet weak var kimbapFoodButtonLabel: UIButton!
    var burritoFoodBool = false
    @IBOutlet weak var burritoFoodButtonLabel: UIButton!
    var pizzaFoodBool = false
    @IBOutlet weak var pizzaFoodButtonLabel: UIButton!
    var chickenFoodBool = false
    @IBOutlet weak var chickenFoodButtonLabel: UIButton!
    var hamburgerFoodBool = false
    @IBOutlet weak var hamburgerFoodButtonLabel: UIButton!
    var jajangmyeonFoodBool = false
    @IBOutlet weak var jajangmyeonFoodButtonLabel: UIButton!
    var jjambbongFoodBool = false
    @IBOutlet weak var jjambbongFoodButtonLabel: UIButton!
    var malatangFoodBool = false
    @IBOutlet weak var malatangFoodButtonLabel: UIButton!
    var ricenoodlesFoodBool = false
    @IBOutlet weak var ricenoodlesFoodButtonLabel: UIButton!
    var sandwichFoodBool = false
    @IBOutlet weak var sandwichFoodButtonLabel: UIButton!
    var saladFoodBool = false
    @IBOutlet weak var saladFoodButtonLabel: UIButton!
    
    
    @IBOutlet weak var nextViewButton: UIButton!
    @IBOutlet weak var listVIewButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        designButton()
        
        if let target = urlWithFilename("SelectedList.plist", type: .propertyList), let source = Bundle.main.url(forResource: "SelectedList.plist", withExtension: nil) {
            copyFile(target, source)
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    @IBAction func researchLocationButtonAction(_ sender: Any) {
        locationLabel.text = userLocation
    }
    
    @IBAction func soupFoodButtonAction(_ sender: Any) {
        if soupFoodBool == false {
            soupFoodButtonLabel.tintColor = .gray
            soupFoodBool = true
            selectedFood.append("찌개")
        } else {
            soupFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            soupFoodBool = false
            selectedFood = selectedFood.filter{$0 != "찌개"}
        }
    }
    
    @IBAction func meatFoodButtonAction(_ sender: Any) {
        if meatFoodBool == false {
            meatFoodButtonLabel.tintColor = .gray
            meatFoodBool = true
            selectedFood.append("고기")
        } else {
            meatFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            meatFoodBool = false
            selectedFood = selectedFood.filter{$0 != "고기"}
        }
    }
    
    @IBAction func sushiFoodButtonAction(_ sender: Any) {
        if sushiFoodBool == false {
            sushiFoodButtonLabel.tintColor = .gray
            sushiFoodBool = true
            selectedFood.append("초밥")
        } else {
            sushiFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            sushiFoodBool = false
            selectedFood = selectedFood.filter{$0 != "초밥"}
        }
    }
    
    @IBAction func ramenFoodButtonAction(_ sender: Any) {
        if ramenFoodBool == false {
            ramenFoodButtonLabel.tintColor = .gray
            ramenFoodBool = true
            selectedFood.append("라멘")
        } else {
            ramenFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            ramenFoodBool = false
            selectedFood = selectedFood.filter{$0 != "라멘"}
        }
    }
    
    @IBAction func kimbapFoodButtonAction(_ sender: Any) {
        if kimbapFoodBool == false {
            kimbapFoodButtonLabel.tintColor = .gray
            kimbapFoodBool = true
            selectedFood.append("김밥")
        } else {
            kimbapFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            kimbapFoodBool = false
            selectedFood = selectedFood.filter{$0 != "김밥"}
        }
    }
    
    @IBAction func burritoFoodButtonAction(_ sender: Any) {
        if burritoFoodBool == false {
            burritoFoodButtonLabel.tintColor = .gray
            burritoFoodBool = true
            selectedFood.append("부리또")
        } else {
            burritoFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            burritoFoodBool = false
            selectedFood = selectedFood.filter{$0 != "부리또"}
        }
    }
    
    @IBAction func pizzaFoodButtonAction(_ sender: Any) {
        if pizzaFoodBool == false {
            pizzaFoodButtonLabel.tintColor = .gray
            pizzaFoodBool = true
            selectedFood.append("피자")
        } else {
            pizzaFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            pizzaFoodBool = false
            selectedFood = selectedFood.filter{$0 != "피자"}
        }
    }
    
    @IBAction func chickenFoodButtonAction(_ sender: Any) {
        if chickenFoodBool == false {
            chickenFoodButtonLabel.tintColor = .gray
            chickenFoodBool = true
            selectedFood.append("치킨")
        } else {
            chickenFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            chickenFoodBool = false
            selectedFood = selectedFood.filter{$0 != "치킨"}
        }
    }
    
    @IBAction func hamburgerFoodButtonAction(_ sender: Any) {
        if hamburgerFoodBool == false {
            hamburgerFoodButtonLabel.tintColor = .gray
            hamburgerFoodBool = true
            selectedFood.append("햄버거")
        } else {
            hamburgerFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            hamburgerFoodBool = false
            selectedFood = selectedFood.filter{$0 != "햄버거"}
        }
    }
    
    @IBAction func jajangmyeonFoodButtonAction(_ sender: Any) {
        if jajangmyeonFoodBool == false {
            jajangmyeonFoodButtonLabel.tintColor = .gray
            jajangmyeonFoodBool = true
            selectedFood.append("짜장면")
        } else {
            jajangmyeonFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            jajangmyeonFoodBool = false
            selectedFood = selectedFood.filter{$0 != "짜장면"}
        }
    }
    
    @IBAction func jjambbongFoodButtonAction(_ sender: Any) {
        if jjambbongFoodBool == false {
            jjambbongFoodButtonLabel.tintColor = .gray
            jjambbongFoodBool = true
            selectedFood.append("짬뽕")
        } else {
            jjambbongFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            jjambbongFoodBool = false
            selectedFood = selectedFood.filter{$0 != "짬뽕"}
        }
    }
    
    @IBAction func malatangFoodButtonAction(_ sender: Any) {
        if malatangFoodBool == false {
            malatangFoodButtonLabel.tintColor = .gray
            malatangFoodBool = true
            selectedFood.append("마라탕")
        } else {
            malatangFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            malatangFoodBool = false
            selectedFood = selectedFood.filter{$0 != "마라탕"}
        }
    }
    
    @IBAction func ricenoodlesFoodButtonAction(_ sender: Any) {
        if ricenoodlesFoodBool == false {
            ricenoodlesFoodButtonLabel.tintColor = .gray
            ricenoodlesFoodBool = true
            selectedFood.append("쌀국수")
        } else {
            ricenoodlesFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            ricenoodlesFoodBool = false
            selectedFood = selectedFood.filter{$0 != "쌀국수"}
        }
    }
    
    @IBAction func sandwichFoodButtonAction(_ sender: Any) {
        if sandwichFoodBool == false {
            sandwichFoodButtonLabel.tintColor = .gray
            sandwichFoodBool = true
            selectedFood.append("샌드위치")
        } else {
            sandwichFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            sandwichFoodBool = false
            selectedFood = selectedFood.filter{$0 != "샌드위치"}
        }
    }
    
    @IBAction func saladFoodButtonAction(_ sender: Any) {
        if saladFoodBool == false {
            saladFoodButtonLabel.tintColor = .gray
            saladFoodBool = true
            selectedFood.append("샐러드")
        } else {
            saladFoodButtonLabel.tintColor = UIColorFromHex(hexString: "FA7070")
            saladFoodBool = false
            selectedFood = selectedFood.filter{$0 != "샐러드"}
        }
    }
    
    @IBAction func resultViewButtonAction(_ sender: Any) {
        if !soupFoodBool && !meatFoodBool && !sushiFoodBool && !ramenFoodBool && !kimbapFoodBool && !burritoFoodBool && !pizzaFoodBool && !chickenFoodBool && !hamburgerFoodBool && !jajangmyeonFoodBool && !jjambbongFoodBool && !malatangFoodBool && !ricenoodlesFoodBool && !sandwichFoodBool && !saladFoodBool {
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
        var userLocationLatLng = CLLocation(latitude: latitude ?? 37.49457, longitude: longitude ?? 127.0276)
        result.userLocation = userLocationLatLng
        
        dispatchGroup.notify(queue: .main) {
            result.save = self.save
            self.navigationController?.pushViewController(uvc, animated: true)
        }
    }
}

// MARK: - naverSearch API Function
extension MainViewController {
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
                    self.labelDesign(labelName: self.locationLabel, labelString: self.userLocation)
//                    self.locationLabel.text = self.userLocation
                }
            }
        }
    }
}

// MARK: - Design Function
extension MainViewController {
    func labelDesign(labelName: UILabel, labelString: String?) {
        labelName.textColor = .tintColor
        labelName.text = labelString
    }
    
    func buttonShadow(button: UIButton, width: Int, height: Int, opacity: Float, radius: CGFloat) {
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: width, height: height)
        button.layer.shadowOpacity = opacity
        button.layer.shadowRadius = radius
    }
    
    func makeDesignedFoodButton(buttonName: UIButton, imageName: String, titleName: String) {
        let Image = UIImage(named: imageName)?.resizeImage(size: CGSize(width: 60, height: 50))
        buttonName.setImage(Image, for: .normal)
        buttonName.setTitle(titleName, for: .normal)
        var config = UIButton.Configuration.plain()
        config.imagePadding = 5
        config.imagePlacement = .top
        buttonName.configuration = config
        buttonName.tintColor = UIColorFromHex(hexString: "FA7070")
        buttonShadow(button: buttonName, width: 3, height: 2, opacity: 0.5, radius: 4)
    }
    
    func makeNoImageButton(buttonName: UIButton, backgroundUIColorString: String, foreGroundUIColorString: String, titleSize: CGFloat, titleName: String) {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColorFromHex(hexString: backgroundUIColorString)
        config.baseForegroundColor = UIColorFromHex(hexString: foreGroundUIColorString)
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.boldSystemFont(ofSize: titleSize)
        config.attributedTitle = AttributedString(titleName, attributes: titleContainer)
        buttonName.configuration = config
        buttonShadow(button: buttonName, width: 3, height: 2, opacity: 0.5, radius: 4)
    }
    
    func designButton() {
        makeDesignedFoodButton(buttonName: soupFoodButtonLabel, imageName: "Soup", titleName: "찌개")
        makeDesignedFoodButton(buttonName: meatFoodButtonLabel, imageName: "Meat", titleName: "고기")
        makeDesignedFoodButton(buttonName: sushiFoodButtonLabel, imageName: "Sushi", titleName: "초밥")
        
        makeDesignedFoodButton(buttonName: ramenFoodButtonLabel, imageName: "Ramen", titleName: "라멘")
        makeDesignedFoodButton(buttonName: kimbapFoodButtonLabel, imageName: "Kimbap", titleName: "김밥")
        makeDesignedFoodButton(buttonName: burritoFoodButtonLabel, imageName: "Burrito", titleName: "부리또")
        
        makeDesignedFoodButton(buttonName: pizzaFoodButtonLabel, imageName: "Pizza", titleName: "피자")
        makeDesignedFoodButton(buttonName: chickenFoodButtonLabel, imageName: "Chicken", titleName: "치킨")
        makeDesignedFoodButton(buttonName: hamburgerFoodButtonLabel, imageName: "Hamburger", titleName: "햄버거")
        
        makeDesignedFoodButton(buttonName: jajangmyeonFoodButtonLabel, imageName: "Jajangmyeon", titleName: "짜장면")
        makeDesignedFoodButton(buttonName: jjambbongFoodButtonLabel, imageName: "Jjambbong", titleName: "짬뽕")
        makeDesignedFoodButton(buttonName: malatangFoodButtonLabel, imageName: "Malatang", titleName: "마라탕")
        
        makeDesignedFoodButton(buttonName: ricenoodlesFoodButtonLabel, imageName: "Ricenoodles", titleName: "쌀국수")
        makeDesignedFoodButton(buttonName: sandwichFoodButtonLabel, imageName: "Sandwich", titleName: "샌드위치")
        makeDesignedFoodButton(buttonName: saladFoodButtonLabel, imageName: "Salad", titleName: "샐러드")
        
        makeNoImageButton(buttonName: nextViewButton, backgroundUIColorString: "FA7070", foreGroundUIColorString: "FEFDED", titleSize: 30, titleName: "음식점 추천 받기")
        makeNoImageButton(buttonName: listVIewButton, backgroundUIColorString: "A1C398", foreGroundUIColorString: "FEFDED", titleSize: 20, titleName: "추천 받은 리스트")
    }
}
