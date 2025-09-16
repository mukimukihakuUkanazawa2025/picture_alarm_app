//
//  CameraHomeView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/16.
//

import SwiftUI

struct CameraHomeView: View {
    @StateObject private var alarmService: AlarmService = .shared
    
    var body: some View {
        if alarmService.isAlarmOn {
            AlarmStartView()
        }
    }
}

#Preview {
    CameraHomeView()
}
