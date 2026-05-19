//
//  Extension.swift
//  BobPT
//
//  Created by 윤해수 on 4/8/24.
//

import Foundation

// MARK: - Global Function
func dateFormatter() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    let currentDate = dateFormatter.string(from: Date())
    return currentDate
}

extension String {
    var htmlEscaped: String {
        guard let encodedData = self.data(using: .utf8) else {
            return self
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue]
        
        do {
            let attributed = try NSAttributedString(data: encodedData, options: options, documentAttributes: nil)
            return attributed.string
        } catch {
            return self
        }
    }
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
