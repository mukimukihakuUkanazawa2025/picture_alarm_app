//
//  AlarmStartView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/16.
//

import SwiftUI

struct AlarmStartView: View {
    
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var alarmService = AlarmService.shared
    
    @State var wakeupTimeText = ""
    @State var leaveTimeText = ""
    
    @State var isAlarmStart = false
    
    
    
    var body: some View {
        
        NavigationStack{
            VStack{
                if alarmService.isAlarmOn && !alarmService.isPrepareDone {
                    AlarmPrepareView()
                    
                }else{
                    AlarmDoneView()
                }
                
                
                
            }.onAppear{
                
                alarmService.fetchAlarms()
                
                //当日のアラームが設定されていなかったらアラーム待機画面にしない
                if alarmService.getTodayAlarm() == nil{
                    alarmService.isAlarmOn = false
                }
                
                alarmService.isAlarmOn = true
                
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .medium
                
                
                if let currentAlarm = alarmService.currentAlarm {
                    
                    wakeupTimeText = formatter.string(for: currentAlarm.wakeUpTime)!
                    leaveTimeText = formatter.string(for: currentAlarm.leaveTime)!
                    
                }
                
                
                
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "multiply")
                        }
                    ).tint(.white)
                }
            }
        }
        
    }
    
    
}

#Preview {
    AlarmStartView()
}
