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
        self.navigationItem.rightBarButtonItem = editButtonItem
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let url = urlWithFilename("SelectedList.plist", type: .propertyList) else {
                return
            }
            
            plistArray?.remove(at: indexPath.row)
            guard let plistArray else {
                return
            }
            let plistData = try? PropertyListSerialization.data(fromPropertyList: plistArray, format: .xml, options: 0)
            try? plistData?.write(to: url)
        
                tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
}
