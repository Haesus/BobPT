//
//  AuthSessionStore.swift
//  BobPT
//
//  Created by Codex on 5/21/26.
//

import Foundation
import Security

@MainActor
public final class AuthSessionStore: ObservableObject {
    @Published public private(set) var session: AuthSession?
    @Published public var feedbackMessage: String?

    private let backendService: BobPTBackendService
    private let keychain = AuthKeychainStore()

    public var isSignedIn: Bool {
        session != nil
    }

    public var accessToken: String? {
        session?.accessToken
    }

    public init(backendService: BobPTBackendService = BobPTBackendService()) {
        self.backendService = backendService
        session = keychain.load()
    }

    public func validateSession() async {
        guard let accessToken else {
            return
        }

        do {
            let user = try await backendService.fetchCurrentUser(accessToken: accessToken)
            guard let currentSession = session else {
                return
            }

            let updatedSession = AuthSession(
                accessToken: currentSession.accessToken,
                tokenType: currentSession.tokenType,
                expiresIn: currentSession.expiresIn,
                user: user
            )
            session = updatedSession
            keychain.save(updatedSession)
        } catch let error as BackendServiceError {
            handleSessionValidationError(error)
        } catch {
            feedbackMessage = "로그인 상태를 확인하지 못했습니다."
        }
    }

    public func signInWithApple(identityToken: String, fullName: String?) async throws {
        let session = try await backendService.signInWithApple(identityToken: identityToken, fullName: fullName)
        self.session = session
        keychain.save(session)
    }

    public func signOut(message: String? = nil) {
        session = nil
        keychain.delete()
        feedbackMessage = message
    }

    private func handleSessionValidationError(_ error: BackendServiceError) {
        switch error {
        case .unauthorized:
            signOut(message: "로그인이 만료되어 로그아웃되었습니다.")
        case .missingBaseURL:
            feedbackMessage = error.errorDescription
        case .networkUnavailable, .serverUnavailable:
            feedbackMessage = error.errorDescription
        case .forbidden, .notFound, .invalidResponse:
            feedbackMessage = "로그인 상태를 확인하지 못했습니다."
        }
    }
}

private struct AuthKeychainStore {
    private let service = "\(Bundle.main.bundleIdentifier ?? "com.kibwa.BobPT").auth"
    private let account = "session"

    func load() -> AuthSession? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data else {
            return nil
        }

        return try? JSONDecoder().decode(AuthSession.self, from: data)
    }

    func save(_ session: AuthSession) {
        guard let data = try? JSONEncoder().encode(session) else {
            return
        }

        delete()

        var query = baseQuery
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(query as CFDictionary, nil)
    }

    func delete() {
        SecItemDelete(baseQuery as CFDictionary)
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
