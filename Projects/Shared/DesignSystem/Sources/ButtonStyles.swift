//
//  ButtonStyles.swift
//  DesignSystem
//
//  Created by Codex on 5/19/26.
//

import SwiftUI

public struct BobPTPrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .heavy))
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .padding(.horizontal, 18)
            .background(DesignSystem.Colors.primary)
            .foregroundStyle(DesignSystem.Colors.primaryText)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous))
            .shadow(color: DesignSystem.Colors.shadow, radius: 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

public struct BobPTSecondaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .padding(.horizontal, 14)
            .background(DesignSystem.Colors.surface)
            .foregroundStyle(DesignSystem.Colors.primary)
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == BobPTPrimaryButtonStyle {
    static var bobPTPrimary: BobPTPrimaryButtonStyle {
        BobPTPrimaryButtonStyle()
    }
}

public extension ButtonStyle where Self == BobPTSecondaryButtonStyle {
    static var bobPTSecondary: BobPTSecondaryButtonStyle {
        BobPTSecondaryButtonStyle()
    }
}
