//
//  FoodCategory.swift
//  BobPT
//
//  Created by Codex on 5/19/26.
//

import Foundation

public enum FoodCategory: String, CaseIterable, Identifiable, Sendable {
    case soup = "찌개"
    case meat = "고기"
    case sushi = "초밥"
    case ramen = "라멘"
    case kimbap = "김밥"
    case burrito = "부리또"
    case pizza = "피자"
    case chicken = "치킨"
    case hamburger = "햄버거"
    case jajangmyeon = "짜장면"
    case jjambbong = "짬뽕"
    case malatang = "마라탕"
    case ricenoodles = "쌀국수"
    case sandwich = "샌드위치"
    case salad = "샐러드"

    public static let allCases: [FoodCategory] = [
        .soup,
        .meat,
        .sushi,
        .ramen,
        .kimbap,
        .burrito,
        .pizza,
        .chicken,
        .hamburger,
        .jajangmyeon,
        .jjambbong,
        .malatang,
        .ricenoodles,
        .sandwich,
        .salad
    ]

    public var id: String { rawValue }

    public var imageName: String {
        switch self {
        case .soup: return "Soup"
        case .meat: return "Meat"
        case .sushi: return "Sushi"
        case .ramen: return "Ramen"
        case .kimbap: return "Kimbap"
        case .burrito: return "Burrito"
        case .pizza: return "Pizza"
        case .chicken: return "Chicken"
        case .hamburger: return "Hamburger"
        case .jajangmyeon: return "Jajangmyeon"
        case .jjambbong: return "Jjambbong"
        case .malatang: return "Malatang"
        case .ricenoodles: return "Ricenoodles"
        case .sandwich: return "Sandwich"
        case .salad: return "Salad"
        }
    }
}

public struct RecommendationResult: Identifiable, Hashable, Sendable {
    public let id = UUID()
    public let restaurants: [Restaurant]
    public let latitude: Double?
    public let longitude: Double?

    public init(restaurants: [Restaurant], latitude: Double?, longitude: Double?) {
        self.restaurants = restaurants
        self.latitude = latitude
        self.longitude = longitude
    }

    public static func == (lhs: RecommendationResult, rhs: RecommendationResult) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct DeveloperProfile: Identifiable, Sendable {
    public let id = UUID()
    public let name: String
    public let githubURL: URL
    public let avatarURL: URL

    public init?(name: String, githubURLString: String, avatarURLString: String) {
        guard let githubURL = URL(string: githubURLString),
              let avatarURL = URL(string: avatarURLString) else {
            return nil
        }

        self.name = name
        self.githubURL = githubURL
        self.avatarURL = avatarURL
    }

    public static let all: [DeveloperProfile] = [
        DeveloperProfile(
            name: "윤해수",
            githubURLString: "https://github.com/Haesus",
            avatarURLString: "https://avatars.githubusercontent.com/u/111691629?v=4"
        ),
        DeveloperProfile(
            name: "강희창",
            githubURLString: "https://github.com/saul1113",
            avatarURLString: "https://avatars.githubusercontent.com/u/163959713?v=4"
        ),
        DeveloperProfile(
            name: "홍진웅",
            githubURLString: "https://github.com/elphabaa",
            avatarURLString: "https://avatars.githubusercontent.com/u/112241396?v=4"
        )
    ].compactMap { $0 }
}
