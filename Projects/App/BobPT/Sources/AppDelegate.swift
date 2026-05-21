//
//  AppDelegate.swift
//  BobPT
//
//  Created by 윤해수 on 4/5/24.
//

import SwiftUI
import UIKit
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKCommon
import BobPTCore

@main
struct BobPTApp: App {
    @UIApplicationDelegateAdaptor(AppLifecycleDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    guard let url = userActivity.webpageURL else {
                        return
                    }

                    handleIncomingURL(url)
                }
        }
    }

    private func handleIncomingURL(_ url: URL) {
#if DEV
        print("[DEV] Incoming URL: \(url.absoluteString)")
#endif
        NetworkLogger.logEvent(
            category: "SocialAuth",
            title: "Incoming URL",
            metadata: ["url": url.absoluteString]
        )

        if AuthApi.isKakaoTalkLoginUrl(url) {
            _ = AuthController.handleOpenUrl(url: url)
            return
        }

        _ = GIDSignIn.sharedInstance.handle(url)
    }
}

final class AppLifecycleDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let kakaoNativeAppKey = Bundle.main.socialLoginValue(for: "KAKAO_NATIVE_APP_KEY") {
            KakaoSDK.initSDK(appKey: kakaoNativeAppKey)

#if DEV
            let suffix = kakaoNativeAppKey.suffix(6)
            print("[DEV] Kakao app key loaded: ***\(suffix)")
#endif
            NetworkLogger.logEvent(
                category: "SocialAuth",
                title: "Kakao SDK initialized",
                metadata: [
                    "appKeySuffix": String(kakaoNativeAppKey.suffix(6)),
                    "bundleId": Bundle.main.bundleIdentifier ?? "-",
                    "callbackScheme": "kakao\(kakaoNativeAppKey)://oauth"
                ]
            )
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
#if DEV
        print("[DEV] AppDelegate open URL: \(url.absoluteString)")
#endif
        NetworkLogger.logEvent(
            category: "SocialAuth",
            title: "AppDelegate open URL",
            metadata: ["url": url.absoluteString]
        )

        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }

        return GIDSignIn.sharedInstance.handle(url)
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }

#if DEV
        print("[DEV] AppDelegate continue URL: \(url.absoluteString)")
#endif
        NetworkLogger.logEvent(
            category: "SocialAuth",
            title: "AppDelegate continue URL",
            metadata: ["url": url.absoluteString]
        )

        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }

        return false
    }
}

private extension Bundle {
    func socialLoginValue(for key: String) -> String? {
        guard let value = object(forInfoDictionaryKey: key) as? String else {
            return nil
        }

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty, !trimmedValue.hasPrefix("$(") else {
            return nil
        }

        return trimmedValue
    }
}
