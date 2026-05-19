//
//  FoodCategory.swift
//  BobPT
//
//  Created by Codex on 5/19/26.
//

import Foundation

enum FoodCategory: String, CaseIterable, Identifiable {
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

    var id: String { rawValue }

    var imageName: String {
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

struct RecommendationResult: Identifiable, Hashable {
    let id = UUID()
    let restaurants: [Restaurant]
    let latitude: Double?
    let longitude: Double?

    static func == (lhs: RecommendationResult, rhs: RecommendationResult) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct DeveloperProfile: Identifiable {
    let id = UUID()
    let name: String
    let githubURL: URL
    let avatarURL: URL

    static let all: [DeveloperProfile] = [
        DeveloperProfile(
            name: "윤해수",
            githubURL: URL(string: "https://github.com/Haesus")!,
            avatarURL: URL(string: "https://avatars.githubusercontent.com/u/111691629?v=4")!
        ),
        DeveloperProfile(
            name: "강희창",
            githubURL: URL(string: "https://github.com/saul1113")!,
            avatarURL: URL(string: "https://avatars.githubusercontent.com/u/163959713?v=4")!
        ),
        DeveloperProfile(
            name: "홍진웅",
            githubURL: URL(string: "https://github.com/elphabaa")!,
            avatarURL: URL(string: "https://avatars.githubusercontent.com/u/112241396?v=4")!
        )
    ]
}
