//
//  SettingsView.swift
//  SettingsFeature
//
//  Created by Codex on 5/19/26.
//

import MessageUI
import AuthenticationServices
import SwiftUI
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKUser
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
    @State private var naverAuthSession: ASWebAuthenticationSession?
    @AppStorage(DesignSystem.AppearanceMode.storageKey) private var appearanceMode = DesignSystem.AppearanceMode.system
    private let webAuthPresentationContextProvider = WebAuthPresentationContextProvider()

    public init(authStore: AuthSessionStore) {
        self.authStore = authStore
    }

    public var body: some View {
        List {
#if DEV
            Section("DEV 진단") {
                devDiagnosticRow(title: "카카오 키 suffix", value: kakaoKeySuffix)
                devDiagnosticRow(title: "카카오 스킴", value: kakaoCallbackScheme)
                devDiagnosticRow(title: "카카오 launch", value: "CustomScheme")
            }
#endif

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

                    Button {
                        handleKakaoSignIn()
                    } label: {
                        Label("카카오로 계속하기", systemImage: "message.fill")
                    }
                    .disabled(isSigningIn)
                    .listRowBackground(DesignSystem.Colors.surface)

                    Button {
                        handleNaverSignIn()
                    } label: {
                        Label("네이버로 계속하기", systemImage: "n.circle.fill")
                    }
                    .disabled(isSigningIn)
                    .listRowBackground(DesignSystem.Colors.surface)

                    Button {
                        handleGoogleSignIn()
                    } label: {
                        Label("Google로 계속하기", systemImage: "g.circle.fill")
                    }
                    .disabled(isSigningIn)
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

#if DEV
            NavigationLink {
                APILogView()
            } label: {
                Text("API 로그")
            }
            .listRowBackground(DesignSystem.Colors.surface)
#endif

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

#if DEV
    private func devDiagnosticRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DesignSystem.Colors.secondaryText)

            Text(value)
                .font(.caption.monospaced())
                .textSelection(.enabled)
                .foregroundStyle(DesignSystem.Colors.text)
        }
        .padding(.vertical, 4)
        .listRowBackground(DesignSystem.Colors.surface)
    }

    private var kakaoKeySuffix: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else {
            return "-"
        }

        return String(key.suffix(6))
    }

    private var kakaoCallbackScheme: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else {
            return "-"
        }

        return "kakao\(key)://oauth"
    }
#endif

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

    private func handleKakaoSignIn() {
        isSigningIn = true

        let isKakaoTalkAvailable = UserApi.isKakaoTalkLoginAvailable()
        NetworkLogger.logEvent(
            category: "SocialAuth",
            title: "Kakao sign-in started",
            metadata: [
                "isKakaoTalkAvailable": String(isKakaoTalkAvailable),
                "bundleId": Bundle.main.bundleIdentifier ?? "-",
                "launchMethod": "CustomScheme"
            ]
        )

        let completion: (OAuthToken?, Error?) -> Void = { oauthToken, error in
            Task { @MainActor in
                if let error {
                    NetworkLogger.logEvent(
                        category: "SocialAuth",
                        title: "Kakao completion error",
                        metadata: [:],
                        error: error
                    )
                    isSigningIn = false
                    alertMessage = error.localizedDescription
                    return
                }

                guard let accessToken = oauthToken?.accessToken else {
                    NetworkLogger.logEvent(
                        category: "SocialAuth",
                        title: "Kakao completion without access token"
                    )
                    isSigningIn = false
                    alertMessage = "카카오 로그인 정보를 확인하지 못했습니다."
                    return
                }

                NetworkLogger.logEvent(
                    category: "SocialAuth",
                    title: "Kakao completion success",
                    metadata: [
                        "accessTokenSuffix": String(accessToken.suffix(6))
                    ]
                )
                await completeSocialSignIn(provider: .kakao, accessToken: accessToken, idToken: nil)
            }
        }

        if isKakaoTalkAvailable {
            UserApi.shared.loginWithKakaoTalk(launchMethod: .CustomScheme, completion: completion)
        } else {
            UserApi.shared.loginWithKakaoAccount(completion: completion)
        }
    }

    private func handleNaverSignIn() {
        guard let clientId = Bundle.main.socialLoginValue(for: "NAVER_LOGIN_CLIENT_ID"),
              let urlScheme = Bundle.main.socialLoginValue(for: "NAVER_LOGIN_URL_SCHEME") else {
            alertMessage = "네이버 로그인 설정이 필요합니다."
            return
        }

        let redirectURI = "\(urlScheme)://oauth"
        let state = UUID().uuidString
        var components = URLComponents(string: "https://nid.naver.com/oauth2.0/authorize")
        components?.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "state", value: state)
        ]

        guard let authURL = components?.url else {
            alertMessage = "네이버 로그인 주소를 만들지 못했습니다."
            return
        }

        isSigningIn = true
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: urlScheme) { callbackURL, error in
            Task { @MainActor in
                naverAuthSession = nil

                if let error {
                    isSigningIn = false
                    alertMessage = error.localizedDescription
                    return
                }

                guard let callbackURL,
                      let callbackComponents = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let authorizationCode = callbackComponents.queryItems?.first(where: { $0.name == "code" })?.value,
                      callbackComponents.queryItems?.first(where: { $0.name == "state" })?.value == state else {
                    isSigningIn = false
                    alertMessage = "네이버 로그인 정보를 확인하지 못했습니다."
                    return
                }

                await completeSocialSignIn(
                    provider: .naver,
                    accessToken: nil,
                    idToken: nil,
                    authorizationCode: authorizationCode,
                    redirectURI: redirectURI
                )
            }
        }

        session.presentationContextProvider = webAuthPresentationContextProvider
        naverAuthSession = session
        session.start()
    }

    private func handleGoogleSignIn() {
        guard let presentingViewController = UIApplication.shared.rootViewController else {
            alertMessage = "로그인 화면을 열 수 없습니다."
            return
        }

        isSigningIn = true
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
            Task { @MainActor in
                if let error {
                    isSigningIn = false
                    alertMessage = error.localizedDescription
                    return
                }

                guard let user = signInResult?.user else {
                    isSigningIn = false
                    alertMessage = "Google 로그인 정보를 확인하지 못했습니다."
                    return
                }

                await completeSocialSignIn(
                    provider: .google,
                    accessToken: user.accessToken.tokenString,
                    idToken: user.idToken?.tokenString,
                    fullName: user.profile?.name,
                    email: user.profile?.email
                )
            }
        }
    }

    private func completeSocialSignIn(
        provider: SocialLoginProvider,
        accessToken: String?,
        idToken: String?,
        authorizationCode: String? = nil,
        redirectURI: String? = nil,
        fullName: String? = nil,
        email: String? = nil
    ) async {
        defer {
            isSigningIn = false
        }

        do {
            try await authStore.signInWithSocial(
                provider: provider,
                accessToken: accessToken,
                idToken: idToken,
                authorizationCode: authorizationCode,
                redirectURI: redirectURI,
                fullName: fullName,
                email: email
            )
            toastMessage = "로그인되었습니다."
        } catch let error as BackendServiceError {
            alertMessage = error.errorDescription ?? "로그인에 실패했습니다."
        } catch {
            alertMessage = "로그인에 실패했습니다."
        }
    }
}

private extension UIApplication {
    var rootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController
    }
}

private final class WebAuthPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.keyWindow ?? ASPresentationAnchor()
    }
}

private extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }
}

private extension Bundle {
    func socialLoginValue(for key: String) -> String? {
        guard let value = object(forInfoDictionaryKey: key) as? String else {
            return nil
        }

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty, !trimmedValue.hasPrefix("$(") else {
            return nil
        }

        return trimmedValue
    }
}

private extension UIViewController {
    var topMostViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.topMostViewController
        }

        if let navigationController = self as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return visibleViewController.topMostViewController
        }

        if let tabBarController = self as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return selectedViewController.topMostViewController
        }

        return self
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

#if DEV
struct APILogView: View {
    @State private var entries: [NetworkLogEntry] = []

    var body: some View {
        List {
            diagnosticsSection

            if entries.isEmpty {
                Text("수집된 API 로그가 없습니다.")
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                    .listRowBackground(DesignSystem.Colors.surface)
            } else {
                ForEach(entries) { entry in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(entry.category)
                            .font(.headline)

                        Text(entry.timestamp.formatted(date: .omitted, time: .standard))
                            .font(.caption)
                            .foregroundStyle(DesignSystem.Colors.secondaryText)

                        logSection(title: "Request", content: requestText(for: entry))
                        logSection(title: "Response", content: responseText(for: entry))

                        if let errorMessage = entry.errorMessage {
                            logSection(title: "Error", content: errorMessage)
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(DesignSystem.Colors.surface)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Colors.background)
        .navigationTitle("API 로그")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let stream = await NetworkLogStore.shared.stream()

            for await nextEntries in stream {
                entries = nextEntries
            }
        }
        .toolbar {
            if !entries.isEmpty {
                Button("삭제") {
                    Task {
                        await NetworkLogStore.shared.clear()
                    }
                }
            }
        }
    }

    private var diagnosticsSection: some View {
        Section("런타임 진단") {
            diagnosticsRow(title: "앱 번들 ID", value: Bundle.main.bundleIdentifier ?? "-")
            diagnosticsRow(title: "카카오 키 suffix", value: kakaoKeySuffix)
            diagnosticsRow(title: "카카오 스킴", value: kakaoCallbackScheme)
            diagnosticsRow(title: "Google Client ID", value: googleClientID)
        }
        .listRowBackground(DesignSystem.Colors.surface)
    }

    @ViewBuilder
    private func logSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DesignSystem.Colors.secondaryText)

            Text(content)
                .font(.caption.monospaced())
                .textSelection(.enabled)
                .foregroundStyle(DesignSystem.Colors.text)
        }
    }

    private func requestText(for entry: NetworkLogEntry) -> String {
        var lines = [
            "\(entry.method) \(entry.url)"
        ]

        if !entry.requestHeaders.isEmpty {
            lines.append("Headers: \(formatted(entry.requestHeaders))")
        }

        if let requestBody = entry.requestBody {
            lines.append("Body:\n\(requestBody)")
        }

        return lines.joined(separator: "\n")
    }

    private func responseText(for entry: NetworkLogEntry) -> String {
        var lines = [
            "Status: \(entry.statusCode.map(String.init) ?? "-")"
        ]

        if !entry.responseHeaders.isEmpty {
            lines.append("Headers: \(formatted(entry.responseHeaders))")
        }

        if let responseBody = entry.responseBody {
            lines.append("Body:\n\(responseBody)")
        }

        return lines.joined(separator: "\n")
    }

    private func formatted(_ dictionary: [String: String]) -> String {
        dictionary
            .sorted { $0.key < $1.key }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
    }

    private func diagnosticsRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DesignSystem.Colors.secondaryText)

            Text(value)
                .font(.caption.monospaced())
                .textSelection(.enabled)
                .foregroundStyle(DesignSystem.Colors.text)
        }
        .padding(.vertical, 4)
    }

    private var kakaoKeySuffix: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else {
            return "-"
        }

        return String(key.suffix(6))
    }

    private var kakaoCallbackScheme: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else {
            return "-"
        }

        return "kakao\(key)://oauth"
    }

    private var googleClientID: String {
        Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String ?? "-"
    }
}
#endif

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
