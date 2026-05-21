//
//  FeedbackView.swift
//  FeedbackUI
//
//  Created by Codex on 5/21/26.
//

import SwiftUI
import DesignSystem

public extension View {
    func bobPTToast(message: Binding<String?>) -> some View {
        modifier(BobPTToastModifier(message: message))
    }

    func bobPTAlert(
        title: String = "알림",
        message: Binding<String?>,
        buttonTitle: String = "확인"
    ) -> some View {
        modifier(BobPTMessageAlertModifier(title: title, message: message, buttonTitle: buttonTitle))
    }

    func bobPTAlert(
        title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        buttonTitle: String = "확인"
    ) -> some View {
        modifier(BobPTPresentedAlertModifier(
            title: title,
            isPresented: isPresented,
            message: message,
            buttonTitle: buttonTitle
        ))
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

private struct BobPTMessageAlertModifier: ViewModifier {
    let title: String
    @Binding var message: String?
    let buttonTitle: String

    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: Binding(
                get: { message != nil },
                set: { if !$0 { message = nil } }
            )) {
                Button(buttonTitle, role: .cancel) {}
            } message: {
                Text(message ?? "")
            }
    }
}

private struct BobPTPresentedAlertModifier: ViewModifier {
    let title: String
    @Binding var isPresented: Bool
    let message: String?
    let buttonTitle: String

    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented) {
                Button(buttonTitle, role: .cancel) {}
            } message: {
                if let message {
                    Text(message)
                }
            }
    }
}
