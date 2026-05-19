//
//  SelectedListView.swift
//  BobPT
//
//  Created by Codex on 5/19/26.
//

import SwiftUI

struct SelectedListView: View {
    @ObservedObject var store: SelectedRestaurantStore

    var body: some View {
        Group {
            if store.restaurants.isEmpty {
                VStack(spacing: 18) {
                    Image("RobotForce")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)

                    Text("저장된 추천 장소가 없습니다.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BobPTTheme.background)
            } else {
                List {
                    ForEach(store.restaurants) { restaurant in
                        HStack(spacing: 14) {
                            Image(restaurant.imageString ?? "Default")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 54)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(restaurant.title.htmlEscaped)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(restaurant.date.htmlEscaped)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: store.delete)
                }
                .scrollContentBackground(.hidden)
                .background(BobPTTheme.background)
            }
        }
        .navigationTitle("추천 기록")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
        .onAppear {
            store.load()
        }
    }
}
