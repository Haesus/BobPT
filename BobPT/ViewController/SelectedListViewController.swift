//
//  SelectedListViewController.swift
//  BobPT
//
//  Created by 윤해수 on 4/6/24.
//

import UIKit

class SelectedListViewController: UITableViewController {
    var plistArray: [[String: Any]]?
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        plistArray = readPlist()
        
        emptyView.isHidden = true
        
        tableView.rowHeight = 100
        self.navigationItem.rightBarButtonItem = editButtonItem
    }
}

// MARK: - plist File Read Function
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
        if plistArray?.count == 0 || plistArray == nil {
            emptyView.isHidden = false
        } else {
            emptyView.isHidden = true
        }
        return plistArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        guard let dic = plistArray?[indexPath.section] as? [String: String] else {
            return cell
        }
        
        let foodNameLabel = cell.viewWithTag(1) as? UILabel
        let dateNameLabel = cell.viewWithTag(2) as? UILabel
        let foodImage = cell.viewWithTag(10) as? UIImageView
        
        foodNameLabel?.text = dic["title"]?.htmlEscaped
        dateNameLabel?.text = dic["date"]?.htmlEscaped
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.cornerRadius = 20
        cell.frame = CGRect(x: 0, y: 0, width: 200, height: 400)
        
        guard let image = dic["imageString"] else {
            return cell
        }
        foodImage?.image = UIImage(named: image)
        
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
            
            plistArray?.remove(at: indexPath.section)
            guard let plistArray else {
                return
            }
            let plistData = try? PropertyListSerialization.data(fromPropertyList: plistArray, format: .xml, options: 0)
            try? plistData?.write(to: url)
            let deleteSection = IndexSet(integer: indexPath.section)
            tableView.deleteSections(deleteSection, with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
}
