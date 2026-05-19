//
//  AppDelegate.swift
//  BobPT
//
//  Created by 윤해수 on 4/5/24.
//

import SwiftUI
import UIKit

@main
struct BobPTApp: App {
    @UIApplicationDelegateAdaptor(AppLifecycleDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainView()
            }
        }
    }
}

final class AppLifecycleDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
