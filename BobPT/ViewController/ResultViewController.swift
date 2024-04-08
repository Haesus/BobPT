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
    
    var keyword = "강남 중국"
    
    let idKey = "6Omg7wmoaLIDTN99C0Ff"
    let secretKey = "R9vTsglyOb"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        naverSearch(keyword: "강남 중국")
        
        print(food)
        // Do any additional setup after loading the view.
    }
    func naverSearch(keyword:String) {
        let endPoint = "https://openapi.naver.com/v1/search/local.json?query=\(keyword)"
        let params: Parameters = ["keyword": keyword]
        let headers: HTTPHeaders = ["X-Naver-Client-Id" : idKey, "X-Naver-Client-Secret" : secretKey]
       
      
        
        let alamo = AF.request(
            endPoint,
            method: .get,
            parameters: params,
            headers: headers
            )
        alamo.responseDecodable(of: Root.self) { response in
            switch response.result {
            case .success( let root): self.restaurant = root.items
                DispatchQueue.main.async {
                    self.todayLbl.text = "오늘의 추천 식당은"
                    let message = root.items[0].title
                    self.restLbl.text = message                    //음식점 랜덤 출력될 Label
                    self.endLbl.text = "맛있게 드세요"
                }

            case .failure(let error):
                print(error.localizedDescription)
            }
            let randomPlace = keyword.randomElement()   //랜덤출력?
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
        performSegue(withIdentifier: "map", sender: nil)
    }   //식당위치확인 버튼 클릭 후 진웅님 맵뷰로 화면 전환
    
}
