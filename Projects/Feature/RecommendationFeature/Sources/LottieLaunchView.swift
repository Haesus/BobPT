//
//  LottieLaunchView.swift
//  RecommendationFeature
//
//  Created by Codex on 5/19/26.
//

import Lottie
import QuartzCore
import SwiftUI
import DesignSystem

struct LottieLaunchView: UIViewRepresentable {
    let completion: () -> Void

    func makeUIView(context: Context) -> UIView {
        let startedAt = CACurrentMediaTime()
        let minimumDisplayDuration: CFTimeInterval = 1.8
        func finishAfterMinimumDuration() {
            let elapsed = CACurrentMediaTime() - startedAt
            let delay = max(0, minimumDisplayDuration - elapsed)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                completion()
            }
        }

        let container = UIView()
        container.backgroundColor = UIColor(DesignSystem.Colors.background)

        let animation = LottieAnimation.named("LaunchScreen", bundle: .main)
        let animationView = LottieAnimationView(animation: animation)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce

        container.addSubview(animationView)
        let widthConstraint = animationView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.72)
        widthConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            widthConstraint,
            animationView.widthAnchor.constraint(lessThanOrEqualTo: container.widthAnchor, multiplier: 0.72),
            animationView.heightAnchor.constraint(lessThanOrEqualTo: container.heightAnchor, multiplier: 0.44),
            animationView.widthAnchor.constraint(equalTo: animationView.heightAnchor),
            animationView.widthAnchor.constraint(lessThanOrEqualToConstant: 320)
        ])

        guard animation != nil else {
            finishAfterMinimumDuration()
            return container
        }

        DispatchQueue.main.async {
            animationView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce) { _ in
                finishAfterMinimumDuration()
            }
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
