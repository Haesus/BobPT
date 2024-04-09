//
//  Extension.swift
//  BobPT
//
//  Created by 윤해수 on 4/8/24.
//

import UIKit
import UniformTypeIdentifiers

extension Bundle {
    var idKey: String? {
        return infoDictionary?["ID_KEY"] as? String
    }
    
    var secretKey: String? {
        return infoDictionary?["SECRET_KEY"] as? String
    }
}

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

extension UIViewController {
    func urlWithFilename(_ filename: String, type: UTType) -> URL? {
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docURL.appendingPathComponent(filename, conformingTo: type)
        
        return fileURL
    }
}
