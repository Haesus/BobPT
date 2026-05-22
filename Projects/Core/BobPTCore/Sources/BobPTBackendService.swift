//
//  BobPTBackendService.swift
//  BobPT
//
//  Created by Codex on 5/21/26.
//

import Alamofire
import Foundation
import BobPTDomain
import Utils

public struct BobPTBackendService: Sendable {
    public init() {}

    public func saveRecommendation(
        restaurants: [Restaurant],
        foodCategories: [FoodCategory],
        location: String,
        latitude: Double?,
        longitude: Double?,
        accessToken: String?
    ) async throws {
        guard let baseURL = Bundle.main.apiBaseURL.validBaseURL else {
            throw BackendServiceError.missingBaseURL
        }

        let endpoint = baseURL.appendingPathComponent("api/recommendations")
        let body = RecommendationSaveRequest(
            location: location,
            foodCategories: foodCategories.map(\.rawValue),
            latitude: latitude,
            longitude: longitude,
            restaurants: restaurants.map { RestaurantPayload(restaurant: $0) }
        )

        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                endpoint,
                method: .post,
                parameters: body,
                encoder: JSONParameterEncoder.default,
                headers: authorizationHeaders(accessToken: accessToken)
            )
                .validate(statusCode: 200..<300)
                .response { response in
                    NetworkLogger.log(
                        category: "BobPTBackendService.saveRecommendation",
                        request: response.request,
                        response: response.response,
                        responseData: response.data,
                        error: response.error
                    )

                    switch response.result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error.backendServiceError(responseData: response.data))
                    }
                }
        }
    }

    public func signInWithApple(identityToken: String, fullName: String?) async throws -> AuthSession {
        guard let baseURL = Bundle.main.apiBaseURL.validBaseURL else {
            throw BackendServiceError.missingBaseURL
        }

        let endpoint = baseURL.appendingPathComponent("api/auth/apple")
        let body = AppleLoginRequest(identityToken: identityToken, fullName: fullName)
        let response: APIResponse<AuthSession> = try await requestDecodable(
            endpoint,
            method: .post,
            parameters: body,
            headers: nil
        )

        return response.data
    }

    public func signInWithSocial(
        provider: SocialLoginProvider,
        accessToken: String?,
        idToken: String?,
        authorizationCode: String? = nil,
        redirectURI: String? = nil,
        state: String? = nil,
        fullName: String? = nil,
        email: String? = nil
    ) async throws -> AuthSession {
        guard let baseURL = Bundle.main.apiBaseURL.validBaseURL else {
            throw BackendServiceError.missingBaseURL
        }

        let endpoint = baseURL.appendingPathComponent("api/auth/\(provider.rawValue)")
        let body = SocialLoginRequest(
            accessToken: accessToken,
            idToken: idToken,
            authorizationCode: authorizationCode,
            redirectURI: redirectURI,
            state: state,
            fullName: fullName,
            email: email
        )
        let response: APIResponse<AuthSession> = try await requestDecodable(
            endpoint,
            method: .post,
            parameters: body,
            headers: nil
        )

        return response.data
    }

    public func fetchLinkedSocialIdentities(accessToken: String) async throws -> [LinkedSocialIdentity] {
        guard let baseURL = Bundle.main.apiBaseURL.validBaseURL else {
            throw BackendServiceError.missingBaseURL
        }

        let endpoint = baseURL.appendingPathComponent("api/auth/identities")
        let response: APIResponse<[LinkedSocialIdentity]> = try await requestDecodable(
            endpoint,
            method: .get,
            parameters: Optional<EmptyRequest>.none,
            headers: authorizationHeaders(accessToken: accessToken)
        )

        return response.data
    }

    public func linkAppleIdentity(identityToken: String, fullName: String?, accessToken: String) async throws -> [LinkedSocialIdentity] {
        guard let baseURL = Bundle.main.apiBaseURL.validBaseURL else {
            throw BackendServiceError.missingBaseURL
        }

        let endpoint = baseURL.appendingPathComponent("api/auth/identities/apple")
        let body = AppleLoginRequest(identityToken: identityToken, fullName: fullName)
        let response: APIResponse<[LinkedSocialIdentity]> = try await requestDecodable(
            endpoint,
            method: .post,
            parameters: body,
            headers: authorizationHeaders(accessToken: accessToken)
        )

        return response.data
    }

    public func linkSocialIdentity(
        provider: SocialLoginProvider,
        accessToken socialAccessToken: String?,
        idToken: String?,
        authorizationCode: String? = nil,
        redirectURI: String? = nil,
        state: String? = nil,
        fullName: String? = nil,
        email: String? = nil,
        currentAccessToken: String
    ) async throws -> [LinkedSocialIdentity] {
        guard let baseURL = Bundle.main.apiBaseURL.validBaseURL else {
            throw BackendServiceError.missingBaseURL
        }

        let endpoint = baseURL.appendingPathComponent("api/auth/identities/\(provider.rawValue)")
        let body = SocialLoginRequest(
            accessToken: socialAccessToken,
            idToken: idToken,
            authorizationCode: authorizationCode,
            redirectURI: redirectURI,
            state: state,
            fullName: fullName,
            email: email
        )
        let response: APIResponse<[LinkedSocialIdentity]> = try await requestDecodable(
            endpoint,
            method: .post,
            parameters: body,
            headers: authorizationHeaders(accessToken: currentAccessToken)
        )

        return response.data
    }

    public func unlinkSocialIdentity(provider: AuthProvider, accessToken: String) async throws -> [LinkedSocialIdentity] {
        guard let baseURL = Bundle.main.apiBaseURL.validBaseURL else {
            throw BackendServiceError.missingBaseURL
        }

        let endpoint = baseURL.appendingPathComponent("api/auth/identities/\(provider.rawValue)")
        let response: APIResponse<[LinkedSocialIdentity]> = try await requestDecodable(
            endpoint,
            method: .delete,
            parameters: Optional<EmptyRequest>.none,
            headers: authorizationHeaders(accessToken: accessToken)
        )

        return response.data
    }

    public func fetchSelections(accessToken: String) async throws -> [SavedRestaurant] {
        guard let baseURL = Bundle.main.apiBaseURL.validBaseURL else {
            throw BackendServiceError.missingBaseURL
        }

        let endpoint = baseURL.appendingPathComponent("api/selections")
        let response: APIResponse<[SelectionResponse]> = try await requestDecodable(
            endpoint,
            method: .get,
            parameters: Optional<EmptyRequest>.none,
            headers: authorizationHeaders(accessToken: accessToken)
        )

        return response.data.map(\.savedRestaurant)
    }

    public func fetchCurrentUser(accessToken: String) async throws -> AuthUser {
        guard let baseURL = Bundle.main.apiBaseURL.validBaseURL else {
            throw BackendServiceError.missingBaseURL
        }

        let endpoint = baseURL.appendingPathComponent("api/auth/me")
        let response: APIResponse<AuthUser> = try await requestDecodable(
            endpoint,
            method: .get,
            parameters: Optional<EmptyRequest>.none,
            headers: authorizationHeaders(accessToken: accessToken)
        )

        return response.data
    }

    public func saveSelection(_ restaurant: Restaurant, accessToken: String) async throws {
        guard let baseURL = Bundle.main.apiBaseURL.validBaseURL else {
            throw BackendServiceError.missingBaseURL
        }

        let endpoint = baseURL.appendingPathComponent("api/selections")
        let body = RestaurantPayload(restaurant: restaurant)

        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                endpoint,
                method: .post,
                parameters: body,
                encoder: JSONParameterEncoder.default,
                headers: authorizationHeaders(accessToken: accessToken)
            )
            .validate(statusCode: 200..<300)
            .response { response in
                NetworkLogger.log(
                    category: "BobPTBackendService.saveSelection",
                    request: response.request,
                    response: response.response,
                    responseData: response.data,
                    error: response.error
                )

                switch response.result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error.backendServiceError(responseData: response.data))
                }
            }
        }
    }

    public func deleteSelection(id: String, accessToken: String) async throws {
        guard let baseURL = Bundle.main.apiBaseURL.validBaseURL else {
            throw BackendServiceError.missingBaseURL
        }

        let endpoint = baseURL.appendingPathComponent("api/selections/\(id)")

        try await withCheckedThrowingContinuation { continuation in
            AF.request(endpoint, method: .delete, headers: authorizationHeaders(accessToken: accessToken))
                .validate(statusCode: 200..<300)
                .response { response in
                    NetworkLogger.log(
                        category: "BobPTBackendService.deleteSelection",
                        request: response.request,
                        response: response.response,
                        responseData: response.data,
                        error: response.error
                    )

                    switch response.result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error.backendServiceError(responseData: response.data))
                    }
                }
        }
    }

    private func requestDecodable<T: Decodable, P: Encodable>(
        _ url: URL,
        method: HTTPMethod,
        parameters: P?,
        headers: HTTPHeaders?
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: method, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: T.self) { response in
                    NetworkLogger.log(
                        category: "BobPTBackendService.\(method.rawValue) \(url.lastPathComponent)",
                        request: response.request,
                        response: response.response,
                        responseData: response.data,
                        error: response.error
                    )

                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        continuation.resume(throwing: error.backendServiceError(responseData: response.data))
                    }
                }
        }
    }
}

public enum BackendServiceError: LocalizedError {
    case missingBaseURL
    case unauthorized
    case forbidden
    case notFound
    case serverUnavailable
    case networkUnavailable
    case invalidResponse
    case message(String)

    public var errorDescription: String? {
        switch self {
        case .missingBaseURL:
            return "API 주소가 설정되어 있지 않습니다."
        case .unauthorized:
            return "로그인이 만료되었습니다."
        case .forbidden:
            return "요청 권한이 없습니다."
        case .notFound:
            return "요청한 정보를 찾지 못했습니다."
        case .serverUnavailable:
            return "서버가 응답하지 않습니다. 잠시 후 다시 시도해주세요."
        case .networkUnavailable:
            return "네트워크 연결을 확인해주세요."
        case .invalidResponse:
            return "서버 응답을 처리하지 못했습니다."
        case .message(let value):
            return value
        }
    }
}

public struct AuthSession: Codable, Sendable {
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: Int
    public let user: AuthUser
}

public struct AuthUser: Codable, Identifiable, Sendable {
    public let id: String
    public let email: String?
    public let displayName: String?
}

public enum SocialLoginProvider: String, CaseIterable, Sendable {
    case kakao
    case naver
    case google
}

public enum AuthProvider: String, CaseIterable, Codable, Identifiable, Sendable {
    case apple
    case kakao
    case naver
    case google

    public var id: String {
        rawValue
    }

    public var displayName: String {
        switch self {
        case .apple:
            return "Apple"
        case .kakao:
            return "카카오"
        case .naver:
            return "네이버"
        case .google:
            return "Google"
        }
    }
}

public struct LinkedSocialIdentity: Codable, Identifiable, Sendable {
    public var id: String {
        provider.rawValue
    }

    public let provider: AuthProvider
    public let email: String?
    public let linkedAt: String
}

public struct SavedRestaurant: Identifiable, Sendable {
    public let id: String
    public let restaurant: Restaurant
}

private struct APIResponse<T: Decodable>: Decodable {
    let data: T
}

private struct APIErrorResponse: Decodable {
    let message: String?
}

private struct EmptyRequest: Encodable {}

private struct AppleLoginRequest: Encodable, Sendable {
    let identityToken: String
    let fullName: String?
}

private struct SocialLoginRequest: Encodable, Sendable {
    let accessToken: String?
    let idToken: String?
    let authorizationCode: String?
    let redirectURI: String?
    let state: String?
    let fullName: String?
    let email: String?
}

private struct RecommendationSaveRequest: Encodable, Sendable {
    let location: String
    let foodCategories: [String]
    let latitude: Double?
    let longitude: Double?
    let restaurants: [RestaurantPayload]
}

private struct RestaurantPayload: Encodable, Sendable {
    let title: String
    let link: String?
    let category: String
    let description: String?
    let address: String
    let mapx: String
    let mapy: String
    let imageName: String?

    init(restaurant: Restaurant) {
        title = restaurant.title
        link = restaurant.link.isEmpty ? nil : restaurant.link
        category = restaurant.category
        description = restaurant.description.isEmpty ? nil : restaurant.description
        address = restaurant.address
        mapx = restaurant.mapx
        mapy = restaurant.mapy
        imageName = restaurant.imageString
    }
}

private struct SelectionResponse: Decodable {
    let id: String
    let title: String
    let link: String?
    let category: String
    let description: String?
    let address: String
    let mapx: String
    let mapy: String
    let imageName: String?
    let selectedAt: String

    var savedRestaurant: SavedRestaurant {
        SavedRestaurant(
            id: id,
            restaurant: Restaurant(
                title: title,
                link: link ?? "",
                category: category,
                description: description ?? "",
                address: address,
                mapx: mapx,
                mapy: mapy,
                date: selectedAt,
                imageString: imageName
            )
        )
    }
}

private func authorizationHeaders(accessToken: String?) -> HTTPHeaders? {
    guard let accessToken, !accessToken.isEmpty else {
        return nil
    }

    return ["Authorization": "Bearer \(accessToken)"]
}

private extension AFError {
    func backendServiceError(responseData: Data?) -> Error {
        if let message = responseData?.loginFailureMessage {
            return BackendServiceError.message(message)
        }

        if let responseCode {
            switch responseCode {
            case 401:
                return BackendServiceError.unauthorized
            case 403:
                return BackendServiceError.forbidden
            case 404:
                return BackendServiceError.notFound
            case 500...599:
                return BackendServiceError.serverUnavailable
            default:
                break
            }
        }

        if case .sessionTaskFailed(let error) = self,
           (error as? URLError) != nil {
            return BackendServiceError.networkUnavailable
        }

        if case .responseSerializationFailed = self {
            return BackendServiceError.invalidResponse
        }

        return self
    }
}

private extension Data {
    var loginFailureMessage: String? {
        guard let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: self),
              let message = errorResponse.message,
              message.contains("로그인에 실패") else {
            return nil
        }

        return message
    }
}

private extension Optional where Wrapped == String {
    var validBaseURL: URL? {
        guard let value = self?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty,
              !value.hasPrefix("$(") else {
            return nil
        }

        return URL(string: value)
    }
}
