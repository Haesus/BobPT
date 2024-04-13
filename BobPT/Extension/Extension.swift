//
//  Extension.swift
//  BobPT
//
//  Created by 윤해수 on 4/8/24.
//

import UIKit
import UniformTypeIdentifiers

// MARK: - Global Function
func dateFormatter() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    let currentDate = dateFormatter.string(from: Date())
    return currentDate
}

// MARK: - extension Bundle
extension Bundle {
    var idKey: String? {
        return infoDictionary?["ID_KEY"] as? String
    }
    
    var secretKey: String? {
        return infoDictionary?["SECRET_KEY"] as? String
    }
}

// MARK: - extension UIImage
extension UIImage {
    func resizeImage(size: CGSize) -> UIImage {
        let originalSize = self.size
        let ratio: CGFloat = {
            return originalSize.width > originalSize.height ? 1 / (size.width / originalSize.width) :
            1 / (size.height / originalSize.height)
        }()
        
        return UIImage(cgImage: self.cgImage!, scale: self.scale * ratio, orientation: self.imageOrientation)
    }
}

// MARK: - extension UIViewController
extension UIViewController {
    func urlWithFilename(_ filename: String, type: UTType) -> URL? {
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docURL.appendingPathComponent(filename, conformingTo: type)
        
        return fileURL
    }
    
    func UIColorFromHex(hexString: String) -> UIColor? {
        var rgbValue: UInt64 = 0
        
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// MARK: - extension UIAlertController
extension UIAlertController {
    public func customViewAlert(_ view: UIView, image: String) {        
        let input = view
        let imageView = UIImageView(image: UIImage(named: image))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        
        input.addSubview(imageView)
        input.addSubview(titleLabel)
        input.addSubview(messageLabel)
        
        titleLabel.text = title
        messageLabel.text = message
        
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        messageLabel.textAlignment = .center
        messageLabel.textColor = .black
        
        self.view.addSubview(input)

        let topMargin: CGFloat = 0
        let leftMargin: CGFloat = 0
        let btnHeight: CGFloat = 40
        let alertWidth = self.view.frame.size.width - (2 * leftMargin)
        
        let viewWidth = (alertWidth / input.frame.width) * input.frame.width
        let viewHeight = (alertWidth / input.frame.width) * input.frame.height
        
        input.frame = CGRect(x: leftMargin, y: topMargin, width: viewWidth, height: viewHeight)
        imageView.frame = CGRect(x: (alertWidth - viewWidth / 3) / 2, y: topMargin + 20, width: viewWidth/3, height: viewHeight/3)
        titleLabel.frame = CGRect(x: leftMargin, y: imageView.frame.maxY + 10, width: alertWidth, height: 50)
        messageLabel.frame = CGRect(x: leftMargin, y: titleLabel.frame.maxY + 10, width: alertWidth, height: 50)
        
        let maskLayer = CAShapeLayer()
        let roundedPath = UIBezierPath(roundedRect: input.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 30, height: 30))
        maskLayer.path = roundedPath.cgPath
        
        input.layer.mask = maskLayer
        
        input.layer.masksToBounds = true
        
        let indicatorConstraint = NSLayoutConstraint(item: self.view as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewHeight + btnHeight + topMargin + leftMargin)
        self.view.addConstraint(indicatorConstraint)
    }
}
