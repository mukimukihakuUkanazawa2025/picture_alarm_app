//
//  picture_alarm_appApp.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/12.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
    // 🔹 シミュレータや開発中は AppCheck を無効化
    AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())

    return true
  }
}

//@main
//struct YourApp: App {
//  // register app delegate for Firebase setup
//  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @main
    struct YourApp: App {
        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

        init() {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black

            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

            // 戻るボタンの文字を消す
            let barButtonAppearance = UIBarButtonItemAppearance()
            barButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            barButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.backButtonAppearance = barButtonAppearance

            // 矢印の色を白にする
            let backImage = UIImage(systemName: "chevron.left")?
                .withRenderingMode(.alwaysTemplate) // テンプレート化
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
            UINavigationBar.appearance().tintColor = .white // ← tint を白に

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
        }


//  var body: some Scene {
//    WindowGroup {
//      NavigationView {
////        ContentView()
//          EntryView()
//      }
//    }
//  }
        var body: some Scene {
            WindowGroup {
                NavigationStack {
                    EntryView()
                }
                .tint(.white) // ← これが重要！NavigationStack 全体に白を適用
            }
        }
}
