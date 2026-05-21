//
//  SettingsView.swift
//  SettingsFeature
//
//  Created by Codex on 5/19/26.
//

import MessageUI
import AuthenticationServices
import SwiftUI
import BobPTCore
import BobPTDomain
import DesignSystem
import FeedbackUI

public struct SettingsView: View {
    @ObservedObject private var authStore: AuthSessionStore
    @State private var showsMailComposer = false
    @State private var opensMailSettingsAlert = false
    @State private var alertMessage: String?
    @State private var toastMessage: String?
    @State private var isSigningIn = false
    @AppStorage(DesignSystem.AppearanceMode.storageKey) private var appearanceMode = DesignSystem.AppearanceMode.system

    public init(authStore: AuthSessionStore) {
        self.authStore = authStore
    }

    public var body: some View {
        List {
            Section("계정") {
                if let user = authStore.session?.user {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.displayName ?? user.email ?? "Apple 계정")
                            .font(.headline)
                        Text("로그인됨")
                            .font(.subheadline)
                            .foregroundStyle(DesignSystem.Colors.secondaryText)
                    }
                    .listRowBackground(DesignSystem.Colors.surface)

                    Button(role: .destructive) {
                        authStore.signOut(message: "로그아웃되었습니다.")
                    } label: {
                        Text("로그아웃")
                    }
                    .listRowBackground(DesignSystem.Colors.surface)
                } else {
                    ZStack {
                        SignInWithAppleButton(.continue) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleSignIn(result)
                        }
                        .signInWithAppleButtonStyle(.black)
                        .opacity(isSigningIn ? 0.35 : 1)
                        .disabled(isSigningIn)

                        if isSigningIn {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .frame(height: 44)
                    .listRowBackground(DesignSystem.Colors.surface)
                }
            }

            Picker("화면 모드", selection: $appearanceMode) {
                ForEach(DesignSystem.AppearanceMode.allCases) { mode in
                    Text(mode.title)
                        .tag(mode)
                }
            }
            .pickerStyle(.menu)
            .listRowBackground(DesignSystem.Colors.surface)

            HStack {
                Text("버전")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }
            .listRowBackground(DesignSystem.Colors.surface)

            NavigationLink {
                DeveloperView()
            } label: {
                Text("개발자 정보")
            }
            .listRowBackground(DesignSystem.Colors.surface)

            Button {
                if MFMailComposeViewController.canSendMail() {
                    showsMailComposer = true
                } else {
                    opensMailSettingsAlert = true
                }
            } label: {
                Text("건의사항")
                    .foregroundStyle(DesignSystem.Colors.text)
            }
            .listRowBackground(DesignSystem.Colors.surface)
        }
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Colors.background)
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showsMailComposer) {
            MailComposeView()
        }
        .bobPTAlert(title: "메일 계정을 설정해주세요", isPresented: $opensMailSettingsAlert)
        .bobPTAlert(message: $alertMessage)
        .bobPTToast(message: $toastMessage)
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let identityToken = String(data: tokenData, encoding: .utf8) else {
                alertMessage = "Apple 로그인 정보를 확인하지 못했습니다."
                return
            }

            let name = PersonNameComponentsFormatter().string(from: credential.fullName ?? PersonNameComponents())
            isSigningIn = true
            Task { @MainActor in
                defer {
                    isSigningIn = false
                }

                do {
                    try await authStore.signInWithApple(
                        identityToken: identityToken,
                        fullName: name.isEmpty ? nil : name
                    )
                    toastMessage = "로그인되었습니다."
                } catch let error as BackendServiceError {
                    alertMessage = error.errorDescription ?? "로그인에 실패했습니다."
                } catch {
                    alertMessage = "로그인에 실패했습니다."
                }
            }
        case .failure(let error):
            if let authorizationError = error as? ASAuthorizationError,
               authorizationError.code == .canceled {
                return
            }

            alertMessage = "Apple 로그인을 완료하지 못했습니다."
        }
    }
}

struct DeveloperView: View {
    var body: some View {
        List(DeveloperProfile.all) { developer in
            HStack(spacing: 14) {
                AsyncImage(url: developer.avatarURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        DesignSystem.Colors.selectedSurface
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(developer.name)
                        .font(.headline)
                    Link(developer.githubURL.absoluteString, destination: developer.githubURL)
                        .font(.subheadline)
                }
            }
            .padding(.vertical, 6)
            .listRowBackground(DesignSystem.Colors.surface)
        }
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Colors.background)
        .navigationTitle("개발자 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = context.coordinator
        mail.setToRecipients(["sea15510@icloud.com"])
        mail.setSubject("앱 건의사항")
        mail.setMessageBody("<p>여기에 건의사항을 입력해 주세요.</p>", isHTML: true)
        return mail
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        private let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            dismiss()
        }
    }
}
