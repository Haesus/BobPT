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
    @StateObject private var authStore = AuthSessionStore()
    @State private var toastMessage: String?

    var body: some View {
        TabView {
            NavigationStack {
                MainView(selectedStore: selectedStore, authStore: authStore)
            }
            .tabItem {
                Label("홈", systemImage: "house.fill")
            }

            NavigationStack {
                SelectedListView(store: selectedStore, authStore: authStore)
            }
            .tabItem {
                Label("기록", systemImage: "list.bullet")
            }

            NavigationStack {
                SettingsView(authStore: authStore)
            }
            .tabItem {
                Label("세팅", systemImage: "gearshape.fill")
            }
        }
        .tint(DesignSystem.Colors.primary)
        .toolbarBackground(DesignSystem.Colors.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .preferredColorScheme(appearanceMode.colorScheme)
        .bobPTToast(message: $toastMessage)
        .task {
            await authStore.validateSession()
        }
        .onChange(of: authStore.feedbackMessage) { message in
            guard let message else {
                return
            }

            toastMessage = message
            authStore.feedbackMessage = nil
        }
    }
}
