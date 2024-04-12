//
//  NextViewController.swift
//  BobPT
//
//  Created by 진웅홍 on 4/11/24.
//

import UIKit
import Kingfisher

class DevViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Table view data source
extension DevViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "developer", for: indexPath)
        let name = cell.viewWithTag(1) as? UILabel
        let github = cell.viewWithTag(2) as? UILabel
        let gitHubImage = cell.viewWithTag(10) as? UIImageView
        gitHubImage?.layer.cornerRadius = 10
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openGithubLink(_:)))
        github?.addGestureRecognizer(tapGesture)
        github?.tag = indexPath.row
        
        github?.textColor = UIColor.blue
        github?.isUserInteractionEnabled = true
        if indexPath.row == 0 {
            gitHubImage?.kf.setImage(with: URL(string: "https://avatars.githubusercontent.com/u/111691629?v=4"))
            name?.text = "윤해수"
            github?.text = "https://github.com/Haesus"
        } else if indexPath.row == 1{
            gitHubImage?.kf.setImage(with: URL(string: "https://avatars.githubusercontent.com/u/163959713?v=4"))
            name?.text = "강희창"
            github?.text = "https://github.com/saul1113"
        } else {
            gitHubImage?.kf.setImage(with: URL(string: "https://avatars.githubusercontent.com/u/112241396?v=4"))
            name?.text = "홍진웅"
            github?.text = "https://github.com/elphabaa"
        }
        
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
    }
}
