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

public extension View {
    func bobPTToast(message: Binding<String?>) -> some View {
        modifier(BobPTToastModifier(message: message))
    }
}

private struct BobPTToastModifier: ViewModifier {
    @Binding var message: String?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let message {
                    Text(message)
                        .font(.system(size: 14, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(DesignSystem.Colors.primaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(DesignSystem.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous))
                        .shadow(color: DesignSystem.Colors.shadow, radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                self.message = nil
                            }
                        }
                }
            }
            .animation(.easeOut(duration: 0.22), value: message)
            .task(id: message) {
                guard message != nil else {
                    return
                }

                try? await Task.sleep(for: .seconds(3))
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.message = nil
                    }
                }
            }
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
