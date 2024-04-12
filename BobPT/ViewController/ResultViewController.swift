//
//  BobPTResultViewController.swift
//  BobPTProjectSearchApi
//
//  Created by 강희창 on 4/6/24.
//

import UIKit
import Alamofire
import CoreLocation

class ResultViewController: UIViewController, CLLocationManagerDelegate {
    
    var save: [Root]?
    var restaurant: Restaurant?
    
    @IBOutlet weak var endLbl: UILabel!
    @IBOutlet weak var restLbl: UILabel!
    @IBOutlet weak var todayLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.todayLbl.text = "오늘의 추천장소는"
        self.endLbl.text = "맛있게 드세요!"
        guard let message = self.save?[0].items.randomElement() else {
            return
        }
        self.restLbl.text = message.title.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
        restaurant = message
        writePlist()
        
       
//        let goLocation = Location(latitude: 37.7749, longitude: -122.4194)
//        fetchLocationsNearby(location: goLocation)
    }
    
    @IBAction func reroleBtn(_ sender: Any) {
        guard let message = self.save?[0].items.randomElement() else {
            return
        }
        self.restLbl.text = message.title.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
        restaurant = message
        writePlist()
    }
    
    @IBAction func mapBtn(_ sender: Any) {
        guard let uvc = self.storyboard?.instantiateViewController(identifier: "MapViewController"), let result = uvc as? MapViewController else{
            return
        }
        
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
            
            arrayPlist.append(restaurantArray)
            
            let plistData = try PropertyListSerialization.data(fromPropertyList: arrayPlist, format: .xml, options: 0)
            try plistData.write(to: url)
        } catch {
            print("Error writing to plist: \(error)")
        }
    }
}
