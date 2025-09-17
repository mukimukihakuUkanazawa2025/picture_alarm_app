//
//  AlarmPrepareView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/16.
//

import SwiftUI

struct AlarmPrepareView: View {
    
    @StateObject private var alarmService = AlarmService.shared
    
    @State var wakeupTimeText = ""
    @State var leaveTimeText = ""
    
    @State var isAlarmStart = false
    
    var body: some View {
        VStack{
            
            if alarmService.isWakeupnow && alarmService.currentAlarm != nil{
                if Date() >= alarmService.currentAlarm!.leaveTime{
                    
                    
                    CameraHomeView()
                    
                }
                Text("\(leaveTimeText)")
            } else if !alarmService.isWakeupnow && alarmService.currentAlarm != nil{
                if Date() >= alarmService.currentAlarm!.wakeUpTime{
                   
                    
                    CameraHomeView()
                    
                }
                Text("\(wakeupTimeText)")
            }else{
                Text("アラームが設定されていないよ！")
            }
            
            
        }.onAppear{
            
            alarmService.setTodayAlarm()
            
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
    }
    
}
//
//#Preview {
//    AlarmPrepareView()
//}
