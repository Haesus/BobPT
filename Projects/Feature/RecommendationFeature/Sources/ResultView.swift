//
//  ResultView.swift
//  RecommendationFeature
//
//  Created by Codex on 5/19/26.
//

import SwiftUI
import BobPTCore
import BobPTDomain
import DesignSystem
import Utils

struct ResultView: View {
    let result: RecommendationResult
    @ObservedObject var store: SelectedRestaurantStore
    @ObservedObject var authStore: AuthSessionStore
    @State private var restaurant: Restaurant?
    @State private var toastMessage: String?
    private let backendService = BobPTBackendService()

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 16)

            Text("오늘의 추천장소는")
                .font(.title2.weight(.semibold))
                .foregroundStyle(DesignSystem.Colors.text)

            if let restaurant {
                Image(restaurant.imageString ?? "Default")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 100)

                Text(restaurant.title.htmlEscaped)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.55)
                    .foregroundStyle(DesignSystem.Colors.text)

                Text("맛있게 드세요!")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(DesignSystem.Colors.accent)

                Spacer()

                NavigationLink {
                    MapScreen(
                        restaurant: restaurant,
                        userLatitude: result.latitude,
                        userLongitude: result.longitude
                    )
                } label: {
                    Text("지도로 위치 확인하기")
                }
                .buttonStyle(.bobPTPrimary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background.ignoresSafeArea())
        .navigationTitle("추천 결과")
        .navigationBarTitleDisplayMode(.inline)
        .bobPTToast(message: $toastMessage)
        .onAppear {
            guard restaurant == nil, let selected = result.restaurants.randomElement() else {
                return
            }

            restaurant = selected
            if let accessToken = authStore.accessToken {
                Task {
                    do {
                        try await backendService.saveSelection(selected, accessToken: accessToken)
                    } catch BackendServiceError.unauthorized {
                        await MainActor.run {
                            authStore.signOut(message: "로그인이 만료되어 추천 장소를 기기에 저장했습니다.")
                            store.insert(selected)
                        }
                    } catch {
                        await MainActor.run {
                            store.insert(selected)
                            toastMessage = "서버 저장에 실패해 추천 장소를 기기에 저장했습니다."
                        }
                    }
                }
            } else {
                store.insert(selected)
            }
        }
    }
}
