//
//  MainView.swift
//  BobPT
//
//  Created by Codex on 5/19/26.
//

import SwiftUI
import BobPTCore
import BobPTDomain
import DesignSystem

public struct MainView: View {
    @AppStorage(DesignSystem.AppearanceMode.storageKey) private var appearanceMode = DesignSystem.AppearanceMode.system
    @StateObject private var locationProvider = LocationProvider()
    @StateObject private var selectedStore = SelectedRestaurantStore()
    @State private var selectedFoods: Set<FoodCategory> = []
    @State private var recommendationResult: RecommendationResult?
    @State private var isSearching = false
    @State private var alertMessage: String?
    @State private var showsLaunchAnimation = true

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)
    private let searchService = NaverSearchService()

    public init() {}

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
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        SelectedListView(store: selectedStore)
                    } label: {
                        Image(systemName: "list.bullet")
                    }

                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .background(recommendationLink)
            .alert("알림", isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "")
            }
            .disabled(isSearching)
            .task {
                locationProvider.requestLocation()
                selectedStore.load()
            }

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
                }
                .ignoresSafeArea()
                .transition(.opacity)
            }
        }
        .preferredColorScheme(appearanceMode.colorScheme)
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

    private var recommendationLink: some View {
        NavigationLink(
            isActive: Binding(
                get: { recommendationResult != nil },
                set: { isActive in
                    if !isActive {
                        recommendationResult = nil
                    }
                }
            )
        ) {
            if let recommendationResult {
                ResultView(result: recommendationResult, store: selectedStore)
            }
        } label: {
            EmptyView()
        }
        .hidden()
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
            try await withThrowingTaskGroup(of: [Restaurant].self) { group in
                for food in selectedFoods {
                    group.addTask {
                        try await searchService.search(location: locationProvider.userLocation, food: food)
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
