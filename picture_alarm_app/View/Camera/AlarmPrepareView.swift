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
            
            if alarmService.currentAlarm!.isWakeup && !alarmService.currentAlarm!.isLeave {
                    
                    DepartureCountdownView(departureTime:  alarmService.currentAlarm!.leaveTime, wakeUpImage: UIImage(systemName: "house"))
                    
                   

            } else if !alarmService.currentAlarm!.isWakeup{
                
                CameraViewWrapper()
                
            }else{
                Text("アラームが設定されていないよ！")
            }
            
            
        }.onAppear{
            
            alarmService.fetchAlarms()
            
            //当日のアラームが設定されていなかったらアラーム待機画面にしない
            if alarmService.getTodayAlarm() == nil{
                alarmService.isAlarmOn = false
            }else{
                alarmService.isAlarmOn = true
                
                alarmService.updateAlarmStatus(id: alarmService.currentAlarm!.id, isOn: true, isWakeup: false, isLeave: false)
                
            }
            UserDefaults.standard.set(alarmService.isAlarmOn, forKey: "isAlarmOn")
            
            
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

#Preview {
    AlarmPrepareView()
}
