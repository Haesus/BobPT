//
//  DesignSystem.swift
//  DesignSystem
//
//  Created by Codex on 5/19/26.
//

import SwiftUI
import UIKit

public enum DesignSystem {
    public enum Colors {
        public static let background = Color(light: 0xFFF7ED, dark: 0x15110D)
        public static let surface = Color(light: 0xFFFFFF, dark: 0x211A14)
        public static let primary = Color(light: 0xEA580C, dark: 0xFDBA74)
        public static let accent = Color(light: 0x16A34A, dark: 0x4ADE80)
        public static let text = Color(light: 0x111827, dark: 0xF9FAFB)
        public static let secondaryText = Color(light: 0x78716C, dark: 0xA8A29E)
        public static let border = Color(light: 0xFED7AA, dark: 0x3A2D22)
        public static let selectedSurface = Color(light: 0xFFEDD5, dark: 0x3A2412)
        public static let inputSurface = Color(light: 0xFFFBF5, dark: 0x1B1510)
        public static let arrow = Color(light: 0xA8A29E, dark: 0x78716C)
        public static let primaryText = Color(light: 0xFFFFFF, dark: 0x1C1208)
        public static let shadow = Color.black.opacity(0.14)
    }

    public enum Radius {
        public static let small: CGFloat = 6
        public static let medium: CGFloat = 8
        public static let large: CGFloat = 12
    }
}

private extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traitCollection in
            UIColor(hex: traitCollection.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
