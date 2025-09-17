//
//  AlermWakuUpDetailView.swift
//  picture_alarm_app
//
//  Created by 酒井みな実 on 2025/09/17.
//

import SwiftUI
import UserNotifications

struct AlermWakuUpDetailView: View {
    @Binding var wakeUpTime: Date
    @Binding var leaveTime: Date
    @Binding var isShowWakuUpDetailView: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
//            Capsule()
//                .fill(Color.gray.opacity(0.5))
//                .frame(width: 40, height: 6)
            
            Text("起床時間を設定")
                .font(.headline)
                .foregroundColor(.white)
//                .padding(.top, 16)
            
//            DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
//                .datePickerStyle(.wheel)
//                .labelsHidden()
//                .tint(.orange)
//                .environment(\.colorScheme, .dark)
//                .frame(height: 200)
//                .padding(.top, 24)

            DatePicker(
                "",
                selection: $wakeUpTime,
                displayedComponents: .hourAndMinute
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
                    isShowWakuUpDetailView = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "FF8300"))
                .cornerRadius(12)
                .foregroundColor(.white)
                .padding(.bottom, 60)
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
        dismiss()
    }
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _,_ in }
    }
}
