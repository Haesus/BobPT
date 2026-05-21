//
//  MainView.swift
//  RecommendationFeature
//
//  Created by Codex on 5/19/26.
//

import SwiftUI
import BobPTCore
import BobPTDomain
import DesignSystem
import FeedbackUI

public struct MainView: View {
    @StateObject private var locationProvider = LocationProvider()
    @ObservedObject private var selectedStore: SelectedRestaurantStore
    @ObservedObject private var authStore: AuthSessionStore
    @State private var selectedFoods: Set<FoodCategory> = []
    @State private var recommendationResult: RecommendationResult?
    @State private var isSearching = false
    @State private var alertMessage: String?
    @State private var toastMessage: String?
    @State private var showsLaunchAnimation = true
    @State private var launchAnimationDidFinish = false
    @State private var hasRequestedInitialLocation = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)
    private let searchService = NaverSearchService()
    private let backendService = BobPTBackendService()

    public init(selectedStore: SelectedRestaurantStore, authStore: AuthSessionStore) {
        self.selectedStore = selectedStore
        self.authStore = authStore
    }

    public var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    locationHeader
                    foodGrid
                    recommendButton
                }
                .padding(20)
            }
            .navigationTitle("Bob-PT")
            .navigationDestination(isPresented: Binding(
                get: { recommendationResult != nil },
                set: { isActive in
                    if !isActive {
                        recommendationResult = nil
                    }
                }
            )) {
                if let recommendationResult {
                    ResultView(result: recommendationResult, store: selectedStore, authStore: authStore)
                }
            }
            .bobPTAlert(message: $alertMessage)
            .disabled(isSearching)
            .task {
                selectedStore.load()
            }
            .task(id: launchAnimationDidFinish) {
                guard launchAnimationDidFinish, !hasRequestedInitialLocation else {
                    return
                }

                hasRequestedInitialLocation = true
                try? await Task.sleep(for: .milliseconds(350))
                locationProvider.requestLocation()
            }
            .onChange(of: locationProvider.errorMessage) { message in
                guard launchAnimationDidFinish, let message else {
                    return
                }

                toastMessage = message
                locationProvider.clearErrorMessage()
            }
            .bobPTToast(message: $toastMessage)

            if isSearching {
                ProgressView("음식점을 찾는 중")
                    .foregroundStyle(DesignSystem.Colors.text)
                    .padding(20)
                    .background(DesignSystem.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.large, style: .continuous))
            }

            if showsLaunchAnimation {
                LottieLaunchView {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showsLaunchAnimation = false
                    }
                    launchAnimationDidFinish = true
                }
                .ignoresSafeArea()
                .transition(.opacity)
            }
        }
    }

    private var locationHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("현재 위치")
                    .font(.caption)
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                Text(locationProvider.userLocation)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(DesignSystem.Colors.primary)
            }

            Spacer()

            Button {
                locationProvider.requestLocation()
            } label: {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(DesignSystem.Colors.selectedSurface)
                    .foregroundStyle(DesignSystem.Colors.accent)
                    .clipShape(Circle())
            }
            .accessibilityLabel("위치 다시 가져오기")
        }
    }

    private var foodGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(FoodCategory.allCases) { food in
                FoodButton(food: food, isSelected: selectedFoods.contains(food)) {
                    if selectedFoods.contains(food) {
                        selectedFoods.remove(food)
                    } else {
                        selectedFoods.insert(food)
                    }
                }
            }
        }
    }

    private var recommendButton: some View {
        Button {
            Task {
                await recommendRestaurants()
            }
        } label: {
            Text(isSearching ? "추천 준비 중" : "음식점 추천 받기")
        }
        .buttonStyle(.bobPTPrimary)
        .disabled(isSearching)
    }

    private func recommendRestaurants() async {
        if selectedFoods.count > 10 {
            alertMessage = "선택된 메뉴가 너무 많습니다. 10개 이하를 골라주세요."
            return
        }

        if selectedFoods.isEmpty {
            alertMessage = "메뉴를 한가지 이상 선택해주세요. 밥피티가 맛있는 집을 추천해드립니다."
            return
        }

        isSearching = true
        defer { isSearching = false }

        do {
            var restaurants: [Restaurant] = []
            let locationName = locationProvider.userLocation
            try await withThrowingTaskGroup(of: [Restaurant].self) { group in
                for food in selectedFoods {
                    group.addTask {
                        try await searchService.search(location: locationName, food: food)
                    }
                }

                for try await result in group {
                    restaurants.append(contentsOf: result)
                }
            }

            guard !restaurants.isEmpty else {
                alertMessage = "추천 가능한 음식점을 찾지 못했습니다."
                return
            }

            if authStore.isSignedIn {
                do {
                    try await backendService.saveRecommendation(
                        restaurants: restaurants,
                        foodCategories: Array(selectedFoods),
                        location: locationName,
                        latitude: locationProvider.latitude,
                        longitude: locationProvider.longitude,
                        accessToken: authStore.accessToken
                    )
                } catch BackendServiceError.unauthorized {
                    authStore.signOut(message: "로그인이 만료되어 추천 기록은 기기에만 표시됩니다.")
                } catch {
                    toastMessage = "추천 기록을 서버에 저장하지 못했습니다. 추천 결과는 계속 확인할 수 있습니다."
                }
            }

            recommendationResult = RecommendationResult(
                restaurants: restaurants,
                latitude: locationProvider.latitude,
                longitude: locationProvider.longitude
            )
        } catch {
            alertMessage = error.localizedDescription
        }
    }
}

private struct FoodButton: View {
    let food: FoodCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(food.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 46)

                Text(food.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .foregroundStyle(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.text)
            .background(isSelected ? DesignSystem.Colors.selectedSurface : DesignSystem.Colors.surface)
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous)
                    .stroke(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.border, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.medium, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(food.rawValue)
    }
}
