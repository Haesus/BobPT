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

@main
struct BobPTApp: App {
    @UIApplicationDelegateAdaptor(AppLifecycleDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}

final class AppLifecycleDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let kakaoNativeAppKey = Bundle.main.socialLoginValue(for: "KAKAO_NATIVE_APP_KEY") {
            KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }

        return GIDSignIn.sharedInstance.handle(url)
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
