//
//  ResultView.swift
//  BobPT
//
//  Created by Codex on 5/19/26.
//

import SwiftUI

struct ResultView: View {
    let result: RecommendationResult
    @ObservedObject var store: SelectedRestaurantStore
    @State private var restaurant: Restaurant?

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 16)

            Text("오늘의 추천장소는")
                .font(.title2.weight(.semibold))
                .foregroundStyle(BobPTTheme.text)

            if let restaurant {
                Image(restaurant.imageString ?? "Default")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 100)

                Text(restaurant.title.htmlEscaped)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.55)
                    .foregroundStyle(BobPTTheme.primary)

                Text("맛있게 드세요!")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(BobPTTheme.text)

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
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BobPTTheme.background.ignoresSafeArea())
        .navigationTitle("추천 결과")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard restaurant == nil, let selected = result.restaurants.randomElement() else {
                return
            }

            restaurant = selected
            store.insert(selected)
        }
    }
}
