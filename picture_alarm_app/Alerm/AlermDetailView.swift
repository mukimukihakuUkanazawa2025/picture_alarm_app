//
//  AlermDetailView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

import SwiftUI
import UserNotifications

// 日付選択機能付きアラーム設定画面
struct AlermDetailView: View {
    @Binding var wakeUpTime: Date
    @Binding var leaveTime: Date
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 時刻設定（ホイール）エリア
                VStack(spacing: 28) {
                    // 起床時間
                    VStack(spacing: 16) {
                        Text("起床時間")
                            .font(.headline)
                            .foregroundColor(.white)
                        DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .tint(.white)
                            .environment(\.colorScheme, .dark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color.gray.opacity(0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    // 出発時間
                    VStack(spacing: 16) {
                        Text("出発時間")
                            .font(.headline)
                            .foregroundColor(.white)
                        DatePicker("", selection: $leaveTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .tint(.white)
                            .environment(\.colorScheme, .dark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color.gray.opacity(0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                
                Spacer()
            }
            .background(Color.black)
            .navigationTitle("アラーム設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveAlarm()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            setupInitialDate()
            requestNotificationAuthorization()
        }
    }
    
    // MARK: - メソッド
    private func setupInitialDate() { selectedDate = Date() }
    
    private func saveAlarm() {
        let combinedDate = calendar.date(
            bySettingHour: calendar.component(.hour, from: wakeUpTime),
            minute: calendar.component(.minute, from: wakeUpTime),
            second: 0,
            of: selectedDate
        ) ?? selectedDate
        
        let combinedLeaveTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: leaveTime),
            minute: calendar.component(.minute, from: leaveTime),
            second: 0,
            of: selectedDate
        ) ?? selectedDate
        
        if let gettedAlarm = AlarmService.shared.getAlarm(for: selectedDate) {
            AlarmService.shared.updateAlarm(
                id: gettedAlarm.id,
                date: selectedDate,
                wakeUpTime: combinedDate,
                leaveTime: combinedLeaveTime, isOn: false
            )
        }
        dismiss()
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _,_ in }
    }
}

#Preview {
    AlermDetailView(
        wakeUpTime: .constant(Date()),
        leaveTime: .constant(Date())
    )
}
