//
//  AlermView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

import SwiftUI
import UserNotifications
import SwiftData

struct AlermView: View {
    @StateObject private var alarmService = AlarmService.shared
    
    @State private var wakeUpTime: Date = {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    }()
    @State private var leaveTime: Date = {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    }()
    
    @State private var showingAlarmDetail = false
    @State private var selectedDate = Date()
    @State private var editedAlarm: AlarmData?
    
    // 起床時間/出発時間のモーダル表示フラグ
    @State private var isShowWakuUpDetailView = false
    @State private var isShowLeaveDetailView = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                
                // --- 年 + 今日ボタン ---
                HStack {
                    Text(yearString)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { selectedDate = Date() }) {
                        Text("今日")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Calendar.current.isDate(selectedDate, inSameDayAs: Date())
                                ? Color.gray
                                : Color(hex: "FF8300")
                            )
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // --- 月/日セレクタ ---
                MonthSelector(selectedDate: $selectedDate)
                    .padding(.bottom, 16)
                DaySelector(selectedDate: $selectedDate)
                
                // --- 時刻カード ---
                VStack(spacing: 28) {
                    TimeCardView(title: "起床時間", time: wakeUpTime)
                        .onTapGesture { isShowWakuUpDetailView = true }
                    
                    TimeCardView(title: "出発時間", time: leaveTime)
                        .onTapGesture { isShowLeaveDetailView = true }
                }
                .padding(.horizontal, 16)
                .padding(.top, 28)
                
                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: { showingAlarmDetail = true }) {
//                        Image(systemName: "pencil")
//                            .foregroundColor(.white)
//                    }
//                }
//            }
//             --- 詳細編集シート ---
            .sheet(isPresented: $showingAlarmDetail) {
                AlermDetailView(wakeUpTime: $wakeUpTime, leaveTime: $leaveTime)
            }
            // --- 起床時間モーダル ---
            .sheet(isPresented: $isShowWakuUpDetailView) {
                AlermWakuUpDetailView(
                    wakeUpTime: $wakeUpTime,
                    leaveTime: $leaveTime,
                    isShowWakuUpDetailView: $isShowWakuUpDetailView
                )
                .presentationDetents([.fraction(0.75)]) // 下から 3/4 覆う
                .presentationDragIndicator(.visible)
            }
            // --- 出発時間モーダル ---
            .sheet(isPresented: $isShowLeaveDetailView) {
                AlermLeaveDetailView(
                    wakeUpTime: $wakeUpTime,
                    leaveTime: $leaveTime,
                    isShowLeaveDetailView: $isShowLeaveDetailView
                )
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.visible)
            }
            // --- データの反映 ---
            .onAppear {
                selectedDate = Date()
                editedAlarm = alarmService.getAlarm(for: selectedDate)
                wakeUpTime = editedAlarm?.wakeUpTime ?? wakeUpTime
                leaveTime = editedAlarm?.leaveTime ?? leaveTime
            }
            .onChange(of: selectedDate) { _ in
                editedAlarm = alarmService.getAlarm(for: selectedDate)
                wakeUpTime = editedAlarm?.wakeUpTime ?? wakeUpTime
                leaveTime = editedAlarm?.leaveTime ?? leaveTime
            }
            .onChange(of: wakeUpTime) { _ in
                if let gettedAlarm = alarmService.getAlarm(for: selectedDate) {
                    alarmService.updateAlarm(
                        id: gettedAlarm.id,
                        date: selectedDate,
                        wakeUpTime: wakeUpTime,
                        leaveTime: leaveTime
                    )
                }
            }
            .onChange(of: leaveTime) { _ in
                if let gettedAlarm = alarmService.getAlarm(for: selectedDate) {
                    alarmService.updateAlarm(
                        id: gettedAlarm.id,
                        date: selectedDate,
                        wakeUpTime: wakeUpTime,
                        leaveTime: leaveTime
                    )
                }
            }
        }
    }
    
    // MARK: - 日付表示ユーティリティ
    private var yearString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年"
        return f.string(from: selectedDate)
    }
}

#Preview {
    AlermView()
}
