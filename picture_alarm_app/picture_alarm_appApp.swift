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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase

    init() {
        
        registerBackgroundTask()
        
        scheduleDailyAlarmSetup()
        
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

        // 共通のアイテムカラー設定
        let normalAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        let selectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(Color(hex: "FF8300"))]

        // iOS15以降はこれを全部に指定してあげる必要がある
        tabAppearance.stackedLayoutAppearance.normal.iconColor = .white
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "FF8300"))
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs

        tabAppearance.inlineLayoutAppearance = tabAppearance.stackedLayoutAppearance
        tabAppearance.compactInlineLayoutAppearance = tabAppearance.stackedLayoutAppearance

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        
    }
    
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            
            
            RootView()
                .environmentObject(authViewModel)
                
        }.modelContainer(sharedModelContainer)
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .background || newPhase == .active{
                            print("App is in background. Scheduling daily alarm setup task.")
                            scheduleDailyAlarmSetup()
                        }
                    }
           
    }
    
    private let backgroundTaskID = "app.hakuu.mukimuki.picture-alarm-app.background"
    
    
    /// バックグラウンドタスクのハンドラを登録する
       private func registerBackgroundTask() {
           BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskID, using: nil) { task in
               // 実際に実行したい処理はここ（handleAppRefresh）に書く
               self.handleAppRefresh(task: task as! BGAppRefreshTask)
           }
       }
       
       /// バックグラウンドタスクをOSにスケジュール（予約）する
       private func scheduleDailyAlarmSetup() {
           let request = BGAppRefreshTaskRequest(identifier: backgroundTaskID)

           // --- ここから修正 ---
           let calendar = Calendar.current
           let now = Date()

           // 基準日を「昨日」ではなく「今日」にする
           guard var targetDate = calendar.date(bySettingHour: 5, minute: 41, second: 0, of: now) else {
               print("目標時刻の生成に失敗しました。")
               return
           }

           // もし現在の時刻が「今日の朝5時18分」を既に過ぎていたら、
           // 目標日を1日進めて「明日の朝5時18分」に設定する
           if now > targetDate {
               targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
           }


              // OSに「この時刻以降のできるだけ早いタイミングで実行してください」と伝える
              request.earliestBeginDate = targetDate

              print("次のバックグラウンドタスクは \(targetDate) 以降にスケジュールされました。")
              
              // --- ここまで修正 ---

              do {
                  try BGTaskScheduler.shared.submit(request)
                  print("Successfully scheduled background task.")
              } catch {
                  print("Could not schedule background task: \(error)")
              }
           
           
       }
       
       /// バックグラウンドで実行される実際の処理
       private func handleAppRefresh(task: BGAppRefreshTask) {
           // タイムリミットが来たら必ずタスクを終了させるための処理
           task.expirationHandler = {
               task.setTaskCompleted(success: false)
           }

           print("🌅 Background task started. Setting up today's alarm.")
           
           // ここであなたのAlarmServiceのメソッドを呼び出す！
           // MainActorで実行することで、UI関連のプロパティを安全に扱える
           Task { @MainActor in
               AlarmService.shared.setTodayAlarm()
               AlarmService.shared.startMonitoring() // 監視も再スタート
               
               // OSにタスクが完了したことを伝える（成功）
               task.setTaskCompleted(success: true)
               print("✅ Background task completed successfully.")
               
               // 次の日のタスクを再スケジュールするのを忘れない！
               scheduleDailyAlarmSetup()
           }
       }
}


// 共有のModelContainerを先に作ってしまう
let sharedModelContainer: ModelContainer = {
    // あなたのアプリで使うモデルのスキーマを定義
    let schema = Schema([
        AlarmData.self, // 例：Alarmモデル
        // 他のモデルがあればここに追加
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}() // 即時実行クロージャで初期化


////
////  picture_alarm_appApp.swift
////  picture_alarm_app
////
////  Created by tanaka niko on 2025/09/12.
////
//
//import SwiftUI
//import FirebaseCore
////import FirebaseAppCheck
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//    
//    // 🔹 シミュレータや開発中は AppCheck を無効化
////    AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
//
//    return true
//  }
//}
//
////@main
////struct YourApp: App {
////  // register app delegate for Firebase setup
////  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    
//    @main
//    struct YourApp: App {
//        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//
//        init() {
//            let appearance = UINavigationBarAppearance()
//            appearance.configureWithOpaqueBackground()
//            appearance.backgroundColor = .black
//
//            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//
//            // 戻るボタンの文字を消す
//            let barButtonAppearance = UIBarButtonItemAppearance()
//            barButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
//            barButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
//            appearance.backButtonAppearance = barButtonAppearance
//
//            // 矢印の色を白にする
//            let backImage = UIImage(systemName: "chevron.left")?
//                .withRenderingMode(.alwaysTemplate) // テンプレート化
//            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
//            UINavigationBar.appearance().tintColor = .white // ← tint を白に
//
//            UINavigationBar.appearance().standardAppearance = appearance
//            UINavigationBar.appearance().scrollEdgeAppearance = appearance
//            UINavigationBar.appearance().compactAppearance = appearance
//        }
//
//
////  var body: some Scene {
////    WindowGroup {
////      NavigationView {
//////        ContentView()
////          EntryView()
////      }
////    }
////  }
//        var body: some Scene {
////            @StateObject var cameraviewmodel = CameraViewModel()
//            
//            WindowGroup {
////                CameraView(cameraviewmodel: cameraviewmodel)
//                EntryView()
////                NavigationStack {
////                    EntryView()
////                }
////                .tint(.white) // ← これが重要！NavigationStack 全体に白を適用
//            }
//        }
//}
