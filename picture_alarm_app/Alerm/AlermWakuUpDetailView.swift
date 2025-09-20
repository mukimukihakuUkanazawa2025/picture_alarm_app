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
    @Binding var alarmStatus:alarmStatus
    @Binding var selectedDate:Date
    @Binding var alarmOntoggle:Bool
    @Environment(\.dismiss) private var dismiss
    
//    @State private var selectedDate = Date()
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            Text("起床時間を設定")
                .font(.headline)
                .foregroundColor(.white)
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
                    if alarmOntoggle{
                        saveAlarm()
                    }
                    
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
//            setupInitialDate()
            requestNotificationAuthorization()
        }
        
    }
    
    // --- ロジックはそのまま保持 ---
    //    private func setupInitialDate() { selectedDate = Date() }
        private func saveAlarm() {
            print(selectedDate)
            
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
            
            print("DEBUG: if文の直前のselectedDateの値 -> \(selectedDate)")
            
            if combinedDate <= combinedLeaveTime {
                if  Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                    if let alarms =  AlarmService.shared.getAlarm(for: selectedDate){
                        AlarmService.shared.updateAlarm(
                            id: alarms.id,
                            date: selectedDate,
                            wakeUpTime: combinedDate,
                            leaveTime: combinedLeaveTime,
                            isOn: true,
                            
                        )
                        
                        AlarmService.shared.updateAlarmStatus(id: alarms.id, isOn: true, isWakeup: false, isLeave: false)
                        
                    } else {

    //                    wakeUpTime = combinedDate
    //                    leaveTime = combinedLeaveTime
                        
                        AlarmService.shared.addAlarm(date: selectedDate, wakeUpTime: combinedDate, leaveTime: combinedLeaveTime, isOn: true)
//                        AlarmService.shared.updateAlarmStatus(id: alarms.id, isOn: true, isWakeup: false, isLeave: false)
                    }
                    
//                    let background = BackgroundTasks()
//                    background.scheduleDepaturePostSetup()
                    
                    print("a")
                } else {
                    if let alarms =  AlarmService.shared.getAlarm(for: selectedDate){
                        AlarmService.shared.updateAlarm(
                            id: alarms.id,
                            date: selectedDate,
                            wakeUpTime: combinedDate,
                            leaveTime: combinedLeaveTime,
                            isOn:false
                        )
                    } else {
                        var newAlarm :AlarmData?
                        newAlarm?.date = selectedDate
                        newAlarm?.wakeUpTime = combinedDate
                        newAlarm?.leaveTime = combinedLeaveTime
                        AlarmService.shared.addAlarm(date: selectedDate, wakeUpTime: combinedDate, leaveTime: combinedLeaveTime,isOn: false)
                    }
                    
                    print("b")
                }
                
                alarmStatus = .setted
                
                print(AlarmService.shared.getAlarm(for: selectedDate)?.date)
                print(AlarmService.shared.getAlarm(for: selectedDate)?.wakeUpTime)
                print(AlarmService.shared.getAlarm(for: selectedDate)?.leaveTime)

            } else{
                alarmStatus = .error
            }
            
            print(AlarmService.shared.getAlarm(for: selectedDate))
            
            dismiss()
        }

    

    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _,_ in }
    }
}

