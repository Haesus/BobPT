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
    
    @IBAction func koreaFoodButtonAction(_ sender: Any) {
        if koreaFoodBool == false {
            koreaFoodButtonLabel.tintColor = .gray
            koreaFoodBool = true
        } else {
            koreaFoodButtonLabel.tintColor = .link
            koreaFoodBool = false
        }
    }
    
    @IBAction func chinaFoodButtonAction(_ sender: Any) {
        if chinaFoodBool == false {
            chinaFoodButtonLabel.tintColor = .gray
            chinaFoodBool = true
        } else {
            chinaFoodButtonLabel.tintColor = .link
            chinaFoodBool = false
        }
    }
    
    @IBAction func japanFoodButtonAction(_ sender: Any) {
        if japanFoodBool == false {
            japanFoodButtonLabel.tintColor = .gray
            japanFoodBool = true
        } else {
            japanFoodButtonLabel.tintColor = .link
            japanFoodBool = false
        }
    }
    
    @IBAction func bunsikFoodButtonAction(_ sender: Any) {
        if bunsikFoodBool == false {
            bunsikFoodButtonLabel.tintColor = .gray
            bunsikFoodBool = true
        } else {
            bunsikFoodButtonLabel.tintColor = .link
            bunsikFoodBool = false
        }
    }
    
    @IBAction func burgerFoodButtonAction(_ sender: Any) {
        if burgerFoodBool == false {
            burgerFoodButtonLabel.tintColor = .gray
            burgerFoodBool = true
        } else {
            burgerFoodButtonLabel.tintColor = .link
            burgerFoodBool = false
        }
    }
    
    @IBAction func noodleFoodButtonAction(_ sender: Any) {
        if noodleFoodBool == false {
            noodleFoodButtonLabel.tintColor = .gray
            noodleFoodBool = true
        } else {
            noodleFoodButtonLabel.tintColor = .link
            noodleFoodBool = false
        }
    }
    
    @IBAction func resultViewButtonAction(_ sender: Any) {
        if !koreaFoodBool && !chinaFoodBool && !japanFoodBool && !bunsikFoodBool && !burgerFoodBool && !noodleFoodBool {
            let alert = UIAlertController(title: "하나의 음식이라도 골라주세요.", message: "", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "확인", style: .cancel)
            
            alert.addAction(alertAction)
            present(alert, animated: true)
        }
        
        guard let uvc = self.storyboard?.instantiateViewController(identifier: "ResultViewController") else{
                    return
                }
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
