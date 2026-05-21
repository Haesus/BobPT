//
//  SelectedListView.swift
//  HistoryFeature
//
//  Created by Codex on 5/19/26.
//

import SwiftUI
import BobPTCore
import BobPTDomain
import DesignSystem
import FeedbackUI
import Utils

public struct SelectedListView: View {
    @ObservedObject var store: SelectedRestaurantStore
    @ObservedObject var authStore: AuthSessionStore
    @State private var remoteSelections: [SavedRestaurant] = []
    @State private var isLoading = false
    @State private var alertMessage: String?
    @State private var toastMessage: String?

    private let backendService = BobPTBackendService()

    public init(store: SelectedRestaurantStore, authStore: AuthSessionStore) {
        self.store = store
        self.authStore = authStore
    }

    public var body: some View {
        Group {
            if displayedRestaurants.isEmpty {
                VStack(spacing: 18) {
                    Image("RobotForce")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)

                    Text("저장된 추천 장소가 없습니다.")
                        .font(.headline)
                        .foregroundStyle(DesignSystem.Colors.secondaryText)
                    if isLoading {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DesignSystem.Colors.background)
            } else {
                List {
                    ForEach(displayedRestaurants) { item in
                        HStack(spacing: 14) {
                            Image(item.restaurant.imageString ?? "Default")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 54)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.restaurant.title.htmlEscaped)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(item.restaurant.date.htmlEscaped)
                                    .font(.subheadline)
                                    .foregroundStyle(DesignSystem.Colors.secondaryText)
                            }
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(DesignSystem.Colors.surface)
                    }
                    .onDelete(perform: delete)
                }
                .scrollContentBackground(.hidden)
                .background(DesignSystem.Colors.background)
            }
        }
        .navigationTitle("추천 기록")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
        .bobPTAlert(message: $alertMessage)
        .bobPTToast(message: $toastMessage)
        .onAppear {
            load()
        }
        .onChange(of: authStore.isSignedIn) { _ in
            load()
        }
    }

    private var displayedRestaurants: [DisplayedRestaurant] {
        if authStore.isSignedIn {
            return remoteSelections.map { DisplayedRestaurant(id: $0.id, restaurant: $0.restaurant) }
        }

        return store.restaurants.map { DisplayedRestaurant(id: $0.id, restaurant: $0) }
    }

    private func load() {
        if let accessToken = authStore.accessToken {
            Task {
                await loadRemote(accessToken: accessToken)
            }
        } else {
            store.load()
            remoteSelections = []
        }
    }

    private func loadRemote(accessToken: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            remoteSelections = try await backendService.fetchSelections(accessToken: accessToken)
        } catch BackendServiceError.unauthorized {
            authStore.signOut(message: "로그인이 만료되어 기기에 저장된 기록을 표시합니다.")
            store.load()
            remoteSelections = []
        } catch BackendServiceError.missingBaseURL {
            store.load()
            remoteSelections = []
            toastMessage = "API 주소가 설정되지 않아 기기에 저장된 기록을 표시합니다."
        } catch {
            alertMessage = "서버 기록을 불러오지 못했습니다."
        }
    }

    private func delete(at offsets: IndexSet) {
        if let accessToken = authStore.accessToken {
            let targets = offsets.compactMap { remoteSelections.indices.contains($0) ? remoteSelections[$0] : nil }
            let previousSelections = remoteSelections
            remoteSelections.remove(atOffsets: offsets)
            Task {
                for target in targets {
                    do {
                        try await backendService.deleteSelection(id: target.id, accessToken: accessToken)
                    } catch BackendServiceError.unauthorized {
                        await MainActor.run {
                            authStore.signOut(message: "로그인이 만료되어 서버 기록 삭제를 완료하지 못했습니다.")
                            store.load()
                            remoteSelections = []
                        }
                        return
                    } catch {
                        await MainActor.run {
                            remoteSelections = previousSelections
                            toastMessage = "서버 기록을 삭제하지 못했습니다."
                        }
                        return
                    }
                }
            }
        } else {
            store.delete(at: offsets)
        }
    }
}

private struct DisplayedRestaurant: Identifiable {
    let id: String
    let restaurant: Restaurant
}
