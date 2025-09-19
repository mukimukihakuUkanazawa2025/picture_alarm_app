//
//  BackgroundTasks.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/19.
//

import Foundation
import SwiftData
import BackgroundTasks
import SwiftUI


class BackgroundTask: ObservableObject {
    
    private let backgroundTaskID = "app.hakuu.mukimuki.picture-alarm-app.background"
    
    @StateObject var alarmService = AlarmService.shared
    
    var postService = PostService()
    
    @State var isAlarmOn = UserDefaults.standard.value(forKey: "isAlarmOn") as? Bool ?? false
    
    
    /// バックグラウンドタスクのハンドラを登録する
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskID, using: nil) { task in
            // 実際に実行したい処理はここ（handleAppRefresh）に書く
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
       
       /// バックグラウンドタスクをOSにスケジュール（予約）する
       func scheduleDailyAlarmSetup() {
           let request = BGAppRefreshTaskRequest(identifier: backgroundTaskID)
           
           if let todayalarm =  AlarmService.shared.getTodayAlarm() {
               if todayalarm.isOn == true {
                   scheduleDepaturePostSetup()
               }
           }

           // --- ここから修正 ---
           let calendar = Calendar.current
           let now = Date()

           // 基準日を「昨日」ではなく「今日」にする
           guard var targetDate = calendar.date(bySettingHour: 10, minute: 43, second: 0, of: now) else {
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
    
    //出発時刻にタスクが実行されるようにする
     func scheduleDepaturePostSetup() {
        guard let todayalarm =  AlarmService.shared.getTodayAlarm() else {
            scheduleDailyAlarmSetup()
            return
        }
        
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskID)

        // --- ここから修正 ---
        let calendar = Calendar.current
           let now = Date()

           // 1. `todayalarm`の起床時刻から「時」と「分」を抽出する
           let targetHour = calendar.component(.hour, from: todayalarm.wakeUpTime)
           let targetMinute = calendar.component(.minute, from: todayalarm.wakeUpTime)

           // 2. 抽出した「時」と「分」を使って、今日の目標時刻を生成する
           guard var targetDate = calendar.date(bySettingHour: targetHour, minute: targetMinute, second: 0, of: now) else {
               print("目標時刻の生成に失敗しました。")
               return
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
    
    func handleAppRefresh(task:  BGAppRefreshTask) {
        // タイムリミットが来たら必ずタスクを終了させるための処理
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        print("㊗️ Background task started")
        
        //出発処理を実行
        if isAlarmOn{
            
            handledDepaturePost(task: task)
        
        //アラーム設定処理を追加
        }else{
            handleSetAarlm(task: task)
        
        }
        
       
    }
       
       /// バックグラウンドで実行される実際の処理
    private func handleSetAarlm(task:BGAppRefreshTask) {
           // タイムリミットが来たら必ずタスクを終了させるための処理
          

           print("🌅 Background task started. Setting up today's alarm.")
           
           // ここであなたのAlarmServiceのメソッドを呼び出す！
           // MainActorで実行することで、UI関連のプロパティを安全に扱える
           Task { @MainActor in
               
               //今日のアラームが設定されているときだけ処理を実行
               if let todayalarm = AlarmService.shared.getTodayAlarm(){
                   AlarmService.shared.startMonitoring() // 監視も再スタート
//                   scheduleDepaturePostSetup()
               }else{
                print("💸 No Alarm")
//                   scheduleDailyAlarmSetup()
               }
               
              
               
               // OSにタスクが完了したことを伝える（成功）
               task.setTaskCompleted(success: true)
               print("✅ Background task completed successfully.")
               
               // 次の日のタスクを再スケジュールするのを忘れない！
               scheduleDepaturePostSetup()
               
           }
       }
    
    private func handledDepaturePost(task:BGAppRefreshTask){
        // タイムリミットが来たら必ずタスクを終了させるための処理
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        print("💟 Background task started. posting today post.")
        
        // ここであなたのAlarmServiceのメソッドを呼び出す！
        // MainActorで実行することで、UI関連のプロパティを安全に扱える
        Task {

            postFailurePost(alarmdata: alarmService.currentAlarm!)
            
            // OSにタスクが完了したことを伝える（成功）
            task.setTaskCompleted(success: true)
            print("✅ Background task completed successfully.")
            
            // 次の日のタスクを再スケジュールするのを忘れない！
            scheduleDailyAlarmSetup()
        }
    }
    
    
    //謝罪画像の投稿
    private func postFailurePost(alarmdata:AlarmData){
        
        if alarmdata.isOn{
            if alarmdata.isWakeup && !alarmdata.isLeave{
                if let Wakeupimagedata = UserDefaults.standard.object(forKey: "wakeupImageData") as? Data {
                    Task.detached(priority: .background) {
                        do {
                            // 4. 裏でアップロード処理を実行
                            try await self.postService.uploadPost(imageData: Wakeupimagedata, comment: "準備が終わりませんでした、、、", completion: { _ in
                                print("a")
                            })
                            
                            // 5. (任意) アップロード成功後、裏で何か処理が必要な場合はここで行う
                            
                            
                            
                            // 例: アプリ全体の投稿リストを更新する通知を送るなど
                            await MainActor.run {
                                // alarmService.postsNeedRefresh = true
                            }
                            
                        } catch {
                            // エラーが発生してもUIは既にないので、コンソールにログを出すなどの対応
                            print("❌ バックグラウンドでの投稿に失敗しました: \(error.localizedDescription)")
                        }
                    }
                }
                
                alarmService.updateAlarmStatus(id: alarmdata.id, isOn: false, isWakeup: true, isLeave: true)
//
               
            } else if !alarmdata.isWakeup && !alarmdata.isLeave {
                if let hitozichiimagedata = UserDefaults.standard.object(forKey: "hitozichiImage") as? Data {
                    Task.detached(priority: .background) {
                        do {
                            // 4. 裏でアップロード処理を実行
                            try await self.postService.uploadPost(imageData: hitozichiimagedata, comment: "寝過ごしてしまいました、、", completion: { _ in
                                print("a")
                            })
                            
                            // 5. (任意) アップロード成功後、裏で何か処理が必要な場合はここで行う
                            
                            
                            
                            // 例: アプリ全体の投稿リストを更新する通知を送るなど
                            await MainActor.run {
                                // alarmService.postsNeedRefresh = true
                            }
                            
                        } catch {
                            // エラーが発生してもUIは既にないので、コンソールにログを出すなどの対応
                            print("❌ バックグラウンドでの投稿に失敗しました: \(error.localizedDescription)")
                        }
                    }
                }
                
                alarmService.updateAlarmStatus(id: alarmdata.id, isOn: false, isWakeup: true, isLeave: true)
            }
        }
        
    }
}
