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
        guard let idKey = Bundle.main.idKey,
              let secretKey = Bundle.main.secretKey else {
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

        let root: Root = try await withCheckedThrowingContinuation { continuation in
            AF.request(endPoint, method: .get, parameters: params, headers: headers)
                .responseDecodable(of: Root.self) { response in
                    switch response.result {
                    case .success(let root):
                        continuation.resume(returning: root)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }

        return root.items.map { restaurant in
            Restaurant(
                title: restaurant.title,
                link: restaurant.link,
                category: restaurant.category,
                description: restaurant.description,
                address: restaurant.address,
                mapx: restaurant.mapx,
                mapy: restaurant.mapy,
                date: restaurant.date,
                imageString: food.imageName
            )
        }
    }
}
