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
    
    @Binding var isShowingSecondModal: Bool
    
    let onDismissAll: () -> Void
    
    var body: some View {
        VStack{
            
            if alarmService.currentAlarm!.isWakeup && !alarmService.currentAlarm!.isLeave {
                    
                DepartureCountdownView(departureTime:  alarmService.currentAlarm!.leaveTime, wakeUpImage: UIImage(systemName: "house"), onDismissAll: onDismissAll, isShowingSecondModal: $isShowingSecondModal)
                    
                   

            } else if !alarmService.currentAlarm!.isWakeup && !alarmService.currentAlarm!.isLeave{
                
                CameraViewWrapper(isShowingSecondModal: $isShowingSecondModal, onDismissAll: onDismissAll)
                
            }else{
                Text("アラームが設定されていないよ！")
            }
            
            
        }.onAppear{
            
            alarmService.fetchAlarms()
            
            alarmService.setTodayAlarm()
            
            
            //当日のアラームが設定されていなかったらアラーム待機画面にしない
            if alarmService.getTodayAlarm() == nil{
                print("nosetting😉")
                alarmService.isAlarmOn = false
//                UserDefaults.standard.set(alarmService.isAlarmOn, forKey: "isAlarmOn")
            }else{
                print("設定おk🥶")
                alarmService.isAlarmOn = true
//                UserDefaults.standard.set(alarmService.isAlarmOn, forKey: "isAlarmOn")
                
//                alarmService.updateAlarmStatus(id: alarmService.currentAlarm!.id, isOn: true, isWakeup: false, isLeave: false)
                
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

//#Preview {
//    AlarmPrepareView()
//}
