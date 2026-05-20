//
//  AppearanceMode.swift
//  DesignSystem
//
//  Created by Codex on 5/19/26.
//

import SwiftUI

public extension DesignSystem {
    enum AppearanceMode: String, CaseIterable, Identifiable {
        case system
        case light
        case dark

        public static let storageKey = "appearanceMode"

        public var id: String {
            rawValue
        }

        public var title: String {
            switch self {
            case .system:
                return "시스템"
            case .light:
                return "라이트"
            case .dark:
                return "다크"
            }
        }

        public var colorScheme: ColorScheme? {
            switch self {
            case .system:
                return nil
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }
    }
}
