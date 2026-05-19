//
//  RootTabView.swift
//  BobPT
//
//  Created by Codex on 5/20/26.
//

import SwiftUI
import BobPTCore
import DesignSystem
import HistoryFeature
import RecommendationFeature
import SettingsFeature

struct RootTabView: View {
    @AppStorage(DesignSystem.AppearanceMode.storageKey) private var appearanceMode = DesignSystem.AppearanceMode.system
    @StateObject private var selectedStore = SelectedRestaurantStore()

    var body: some View {
        TabView {
            NavigationStack {
                MainView(selectedStore: selectedStore)
            }
            .tabItem {
                Label("홈", systemImage: "house.fill")
            }

            NavigationStack {
                SelectedListView(store: selectedStore)
            }
            .tabItem {
                Label("기록", systemImage: "list.bullet")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("세팅", systemImage: "gearshape.fill")
            }
        }
        .tint(DesignSystem.Colors.primary)
        .toolbarBackground(DesignSystem.Colors.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .preferredColorScheme(appearanceMode.colorScheme)
    }
}
