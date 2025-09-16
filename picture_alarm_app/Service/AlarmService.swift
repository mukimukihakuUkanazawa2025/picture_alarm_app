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

//アラームデータ構造
struct AlarmData: Equatable, Identifiable, Encodable, Decodable {
    let id: UUID
    let date: Date
    let wakeUpTime: Date
    let leaveTime: Date
    
    init(date: Date, wakeUpTime: Date, leaveTime: Date) {
        self.id = UUID()
        self.date = date
        self.wakeUpTime = wakeUpTime
        self.leaveTime = leaveTime
    }
}

// アラームのビューモデル
class AlarmService: ObservableObject {
    static let shared = AlarmService()
    @Published var alarms: [AlarmData] = []
    //今設定中のアラーム
    @Published var currentAlarm: AlarmData?
    private var timer: Timer?
    private var alarmTimer: Timer? // アラーム音を繰り返し再生するタイマー
    @Published var isAlarmPlaying = false // アラームが鳴っているかどうか
    @Published var isAlarmOn: Bool = false //アラームが設定ずみかチェック
    
    private init() {
        setupAudioSession()
        requestNotificationPermission()
        loadAlarms()
        startMonitoring()
    }
    
    /// 日毎のアラームを追加
    func addAlarm(date: Date, wakeUpTime: Date, leaveTime: Date) {
        let alarm = AlarmData(date: date, wakeUpTime: wakeUpTime, leaveTime: leaveTime)
        alarms.append(alarm)
        saveAlarms()
        startMonitoring()
        scheduleNotification(for: alarm)
    }
    
    /// アラームを更新
    func updateAlarm(id: UUID, date: Date, wakeUpTime: Date, leaveTime: Date) {
        if let index = alarms.firstIndex(where: { $0.id == id }) {
            alarms[index] = AlarmData(date: date, wakeUpTime: wakeUpTime, leaveTime: leaveTime)
            saveAlarms()
            startMonitoring()
            scheduleNotification(for: alarms[index])
        }
    }
    
    /// アラームを削除
    func removeAlarm(id: UUID) {
        alarms.removeAll { $0.id == id }
        saveAlarms()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        startMonitoring()
    }
    
    /// アラーム音を停止
    func stopAlarm() {
        alarmTimer?.invalidate()
        alarmTimer = nil
        isAlarmPlaying = false
        print("🔕 アラーム音を停止しました")
        
        // 通知もキャンセル
        if let currentAlarm = currentAlarm {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [currentAlarm.id.uuidString])
        }
    }
    
    /// 特定の日付のアラームを取得
    func getAlarm(for date: Date) -> AlarmData? {
        let calendar = Calendar.current
        return alarms.first { alarm in
            calendar.isDate(alarm.date, inSameDayAs: date)
        }
    }
    
    /// 今日のアラームを取得
    func getTodayAlarm() -> AlarmData? {
        return getAlarm(for: Date())
    }
    
    // MARK: - Private Methods
    
    //オーディオセッションの初期設定
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("オーディオセッションの設定に失敗: \(error)")
        }
    }
    
    // 通知許可をリクエスト
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("通知許可のリクエストに失敗: \(error)")
            } else if granted {
                print("通知許可が与えられました")
            } else {
                print("通知許可が拒否されました")
            }
        }
    }
    
    // アラーム情報をUserDefaultsに保存
    private func saveAlarms() {
        do {
            let data = try JSONEncoder().encode(alarms)
            UserDefaults.standard.set(data, forKey: "alarms")
        } catch {
            print("アラームの保存に失敗しました: \(error)")
        }
    }
    
    // UserDefaultsからアラーム情報を読み込み
    private func loadAlarms() {
        guard let data = UserDefaults.standard.data(forKey: "alarms") else { return }
        do {
            alarms = try JSONDecoder().decode([AlarmData].self, from: data)
        } catch {
            print("アラームの読み込みに失敗しました: \(error)")
        }
    }
    
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
        
        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
        
        // 通知をスケジュール
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知のスケジューリングに失敗しました: \(error)")
            } else {
                print("🔔 ローカル通知をスケジュールしました: \(alarm.id.uuidString)")
            }
        }
    }
}
