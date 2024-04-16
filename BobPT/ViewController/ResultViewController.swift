//
//  BobPTResultViewController.swift
//  BobPTProjectSearchApi
//
//  Created by 강희창 on 4/6/24.
//

import UIKit

class ResultViewController: UIViewController {
    
    var save: [Root]?
    var restaurant: Restaurant?
    var latitude: Double?
    var longitude: Double?
    
    @IBOutlet weak var endLbl: UILabel!
    @IBOutlet weak var restLbl: UILabel!
    @IBOutlet weak var todayLbl: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var nextMapViewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.todayLbl.text = "오늘의 추천장소는"
        self.endLbl.text = "맛있게 드세요!"
        makeNoImageButton(buttonName: nextMapViewButton, radius: 10, backgroundUIColorString: "FA7070", foreGroundUIColorString: "FEFDED", titleSize: 30, titleName: "지도로 위치 확인하기")
        nextMapViewButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        nextMapViewButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside])
        
        guard let message = self.save?[0].items.randomElement() else {
            return
        }
        self.restLbl.text = message.title.htmlEscaped
        let image = UIImage(named: message.imageString!)?.resizeImage(size: CGSize(width: 60, height: 50))
        self.foodImage.image = image
        restaurant = message
        writePlist()
        restLbl.adjustsFontSizeToFitWidth = true
    }
    
    @IBAction func mapBtn(_ sender: Any) {
        guard let uvc = self.storyboard?.instantiateViewController(identifier: "MapViewController"), let result = uvc as? MapViewController else{
            return
        }
        result.userLatitude = latitude
        result.userLongitude = longitude
        result.receivedData = restaurant
        self.navigationController?.pushViewController(uvc, animated: true)
    }
}

// MARK: - extension writePlist Function
extension ResultViewController {
    func writePlist() {
        guard let restaurant, let url = urlWithFilename("SelectedList.plist", type: .propertyList) else {
            return
        }
        
        do {
            var arrayPlist: [[String: Any]] = []
            if let existingData = try? Data(contentsOf: url), let decodedArray = try? PropertyListSerialization.propertyList(from: existingData, format: nil) as? [[String: Any]] {
                arrayPlist = decodedArray
            }
            
            var restaurantArray: [String: Any] = [:]
            restaurantArray["title"] = restaurant.title
            restaurantArray["link"] = restaurant.link
            restaurantArray["category"] = restaurant.category
            restaurantArray["description"] = restaurant.description
            restaurantArray["address"] = restaurant.address
            restaurantArray["mapx"] = restaurant.mapx
            restaurantArray["mapy"] = restaurant.mapy
            restaurantArray["date"] = restaurant.date
            restaurantArray["imageString"] = restaurant.imageString
            
            arrayPlist.insert(restaurantArray, at: 0)
            
            let plistData = try PropertyListSerialization.data(fromPropertyList: arrayPlist, format: .xml, options: 0)
            try plistData.write(to: url)
        } catch {
            print("Error writing to plist: \(error)")
        }
    }
}
