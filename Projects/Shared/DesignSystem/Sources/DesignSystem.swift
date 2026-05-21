//
//  DesignSystem.swift
//  DesignSystem
//
//  Created by Codex on 5/19/26.
//

import Foundation
import SwiftUI

public enum DesignSystem {
    public enum Colors {
        public static let background = Color(assetName: "BPTBackground")
        public static let surface = Color(assetName: "BPTSurface")
        public static let primary = Color(assetName: "BPTPrimary")
        public static let accent = Color(assetName: "BPTAccent")
        public static let text = Color(assetName: "BPTText")
        public static let secondaryText = Color(assetName: "BPTSecondaryText")
        public static let border = Color(assetName: "BPTBorder")
        public static let selectedSurface = Color(assetName: "BPTSelectedSurface")
        public static let inputSurface = Color(assetName: "BPTInputSurface")
        public static let arrow = Color(assetName: "BPTArrow")
        public static let primaryText = Color(assetName: "BPTPrimaryText")
        public static let shadow = Color.black.opacity(0.14)
    }

    public enum Radius {
        public static let small: CGFloat = 6
        public static let medium: CGFloat = 8
        public static let large: CGFloat = 12
    }
}

private final class DesignSystemBundleToken {}

private extension Color {
    init(assetName: String) {
        self.init(assetName, bundle: .designSystemResources)
    }
}

private extension Bundle {
    static let designSystemResources: Bundle = {
        let candidates = [
            Bundle.main.resourceURL,
            Bundle(for: DesignSystemBundleToken.self).resourceURL,
            Bundle.main.bundleURL
        ]

        for candidate in candidates {
            let bundleURL = candidate?.appendingPathComponent("DesignSystem_DesignSystem.bundle")
            if let bundleURL, let bundle = Bundle(url: bundleURL) {
                return bundle
            }
        }

        return Bundle(for: DesignSystemBundleToken.self)
    }()
}
