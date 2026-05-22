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
    @Environment(\.colorScheme) private var colorScheme
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

            Section {
                if let user = authStore.session?.user {
                    signedInAccountCard(user)
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                        .listRowBackground(Color.clear)
                } else {
                    signedOutAccountCard
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                        .listRowBackground(Color.clear)
                }
            } header: {
                Text("계정")
            }

            if authStore.isSignedIn {
                Section {
                    ForEach(AuthProvider.allCases) { provider in
                        linkedIdentityRow(provider)
                            .listRowBackground(DesignSystem.Colors.surface)
                    }
                } header: {
                    Text("연결된 로그인")
                } footer: {
                    Text("여러 로그인 수단을 연결해두면 같은 계정으로 계속 사용할 수 있습니다.")
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
        .task(id: authStore.isSignedIn) {
            await refreshLinkedIdentitiesIfNeeded()
        }
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

    private func signedInAccountCard(_ user: AuthUser) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 14) {
                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.14))
                    .frame(width: 54, height: 54)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(DesignSystem.Colors.primary)
                    }

                VStack(alignment: .leading, spacing: 5) {
                    Text(user.displayName ?? user.email ?? "BobPT 사용자")
                        .font(.headline)
                        .foregroundStyle(DesignSystem.Colors.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    if let email = user.email, email != user.displayName {
                        Text(email)
                            .font(.subheadline)
                            .foregroundStyle(DesignSystem.Colors.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                }

                Spacer(minLength: 10)

                statusBadge("로그인됨", systemImage: "checkmark.circle.fill")
            }

            Divider()

            HStack(spacing: 10) {
                Label("추천 기록 동기화 가능", systemImage: "icloud.and.arrow.up")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DesignSystem.Colors.secondaryText)

                Spacer()

                Button(role: .destructive) {
                    authStore.signOut(message: "로그아웃되었습니다.")
                } label: {
                    Text("로그아웃")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderless)
                .disabled(isSigningIn)
            }
        }
        .padding(16)
        .background(DesignSystem.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        }
    }

    private var signedOutAccountCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 7) {
                Text("로그인하고 BobPT를 이어서 사용하세요")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(DesignSystem.Colors.text)

                Text("추천 기록 저장과 계정 연결을 위해 사용하는 로그인 수단을 선택해 주세요.")
                    .font(.subheadline)
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 10) {
                appleSignInRow

                socialSignInButton(
                    provider: .kakao,
                    title: "카카오로 계속하기",
                    background: Color(red: 1.0, green: 0.90, blue: 0.0),
                    foreground: .black
                ) {
                    handleKakaoSignIn()
                }

                socialSignInButton(
                    provider: .naver,
                    title: "네이버로 계속하기",
                    background: Color(red: 0.01, green: 0.78, blue: 0.35),
                    foreground: .white
                ) {
                    handleNaverSignIn()
                }

                socialSignInButton(
                    provider: .google,
                    title: "Google로 계속하기",
                    background: DesignSystem.Colors.surface,
                    foreground: DesignSystem.Colors.text,
                    iconForeground: AuthProvider.google.brandColor,
                    showsBorder: true
                ) {
                    handleGoogleSignIn()
                }
            }

            if isSigningIn {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)

                    Text("로그인 요청을 처리하고 있습니다.")
                        .font(.caption)
                        .foregroundStyle(DesignSystem.Colors.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(DesignSystem.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        }
    }

    private var appleSignInRow: some View {
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
        .frame(height: 50)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous))
    }

    private func socialSignInButton(
        provider: AuthProvider,
        title: String,
        background: Color,
        foreground: Color,
        iconForeground: Color? = nil,
        showsBorder: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                providerIcon(provider, foreground: iconForeground ?? foreground)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.horizontal, 15)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous))
            .overlay {
                if showsBorder {
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous)
                        .stroke(DesignSystem.Colors.border, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isSigningIn)
        .opacity(isSigningIn ? 0.55 : 1)
    }

    private func statusBadge(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.bold))
            .foregroundStyle(DesignSystem.Colors.primary)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(DesignSystem.Colors.primary.opacity(0.12))
            .clipShape(Capsule())
            .lineLimit(1)
    }

    @ViewBuilder
    private func providerIcon(_ provider: AuthProvider, foreground: Color) -> some View {
        switch provider {
        case .apple, .kakao:
            Image(systemName: provider.systemImageName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(foreground)
                .frame(width: 24, height: 24)
        case .naver, .google:
            Text(provider.shortSymbol)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(foreground)
                .frame(width: 24, height: 24)
        }
    }

    @ViewBuilder
    private func linkedIdentityRow(_ provider: AuthProvider) -> some View {
        let isLinked = authStore.linkedIdentities.contains { $0.provider == provider }

        HStack(spacing: 14) {
            providerIcon(provider, foreground: provider.iconForegroundColor(for: colorScheme))
                .frame(width: 36, height: 36)
                .background(provider.iconBackgroundColor(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.small, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(provider.displayName)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(DesignSystem.Colors.text)

                Text(isLinked ? "연결됨" : "연결 안 됨")
                    .font(.caption)
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }

            Spacer()

            if isLinked {
                Button(role: .destructive) {
                    unlinkIdentity(provider)
                } label: {
                    Text("해제")
                        .font(.subheadline.weight(.semibold))
                }
                .disabled(isSigningIn)
                .buttonStyle(.borderless)
            } else if provider == .apple {
                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    handleAppleSignIn(result, mode: .link)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(width: 112, height: 36)
                .disabled(isSigningIn)
            } else {
                Button {
                    linkIdentity(provider)
                } label: {
                    Text("연결")
                        .font(.subheadline.weight(.semibold))
                }
                .disabled(isSigningIn)
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 8)
    }

    private func refreshLinkedIdentitiesIfNeeded() async {
        guard authStore.isSignedIn else {
            return
        }

        do {
            try await authStore.refreshLinkedIdentities()
        } catch let error as BackendServiceError {
            alertMessage = error.errorDescription ?? "연결된 로그인 정보를 불러오지 못했습니다."
        } catch {
            alertMessage = "연결된 로그인 정보를 불러오지 못했습니다."
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>, mode: SocialAuthMode = .signIn) {
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
                    if mode == .signIn {
                        try await authStore.signInWithApple(
                            identityToken: identityToken,
                            fullName: name.isEmpty ? nil : name
                        )
                    } else {
                        try await authStore.linkAppleIdentity(
                            identityToken: identityToken,
                            fullName: name.isEmpty ? nil : name
                        )
                    }
                    toastMessage = mode.successMessage
                } catch let error as BackendServiceError {
                    alertMessage = error.errorDescription ?? mode.failureMessage
                } catch {
                    alertMessage = mode.failureMessage
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

    private func handleKakaoSignIn(mode: SocialAuthMode = .signIn) {
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
                await completeSocialAuthentication(provider: .kakao, accessToken: accessToken, idToken: oauthToken?.idToken, mode: mode)
            }
        }

        if isKakaoTalkAvailable {
            UserApi.shared.loginWithKakaoTalk(launchMethod: .CustomScheme, completion: completion)
        } else {
            UserApi.shared.loginWithKakaoAccount(completion: completion)
        }
    }

    private func handleNaverSignIn(mode: SocialAuthMode = .signIn) {
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

                await completeSocialAuthentication(
                    provider: .naver,
                    accessToken: nil,
                    idToken: nil,
                    authorizationCode: authorizationCode,
                    redirectURI: redirectURI,
                    state: state,
                    mode: mode
                )
            }
        }

        session.presentationContextProvider = webAuthPresentationContextProvider
        naverAuthSession = session
        session.start()
    }

    private func handleGoogleSignIn(mode: SocialAuthMode = .signIn) {
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

                await completeSocialAuthentication(
                    provider: .google,
                    accessToken: user.accessToken.tokenString,
                    idToken: user.idToken?.tokenString,
                    fullName: user.profile?.name,
                    email: user.profile?.email,
                    mode: mode
                )
            }
        }
    }

    private func completeSocialAuthentication(
        provider: SocialLoginProvider,
        accessToken: String?,
        idToken: String?,
        authorizationCode: String? = nil,
        redirectURI: String? = nil,
        state: String? = nil,
        fullName: String? = nil,
        email: String? = nil,
        mode: SocialAuthMode = .signIn
    ) async {
        defer {
            isSigningIn = false
        }

        do {
            if mode == .signIn {
                try await authStore.signInWithSocial(
                    provider: provider,
                    accessToken: accessToken,
                    idToken: idToken,
                    authorizationCode: authorizationCode,
                    redirectURI: redirectURI,
                    state: state,
                    fullName: fullName,
                    email: email
                )
            } else {
                try await authStore.linkSocialIdentity(
                    provider: provider,
                    accessToken: accessToken,
                    idToken: idToken,
                    authorizationCode: authorizationCode,
                    redirectURI: redirectURI,
                    state: state,
                    fullName: fullName,
                    email: email
                )
            }
            toastMessage = mode.successMessage
        } catch let error as BackendServiceError {
            alertMessage = error.errorDescription ?? mode.failureMessage
        } catch {
            alertMessage = mode.failureMessage
        }
    }

    private func linkIdentity(_ provider: AuthProvider) {
        switch provider {
        case .apple:
            return
        case .kakao:
            handleKakaoSignIn(mode: .link)
        case .naver:
            handleNaverSignIn(mode: .link)
        case .google:
            handleGoogleSignIn(mode: .link)
        }
    }

    private func unlinkIdentity(_ provider: AuthProvider) {
        isSigningIn = true
        Task { @MainActor in
            defer {
                isSigningIn = false
            }

            do {
                try await authStore.unlinkSocialIdentity(provider: provider)
                toastMessage = "연결을 해제했습니다."
            } catch let error as BackendServiceError {
                alertMessage = error.errorDescription ?? "연결 해제에 실패했습니다."
            } catch {
                alertMessage = "연결 해제에 실패했습니다."
            }
        }
    }
}

private enum SocialAuthMode {
    case signIn
    case link

    var successMessage: String {
        switch self {
        case .signIn:
            return "로그인되었습니다."
        case .link:
            return "계정을 연결했습니다."
        }
    }

    var failureMessage: String {
        switch self {
        case .signIn:
            return "로그인에 실패했습니다."
        case .link:
            return "계정 연결에 실패했습니다."
        }
    }
}

private extension AuthProvider {
    var systemImageName: String {
        switch self {
        case .apple:
            return "apple.logo"
        case .kakao:
            return "message.fill"
        case .naver:
            return "n.circle.fill"
        case .google:
            return "g.circle.fill"
        }
    }

    var shortSymbol: String {
        switch self {
        case .apple:
            return "A"
        case .kakao:
            return "K"
        case .naver:
            return "N"
        case .google:
            return "G"
        }
    }

    var brandColor: Color {
        switch self {
        case .apple:
            return .black
        case .kakao:
            return .black
        case .naver:
            return Color(red: 0.01, green: 0.78, blue: 0.35)
        case .google:
            return Color(red: 0.26, green: 0.52, blue: 0.96)
        }
    }

    func iconForegroundColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .apple:
            return DesignSystem.Colors.text
        case .kakao:
            return colorScheme == .dark ? Self.kakaoYellow : .black
        case .naver, .google:
            return brandColor
        }
    }

    func iconBackgroundColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .apple:
            return DesignSystem.Colors.text.opacity(colorScheme == .dark ? 0.18 : 0.08)
        case .kakao:
            return iconForegroundColor(for: colorScheme).opacity(colorScheme == .dark ? 0.18 : 0.08)
        case .naver, .google:
            return brandColor.opacity(colorScheme == .dark ? 0.20 : 0.12)
        }
    }

    private static var kakaoYellow: Color {
        Color(red: 1.0, green: 0.90, blue: 0.0)
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
