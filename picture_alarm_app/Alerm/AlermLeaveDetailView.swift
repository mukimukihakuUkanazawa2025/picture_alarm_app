//
//  AlermLeaveDetailView.swift
//  picture_alarm_app
//
//  Created by 酒井みな実 on 2025/09/17.
//

import SwiftUI
import UserNotifications

struct AlermLeaveDetailView: View {
    @Binding var wakeUpTime: Date
    @Binding var leaveTime: Date
    @Binding var isShowLeaveDetailView: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            Text("出発時間を設定")
                .font(.headline)
                .foregroundColor(.white)
            DatePicker(
                "",
                selection: $leaveTime,
                displayedComponents: [.hourAndMinute]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .tint(.orange)
            .environment(\.colorScheme, .dark)
            .frame(height: 200)
            .padding(.top, 24)
            .padding(.bottom, 32)
            
            HStack(spacing: 16) {
                Button("保存") {
                    saveAlarm()
                    isShowLeaveDetailView = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "FF8300"))
                .cornerRadius(12)
                .foregroundColor(.white)
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .presentationDetents([.fraction(0.75)])
        .presentationDragIndicator(.visible)
        .onAppear {
            setupInitialDate()
            requestNotificationAuthorization()
        }
    }
    
    // --- ロジックはそのまま保持 ---
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
        
        if combinedDate <= combinedLeaveTime {
            let gettedAlarm: AlarmData = AlarmService.shared.getAlarm(for: selectedDate)!
            AlarmService.shared.updateAlarm(
                id: gettedAlarm.id,
                date: selectedDate,
                wakeUpTime: combinedDate,
                leaveTime: combinedLeaveTime
            )
        }
    }
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _,_ in }
    }
}
