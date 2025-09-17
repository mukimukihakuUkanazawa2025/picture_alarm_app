//
//  AlarmService.swift
//  picture_alarm_app
//
//  Created by Assistant on 2025/09/14.
//

import Foundation
import AVFoundation
import AudioToolbox
import UserNotifications
import SwiftData
import SwiftUI




// アラームのビューモデル
@MainActor
class AlarmService: ObservableObject {
    
    
    // 変更点 1: @Queryを削除
    // @Query private var alarmdata: [AlarmData]
    
    // 共有コンテナから直接、安全にmainContextを取得できる
    private let context = sharedModelContainer.mainContext
    
    static let shared = AlarmService()
    
    @Published var alarms: [AlarmData] = []
    @Published var currentAlarm: AlarmData?
    private var timer: Timer?
    private var alarmTimer: Timer?
    @Published var isAlarmPlaying = false
    @Published var isAlarmOn: Bool = false
    @Published var isWakeupnow: Bool = false
    @Published var isPrepareDone: Bool = false
    
    private init() {
        setupAudioSession()
        requestNotificationPermission()
        fetchAlarms() // 変更点 2: 初期化時にデータを取得する
        startMonitoring()
        setTodayAlarm()
    }
    
    // 変更点 3: 手動でデータを取得するメソッドを追加
    /// SwiftDataからアラームを全て取得し、`alarms`プロパティを更新する
    func fetchAlarms() {
        let descriptor = FetchDescriptor<AlarmData>(sortBy: [SortDescriptor(\.date)])
        do {
            self.alarms = try context.fetch(descriptor)
            print("アラームの取得に成功: \(alarms.count)件")
        } catch {
            print("アラームの取得に失敗: \(error)")
        }
//        print(self.alarms)
    }
    
    /// 日毎のアラームを追加
    func addAlarm(date: Date, wakeUpTime: Date, leaveTime: Date) {
        let calendar = Calendar(identifier: .gregorian)
        
        // 変更点 4: `alarmdata`を`alarms`に変更
        if let index = alarms.firstIndex(where: { calendar.startOfDay(for: $0.date) == calendar.startOfDay(for: date)}){
            updateAlarm(id: alarms[index].id, date: alarms[index].date, wakeUpTime: wakeUpTime, leaveTime: leaveTime)
        } else {
            let alarm = AlarmData(date: date, wakeUpTime: wakeUpTime, leaveTime: leaveTime)
            context.insert(alarm)
            saveAndFetchAlarms() // 変更点 5: 保存と再取得を1つのメソッドにまとめる
            startMonitoring()
            scheduleNotification(for: alarm)
        }
    }
    
    /// アラームを更新
    func updateAlarm(id: String, date: Date, wakeUpTime: Date, leaveTime: Date) {
        // alarms配列から更新対象のアラーム（への参照）を探す
            if let alarmToUpdate = alarms.first(where: { $0.id == id }) {
                
                // 参照している元のオブジェクトのプロパティを直接変更する
                alarmToUpdate.date = date
                alarmToUpdate.wakeUpTime = wakeUpTime
                alarmToUpdate.leaveTime = leaveTime
                
                // 変更を保存し、配列を更新する
                saveAndFetchAlarms()
                startMonitoring()
                
                // 通知を再スケジュールする
                scheduleNotification(for: alarmToUpdate)
            }
    }
    
    /// アラームを削除
    func removeAlarm(id: String) {
        // 変更点 4: `alarmdata`を`alarms`に変更
        if let alarmToDelete = alarms.first(where: { $0.id == id }) {
            context.delete(alarmToDelete)
            saveAndFetchAlarms() // 変更点 5
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            startMonitoring()
        }
    }
    
    /// アラーム音を停止
    func stopAlarm() {
        alarmTimer?.invalidate()
        alarmTimer = nil
        isAlarmPlaying = false
        print("🔕 アラーム音を停止しました")
        
        if let currentAlarm = currentAlarm {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [currentAlarm.id])
        }
    }
    
    /// 特定の日付のアラームを取得
    func getAlarm(for date: Date) -> AlarmData? {
        let calendar = Calendar.current
        // 変更点 4: `alarmdata`を`alarms`に変更
        if let existingAlarm = alarms.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            return existingAlarm
        } else {
            // 見つからなかった場合、新しいものを作成して返す（再帰呼び出しは避ける）
            let newAlarm = AlarmData(date: date, wakeUpTime: date, leaveTime: date)
            context.insert(newAlarm)
            saveAndFetchAlarms()
            // alarms配列から新しいインスタンスを返す
            return alarms.first(where: { $0.id == newAlarm.id })
        }
    }
    
    /// 今日のアラームを取得
    func getTodayAlarm() -> AlarmData? {
        let todayalarm = getAlarm(for: Date())
        if todayalarm?.wakeUpTime != todayalarm?.leaveTime {
//            currentAlarm = todayalarm
            
            return todayalarm
        }else{
//            currentAlarm = nil
            return nil
        }
    }
    
    func setTodayAlarm(){
        let todayalarm = getAlarm(for: Date())
        if todayalarm?.wakeUpTime != todayalarm?.leaveTime {
//            currentAlarm = todayalarm
            isAlarmOn = true

        }else{
//            currentAlarm = nil
            isAlarmOn = false
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() { /* ... 変更なし ... */ }
    private func requestNotificationPermission() { /* ... 変更なし ... */ }
    
    // 変更点 6: メソッド名を変更し、責務を明確化
    /// 変更を保存し、データを再取得して`alarms`配列を更新する
    private func saveAndFetchAlarms() {
        do {
            try context.save()
        } catch {
            print("データの保存に失敗: \(error)")
        }
        fetchAlarms() // 保存後に必ずデータを再取得
    }
    
    // UserDefaultsからアラーム情報を読み込み
    //    private func loadAlarms() {
    //        guard let data = UserDefaults.standard.data(forKey: "alarms") else { return }
    //        do {
    //            alarms = try JSONDecoder().decode([AlarmData].self, from: data)
    //        } catch {
    //            print("アラームの読み込みに失敗しました: \(error)")
    //        }
    //    }
    
    //タイマーで時間監視を開始
    private func startMonitoring() {
        stopMonitoring()
        
        // 今日のアラームを取得
        guard let todayAlarm = getTodayAlarm() else { return }
        currentAlarm = todayAlarm
        
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.checkAlarmTime()
        }
        
        // 即座に1回チェック
        checkAlarmTime()
    }
    
    //タイマー停止
    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        currentAlarm = nil
        stopAlarm() // アラーム音も停止し通知もキャンセル
    }
    
    //アラーム時間になったかをチェック
    private func checkAlarmTime() {
        guard let alarm = currentAlarm else { return }
        
        let now = Date()
        let calendar = Calendar.current
        
        // 日付と時刻を比較
        let nowComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let alarmDateComponents = calendar.dateComponents([.year, .month, .day], from: alarm.date)
        let alarmTimeComponents = calendar.dateComponents([.hour, .minute], from: alarm.wakeUpTime)
        
        // 日付が一致し、時刻も一致したらアラームを鳴らす
        if nowComponents.year == alarmDateComponents.year &&
            nowComponents.month == alarmDateComponents.month &&
            nowComponents.day == alarmDateComponents.day &&
            nowComponents.hour == alarmTimeComponents.hour &&
            nowComponents.minute == alarmTimeComponents.minute {
            startAlarmSound()
        }
    }
    
    // アラーム音を繰り返し再生開始
    private func startAlarmSound() {
        // 既にアラームが鳴っている場合は何もしない
        guard !isAlarmPlaying else { return }
        
        isAlarmPlaying = true
        print("🔔 アラーム音を開始します！")
        
        // 即座に1回再生
        playSystemSound()
        
        // 3秒間隔で繰り返し再生
        alarmTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.playSystemSound()
        }
    }
    
    private func playSystemSound() {
#if targetEnvironment(simulator)
        print("🔔 アラーム音が鳴りました！")
#else
        AudioServicesPlaySystemSound(1005) // アラーム音
#endif
    }
    
    
    /// ローカル通知をスケジュール (30秒間音付き)
    func scheduleNotification(for alarm: AlarmData) {
        if alarm.wakeUpTime == alarm.leaveTime {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = "起床時間です！"
        content.sound = UNNotificationSound.defaultCritical
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: alarm.date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: alarm.wakeUpTime)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second ?? 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: alarm.id, content: content, trigger: trigger)
        
        // 通知をスケジュール
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知のスケジューリングに失敗しました: \(error)")
            } else {
                print("🔔 ローカル通知をスケジュールしました: \(alarm.id)")
            }
        }
    }
}
