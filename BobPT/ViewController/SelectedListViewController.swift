//
//  SelectedListViewController.swift
//  BobPT
//
//  Created by 윤해수 on 4/6/24.
//

import UIKit

class SelectedListViewController: UITableViewController {
    var plistArray: [[String: Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 100
        plistArray = readPlist()
    }
}

extension SelectedListViewController {
    func readPlist() -> [[String: Any]] {
        guard let url = urlWithFilename("SelectedList.plist", type: .propertyList) else {
            return []
        }
        do {
            let plistData = try Data(contentsOf: url)
            
            guard let decodedArray = try PropertyListSerialization.propertyList(from: plistData, format: nil) as? [[String: Any]] else {
                return []
            }
            return decodedArray
        } catch {
            print("Error reading plist: \(error)")
            return []
        }
    }
}

extension SelectedListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plistArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        guard let dic = plistArray?[indexPath.row] as? [String: String] else {
            return cell
        }
        
        print("지나간다~")
        let foodNameLabel = cell.viewWithTag(1) as? UILabel
        let dateNameLabel = cell.viewWithTag(2) as? UILabel
        
        foodNameLabel?.text = dic["title"]
        dateNameLabel?.text = dic["date"]
        
        return cell
    }
}
