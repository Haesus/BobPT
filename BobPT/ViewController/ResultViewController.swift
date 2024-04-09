//
//  BobPTResultViewController.swift
//  BobPTProjectSearchApi
//
//  Created by 강희창 on 4/6/24.
//

import UIKit
import Alamofire

class ResultViewController: UIViewController {
    
    var restaurant: Restaurant?
    var save: [Root]?
    
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
        self.restLbl.text = message.title
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

extension ResultViewController {
    func writePlist() {
        guard let restaurant, let url = urlWithFilename("SelectedList.plist", type: .propertyList) else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let currentDate = dateFormatter.string(from: Date())
        
        do {
            var dictionaryPlist: [String: Any] = [:]
            if let existingData = try? Data(contentsOf: url), let decodedDictionary = try? PropertyListSerialization.propertyList(from: existingData, format: nil) as? [String: Any] {
                dictionaryPlist = decodedDictionary
            }
            var restaurantDictionary: [String: Any] = [:]
            restaurantDictionary["title"] = restaurant.title
            restaurantDictionary["link"] = restaurant.link
            restaurantDictionary["category"] = restaurant.category
            restaurantDictionary["description"] = restaurant.description
            restaurantDictionary["address"] = restaurant.address
            restaurantDictionary["mapx"] = restaurant.mapx
            restaurantDictionary["mapy"] = restaurant.mapy
            
            dictionaryPlist[currentDate] = restaurantDictionary
            
            let plistData = try PropertyListSerialization.data(fromPropertyList: dictionaryPlist, format: .xml, options: 0)
            try plistData.write(to: url)
        } catch {
            print("Error writing to plist: \(error)")
        }
    }
}
