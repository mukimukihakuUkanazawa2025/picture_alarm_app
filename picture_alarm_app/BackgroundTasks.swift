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


class BackgroundTasks {
    
    private let backgroundTaskID = "app.hakuu.mukimuki.picture-alarm-app.background.v2"
    
    private let alarmService = AlarmService.shared
    
    
    
    var isAlarmOn = UserDefaults.standard.value(forKey: "isAlarmOn") as? Bool ?? false
    
    
    /// バックグラウンドタスクのハンドラを登録する
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskID, using: nil) { task in
            // 実際に実行したい処理はここ（handleAppRefresh）に書く
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
       
       /// バックグラウンドタスクをOSにスケジュール（予約）する
    @MainActor func scheduleDailyAlarmSetup() {
        
        registerBackgroundTask()
        
        AlarmService.shared.updateAlarmStatus(id: alarmService.currentAlarm!.id, isOn: true, isWakeup: false, isLeave: false)
        
        
        let userDefaults = UserDefaults.standard
               let lastScheduledDateKey = "lastScheduledDate"
               
               // UserDefaultsから最後にタスクをスケジュールした日付を取得
               let lastScheduledDate = userDefaults.object(forKey: lastScheduledDateKey) as? Date

               // 最後の実行日が今日ではないか、または一度も実行されていない場合のみ実行
               if lastScheduledDate == nil || !Calendar.current.isDateInToday(lastScheduledDate!) {
                   print("バックグラウンドタスクを本日分としてスケジュールします。")
//                   backgroundtask.scheduleDailyAlarmSetup()

                   // 今日の日付を保存して、同日中の再実行を防ぐ
                   userDefaults.set(Date(), forKey: lastScheduledDateKey)
                   print("実行日を保存しました: \(Date())")
               } else {
                   return
                   print("本日のバックグラウンドタスクは既にスケジュール済みです。")
               }
        
           let request = BGAppRefreshTaskRequest(identifier: backgroundTaskID)
           
           if let todayalarm =  AlarmService.shared.getTodayAlarm() {
               if todayalarm.isOn == true {
                   scheduleDepaturePostSetup()
                   
                   return
               }
           }
        
     
           // --- ここから修正 ---
           let calendar = Calendar.current
           let now = Date()

           // 基準日を「昨日」ではなく「今日」にする
           guard var targetDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) else {
               print("目標時刻の生成に失敗しました。")
               return
           }


           if now > targetDate {
               targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
           }


              // OSに「この時刻以降のできるだけ早いタイミングで実行してください」と伝える
              request.earliestBeginDate = targetDate

              print("次のバックグラウンドタスクは \(targetDate) 以降にスケジュールされました。")
              
              // --- ここまで修正 ---

              do {
                  
                  BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskID)
                try BGTaskScheduler.shared.submit(request)
                  print("Successfully scheduled background task.")
              } catch {
                  print("Could not schedule background task: \(error)")
              }
           
           
       }
    
    //出発時刻にタスクが実行されるようにする
    @MainActor func scheduleDepaturePostSetup() {
        registerBackgroundTask()
        
        let now = Date()
        print(now)
        
        guard let todayalarm =  AlarmService.shared.getTodayAlarm() else {
            scheduleDailyAlarmSetup()
            return
        }
        
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskID)

        // --- ここから修正 ---
        let calendar = Calendar.current
//               let now = Date()

               // アラームの起床時刻から「時」と「分」を抽出
        let targetHour = calendar.component(.hour, from: todayalarm.leaveTime)
            let targetMinute = calendar.component(.minute, from: todayalarm.leaveTime)

               // 今日の日付で目標時刻を生成
               guard var targetDate = calendar.date(bySettingHour: targetHour, minute: targetMinute, second: 0, of: now) else {
                   print("目標時刻の生成に失敗しました。")
                   return
               }
//        targetDate = calendar.date(byAdding: .hour, value: 9, to: targetDate)!

               // ⭐️ もし現在の時刻が「今日の目標時刻」を過ぎていたら、目標日を1日進める
               if now > targetDate {
                   targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
               }

           // OSに「この時刻以降のできるだけ早いタイミングで実行してください」と伝える
           request.earliestBeginDate = targetDate

           print("次のバックグラウンドタスクは \(targetDate) 以降にスケジュールされました。")
           
           // --- ここまで修正 ---

           do {
               BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskID)
                try BGTaskScheduler.shared.submit(request)
               print("Successfully scheduled background task.")
           } catch {
               print("Could not schedule background task: \(error)")
           }
        
        
    }
    
    @MainActor func handleAppRefresh(task:  BGAppRefreshTask) {
//        // タイムリミットが来たら必ずタスクを終了させるための処理
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
//        defer {
            print("㊗️ Background task started")
            
         
        
       

        if let todayAlarm = AlarmService.shared.getTodayAlarm(), todayAlarm.isOn {
                // アラームがONなら出発処理へ
                handledDepaturePost(task: task)
            } else {
                // アラームがOFFか存在しなければ設定処理へ
                handleSetAarlm(task: task)
            }
        
        task.setTaskCompleted(success: true)
       
    }
       
       /// バックグラウンドで実行される実際の処理
    @MainActor func handleSetAarlm(task:BGAppRefreshTask) {
           // タイムリミットが来たら必ずタスクを終了させるための処理
          

           print("🌅 Background task started. Setting up today's alarm.")
           
           // ここであなたのAlarmServiceのメソッドを呼び出す！
           // MainActorで実行することで、UI関連のプロパティを安全に扱える
           Task {
               
      
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
               await scheduleDepaturePostSetup()
               
           }
       }
    
    @MainActor func handledDepaturePost(task:BGAppRefreshTask){
        // タイムリミットが来たら必ずタスクを終了させるための処理
//        task.expirationHandler = {
//            task.setTaskCompleted(success: false)
//        }
        
        print("💟 Background task started. posting today post.")
        
        // ここであなたのAlarmServiceのメソッドを呼び出す！
        // MainActorで実行することで、UI関連のプロパティを安全に扱える
        Task {
            print("go task")
            
     
                print("alarm check")
                guard self.alarmService.getTodayAlarm() != nil else {
                    print("❌ Error: 実行すべきアラームが見つからず、処理を中断します。")
                    task.setTaskCompleted(success: false) // タスクを失敗として完了
                    return
                    
               
            }
            
           
            postFailurePost(alarmdata: alarmService.currentAlarm!)
            
            // OSにタスクが完了したことを伝える（成功）
            task.setTaskCompleted(success: true)
            print("✅ Background task completed successfully.")
            
            // 次の日のタスクを再スケジュールするのを忘れない！
            await scheduleDailyAlarmSetup()
        }
    }
    
    
    //謝罪画像の投稿
    @MainActor private func postFailurePost(alarmdata:AlarmData){
        
        var postService = PostService()
        
        print("start task")
        
        if alarmdata.isOn{
            print("have alarm")
            if alarmdata.isWakeup && !alarmdata.isLeave{
                if let Wakeupimagedata = UserDefaults.standard.object(forKey: "wakeupImageData") as? Data {
                    Task.detached(priority: .background) {
                        do {
                            // 4. 裏でアップロード処理を実行
                            try await postService.uploadPost(imageData: Wakeupimagedata, comment: "準備が終わりませんでした、、、", status: .isWakeup, completion: { _ in
                                print("can uploard")
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
                }else{
                    Task.detached(priority: .background) {
                        do {
                            // 4. 裏でアップロード処理を実行
                            try await postService.uploadPost(imageData: (UIImage(named: "wakeup")?.jpegData(compressionQuality: 0.5))!, comment: "準備が終わりませんでした、、、", status: .isWakeup, completion: { _ in
                                print("can uploard")
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
                            try await postService.uploadPost(imageData: hitozichiimagedata, comment: "寝過ごしてしまいました、、", status: .noActions, completion: { _ in
                                print("can uploard")
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
                }else {
                    Task.detached(priority: .background) {
                        do {
                            // 4. 裏でアップロード処理を実行
                            try await postService.uploadPost(imageData: (UIImage(named: "wakeup")?.jpegData(compressionQuality: 0.5))!, comment: "寝過ごしてしまいました、、", status: .noActions, completion: { _ in
                                print("can uploard")
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
