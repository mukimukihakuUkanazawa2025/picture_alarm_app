//
//  AlarmStartView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/16.
//

import SwiftUI

struct AlarmStartView: View {
    @StateObject private var alarmService = AlarmService.shared
    
    @State var wakeupTimeText = ""
    @State var leaveTimeText = ""
    
    @State var isAlarmStart = false
    
    var body: some View {
        VStack{
            Text("\(wakeupTimeText)")
            Text("\(leaveTimeText)")
            
        }.onAppear{
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .medium
            
            wakeupTimeText = formatter.string(for: alarmService.currentAlarm!.wakeUpTime) ?? ""
            leaveTimeText = formatter.string(from: alarmService.currentAlarm!.leaveTime) ?? ""
        }
    }
    
  
}

#Preview {
    AlarmStartView()
}
