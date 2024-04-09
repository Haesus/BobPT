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
    
    var restaurant = [Restaurant]()
    var save: [Root]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.todayLbl.text = "오늘의 추천장소는"
        self.endLbl.text = "맛있게 드세요!"
        guard let save else {
            return
        }
        guard let message = self.save?[0].items.randomElement() else {
            return
        }
        self.restLbl.text = message.title
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
        let mapPlace = restaurant as? MapViewController
        performSegue(withIdentifier: "map", sender: nil)
    }   //식당위치확인 버튼 클릭 후 진웅님 맵뷰로 화면 전환
    
}
