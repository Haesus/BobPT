//
//  BobPTRootView.swift
//  BobPTFeature
//
//  Created by Codex on 5/19/26.
//

import SwiftUI
import BobPTCore
import DesignSystem

public struct BobPTRootView: View {
    @AppStorage(DesignSystem.AppearanceMode.storageKey) private var appearanceMode = DesignSystem.AppearanceMode.system
    @StateObject private var selectedStore = SelectedRestaurantStore()

    public init() {}

    public var body: some View {
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
