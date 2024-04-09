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
        print(save)
        guard let message = self.save?[0].items.randomElement() else {
            return
        }
        self.restLbl.text = message.title
        restaurant = message
        print(restaurant?.mapx)
        print(restaurant?.mapy)
    }
    
    @IBAction func mapBtn(_ sender: Any) {
        guard let uvc = self.storyboard?.instantiateViewController(identifier: "MapViewController"), let result = uvc as? MapViewController else{
            return
        }
        
        result.receivedData = restaurant
        self.navigationController?.pushViewController(uvc, animated: true)
    }
}
