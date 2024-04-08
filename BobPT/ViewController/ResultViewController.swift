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
    var food: [String]?
    var keyword = "강남"
    var place: String?
    let idKey = "6Omg7wmoaLIDTN99C0Ff"
    let secretKey = "R9vTsglyOb"
    var save: [Root] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.todayLbl.text = "오늘의 추천장소는"
        self.endLbl.text = "맛있게 드세요!"
        guard let food, let place else { return }
        for i in 0..<food.count {
            let j = "\(place) \(food[i])"
            naverSearch(keyword: j)
        }
        let randomValue = Int.random(in: 0..<save.count)
        let message = save[0].items[randomValue]
        self.restLbl.text = message.title
       
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonaction(_ sender: Any) {
        print(save)
    }
    
    func naverSearch(keyword:String) {
        let endPoint = "https://openapi.naver.com/v1/search/local.json?query=\(keyword)&display=5"
        let params: Parameters = ["keyword": keyword]
        let headers: HTTPHeaders = ["X-Naver-Client-Id" : idKey, "X-Naver-Client-Secret" : secretKey]
        let alamo = AF.request(endPoint, method: .get, parameters: params, headers: headers)
        alamo.responseDecodable(of: Root.self) { response in
            switch response.result {
            case .success(let root):
                self.save.append(root)
//                self.restaurant = root.items
//                
//                let randomPlace = keyword.randomElement()
//                DispatchQueue.main.async {
//                    self.todayLbl.text = "오늘의 추천 식당은"
//                    let message = root.items[0].title
//                    self.restLbl.text = message                    //음식점 랜덤 출력될 Label
//                    self.endLbl.text = "맛있게 드세요"
//                }

            case .failure(let error):
                print(error.localizedDescription)
            }
//            let randomPlace = keyword.randomElement()   //랜덤출력?
        }
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
