//
//  LottieLaunchView.swift
//  BobPT
//
//  Created by Codex on 5/19/26.
//

import Lottie
import SwiftUI
import DesignSystem

struct LottieLaunchView: UIViewRepresentable {
    let completion: () -> Void

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: "LaunchScreen")
        view.backgroundColor = UIColor(DesignSystem.Colors.background)
        view.contentMode = .scaleAspectFit
        view.loopMode = .playOnce
        view.play { _ in
            completion()
        }
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
