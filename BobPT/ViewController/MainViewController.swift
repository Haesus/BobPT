//
//  ViewController.swift
//  BobPT
//
//  Created by 윤해수 on 4/5/24.
//

import UIKit
import NMapsMap
import UniformTypeIdentifiers

class MainViewController: UIViewController {
    
    var selectedFood: [String] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let target = urlWithFilename("SelectedList.plist", type: .propertyList), let source = Bundle.main.url(forResource: "SelectedList.plist", withExtension: nil) {
            copyFile(target, source)
        }
    }
    
//    func selectedCategory(foodCategory: Bool, label: UIButton) {
//        if koreaFoodBool == false {
//            koreaFoodButtonLabel.tintColor = .gray
//            koreaFoodBool = true
//            selectedFood.append("한식")
//        } else {
//            koreaFoodButtonLabel.tintColor = .link
//            koreaFoodBool = false
//            selectedFood = selectedFood.filter{$0 != "한식"}
//        }
//    }
    
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
            selectedFood.append("면류")
        } else {
            noodleFoodButtonLabel.tintColor = .link
            noodleFoodBool = false
            selectedFood = selectedFood.filter{$0 != "면류"}
        }
    }
    
    @IBAction func resultViewButtonAction(_ sender: Any) {
        if !koreaFoodBool && !chinaFoodBool && !japanFoodBool && !bunsikFoodBool && !burgerFoodBool && !noodleFoodBool {
            let alert = UIAlertController(title: "하나의 음식이라도 골라주세요.", message: "", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "확인", style: .cancel)
            
            alert.addAction(alertAction)
            present(alert, animated: true)
        }
        
        print(selectedFood)
        guard let uvc = self.storyboard?.instantiateViewController(identifier: "ResultViewController") else{
                    return
                }
        guard let result = uvc as? ResultViewController else {
            return
        }
        result.food = selectedFood
        self.navigationController?.pushViewController(uvc, animated: true)
    }
}

// MARK: - plist File Copy Function
extension MainViewController {
    func urlWithFilename(_ filename: String, type: UTType) -> URL? {
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docURL.appendingPathComponent(filename, conformingTo: type)
        
        return fileURL
    }
    
    func copyFile(_ target: URL, _ source: URL) {
        guard !FileManager.default.fileExists(atPath: target.path()) else {
            print("이미 파일이 해당 위치에 존재합니다. : \(target)")
            return
        }
        
        try? FileManager.default.copyItem(at: source, to: target)
    }
}

// MARK: - NavigationController
extension MainViewController {
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //
    //    }
}
