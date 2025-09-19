//
//  picture_alarm_appApp.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/12.
//

import SwiftUI
import FirebaseCore
import SwiftData
import BackgroundTasks

// =======================
// 共有の ModelContainer (SwiftData)
// =======================
let sharedModelContainer: ModelContainer = {
    let schema = Schema([
        AlarmData.self, // 例：Alarmモデル
        // 他のモデルを追加可能
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    
    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()

// =======================
// Main App
// =======================
@main
struct YourApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    // バックグラウンドタスク管理
    var backgroundtask = BackgroundTasks()
    
    // Firebase / SwiftData 環境
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        // ===== Firebase 初期化 =====
        FirebaseApp.configure()
        
        // ===== バックグラウンドタスク登録・スケジュール =====
        backgroundtask.registerBackgroundTask()
        backgroundtask.scheduleDailyAlarmSetup()
        
        // ===== ナビゲーションバー設定 =====
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = .black
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        let barButtonAppearance = UIBarButtonItemAppearance()
        barButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        barButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
        navAppearance.backButtonAppearance = barButtonAppearance
        
        let backImage = UIImage(systemName: "chevron.left")?
            .withRenderingMode(.alwaysTemplate)
        navAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        UINavigationBar.appearance().tintColor = .white
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        
        // ===== タブバー設定 =====
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        let tabColor = UIColor(Color(hex: "212121").opacity(0.8))
        tabAppearance.backgroundColor = tabColor
        
        let normalAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        let selectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(Color(hex: "FF8300"))]
        
        tabAppearance.stackedLayoutAppearance.normal.iconColor = .white
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "FF8300"))
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        tabAppearance.inlineLayoutAppearance = tabAppearance.stackedLayoutAppearance
        tabAppearance.compactInlineLayoutAppearance = tabAppearance.stackedLayoutAppearance
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background || newPhase == .active {
                print("App is in background or active. Scheduling daily alarm setup task.")
                backgroundtask.scheduleDailyAlarmSetup()
            }
        }
    }
}
