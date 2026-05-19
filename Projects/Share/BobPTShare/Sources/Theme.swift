//
//  Theme.swift
//  BobPT
//
//  Created by Codex on 5/19/26.
//

import SwiftUI

public enum BobPTTheme {
    public static let background = Color(red: 254 / 255, green: 253 / 255, blue: 237 / 255)
    public static let primary = Color(red: 250 / 255, green: 112 / 255, blue: 112 / 255)
    public static let secondary = Color(red: 198 / 255, green: 235 / 255, blue: 197 / 255)
    public static let text = Color(red: 45 / 255, green: 45 / 255, blue: 45 / 255)
}

public struct PrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 22, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(BobPTTheme.primary)
            .foregroundStyle(BobPTTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: .black.opacity(0.22), radius: 4, x: 3, y: 2)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
