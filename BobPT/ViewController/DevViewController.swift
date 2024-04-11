//
//  NextViewController.swift
//  BobPT
//
//  Created by 진웅홍 on 4/11/24.
//

import UIKit

class DevViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "developer", for: indexPath)
        let name = cell.viewWithTag(1) as? UILabel
        let github = cell.viewWithTag(2) as? UILabel
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openGithubLink(_:)))
        github?.addGestureRecognizer(tapGesture)
        github?.tag = indexPath.row
        
        github?.textColor = UIColor.blue
        github?.isUserInteractionEnabled = true
        if indexPath.row == 0 {
            name?.text = "윤해수"
            github?.text = "https://github.com/Haesus"
        }else if indexPath.row == 1{
            name?.text = "강희창"
            github?.text = "https://github.com/saul1113"
        }else{
            name?.text = "홍진웅"
            github?.text = "https://github.com/elphabaa"
        }
        
        // Configure the cell...
        
        return cell
    }
    @objc func openGithubLink(_ sender: UITapGestureRecognizer) {
        var urlString = ""
        if let tag = sender.view?.tag {
            switch tag {
            case 0:
                urlString = "https://github.com/Haesus"
            case 1:
                urlString = "https://github.com/saul1113"
            default:
                urlString = "https://github.com/elphabaa"
            }
        }
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
        
        /*
         // Override to support conditional editing of the table view.
         override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the specified item to be editable.
         return true
         }
         */
        
        /*
         // Override to support editing the table view.
         override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
         // Delete the row from the data source
         tableView.deleteRows(at: [indexPath], with: .fade)
         } else if editingStyle == .insert {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
         }
         }
         */
        
        /*
         // Override to support rearranging the table view.
         override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
         
         }
         */
        
        /*
         // Override to support conditional rearranging of the table view.
         override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the item to be re-orderable.
         return true
         }
         */
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
}
