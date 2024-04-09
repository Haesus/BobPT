//
//  BobPTResultViewController.swift
//  BobPTProjectSearchApi
//
//  Created by 강희창 on 4/6/24.
//

import UIKit
import Alamofire

class ResultViewController: UIViewController {
    @IBOutlet weak var endLbl: UILabel!
    @IBOutlet weak var restLbl: UILabel!
    @IBOutlet weak var todayLbl: UILabel!
    
    var restaurant: Restaurant?
    var save: [Root]?
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func mapBtn(_ sender: Any) {
        guard let uvc = self.storyboard?.instantiateViewController(identifier: "MapViewController"), let result = uvc as? MapViewController else{
            return
        }
        
        result.receivedData = restaurant
        self.navigationController?.pushViewController(uvc, animated: true)
    }
}
