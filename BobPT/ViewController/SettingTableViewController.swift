//
//  SettingTableViewController.swift
//  BobPT
//
//  Created by 진웅홍 on 4/11/24.
//

import UIKit

class SettingTableViewController: UITableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        if indexPath.row == 0 {
            
        } else {
            let name = cell.viewWithTag(1) as? UILabel
            name?.text = "개발자 정보"
            let version = cell.viewWithTag(2) as? UILabel
            version?.text = nil
            
            let accessory  = UIImageView(image: UIImage(systemName: "chevron.right"))
            accessory.tintColor = UIColor.black
            cell.accessoryView = accessory
        }
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColorFromHex(hexString: "C6EBC5")
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            if let devViewController = storyboard?.instantiateViewController(withIdentifier: "NextViewController") as? DevViewController {
                navigationController?.pushViewController(devViewController, animated: true)
            }
        }
    }
    
}
