//
//  Extension.swift
//  Utils
//
//  Created by 윤해수 on 4/8/24.
//

import Foundation

// MARK: - Global Function
public func dateFormatter() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    let currentDate = dateFormatter.string(from: Date())
    return currentDate
}

public extension String {
    var htmlEscaped: String {
        self
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}

// MARK: - extension Bundle
public extension Bundle {
    var idKey: String? {
        return infoDictionary?["ID_KEY"] as? String
    }
    
    var secretKey: String? {
        return infoDictionary?["SECRET_KEY"] as? String
    }
}
