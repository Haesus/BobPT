//
//  NaverSearchService.swift
//  BobPT
//
//  Created by Codex on 5/19/26.
//

import Alamofire
import Foundation
import BobPTDomain
import Utils

public enum NaverSearchError: LocalizedError, Sendable {
    case missingAPIKey
    case requestFailed

    public var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API 키를 로드하지 못했습니다."
        case .requestFailed:
            return "음식점 검색에 실패했습니다."
        }
    }
}

public struct NaverSearchService: Sendable {
    public init() {}

    public func search(location: String, food: FoodCategory) async throws -> [Restaurant] {
        guard let idKey = Bundle.main.idKey.validAPIKey,
              let secretKey = Bundle.main.secretKey.validAPIKey else {
            throw NaverSearchError.missingAPIKey
        }

        let keyword = "\(location) \(food.rawValue)"
        let endPoint = "https://openapi.naver.com/v1/search/local.json"
        let params: Parameters = [
            "query": keyword,
            "display": 5
        ]
        let headers: HTTPHeaders = [
            "X-Naver-Client-Id": idKey,
            "X-Naver-Client-Secret": secretKey
        ]

        let response: NaverSearchResponse
        do {
            response = try await withCheckedThrowingContinuation { continuation in
                AF.request(endPoint, method: .get, parameters: params, headers: headers)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: NaverSearchResponse.self) { response in
                        NetworkLogger.log(
                            category: "NaverSearchService.search",
                            request: response.request,
                            response: response.response,
                            responseData: response.data,
                            error: response.error
                        )

                        switch response.result {
                        case .success(let response):
                            continuation.resume(returning: response)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
            }
        } catch {
            throw NaverSearchError.requestFailed
        }

        return response.items.map { restaurant in
            Restaurant(
                title: restaurant.title,
                link: restaurant.link,
                category: restaurant.category,
                description: restaurant.description,
                address: restaurant.address,
                mapx: restaurant.mapx,
                mapy: restaurant.mapy,
                imageString: food.imageName
            )
        }
    }
}

private struct NaverSearchResponse: Decodable, Sendable {
    let items: [NaverRestaurant]
}

private struct NaverRestaurant: Decodable, Sendable {
    let title: String
    let link: String
    let category: String
    let description: String
    let address: String
    let mapx: String
    let mapy: String
}

private extension Optional where Wrapped == String {
    var validAPIKey: String? {
        guard let value = self?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty,
              !value.hasPrefix("$(") else {
            return nil
        }

        return value
    }
}
