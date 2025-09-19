//
//  AlermView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

import SwiftUI
import UserNotifications
import SwiftData

struct AlermView: View {
    
    @State private var alarms: [AlarmData] = []
    
    @StateObject private var alarmService = AlarmService.shared
    
    @State private var wakeUpTime: Date = {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    }()
    @State private var leaveTime: Date = {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    }()
    
    @State private var showingAlarmDetail = false
    @State private var selectedDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var editedAlarm: AlarmData?
    @State private var isAlarmOn: Bool = true //toggle用
    
    // 起床時間/出発時間のモーダル表示フラグ
    @State private var isShowWakuUpDetailView = false
    @State private var isShowLeaveDetailView = false
    
    @State private var alarmstatus : alarmStatus = .unsetted
    @State private var alarmStatusText:String = "アラームが未設定です"
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                
                // --- 年 + 今日ボタン ---
                HStack {
                    Text(yearString)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(.white)
                   
                    Spacer()
                    
                    Button(action: { selectedDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()}) {
                        Text("今日")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Calendar.current.isDate(selectedDate, inSameDayAs: Date())
                                ? Color.gray.opacity(0.5)
                                : Color(hex: "FF8300")
                            )
                            .clipShape(Capsule())
                    }
                }
                
                .padding(.horizontal, 16)
                .padding(.top, 8)
                // --- 月/日セレクタ ---
                MonthSelector(selectedDate: $selectedDate)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                DaySelector(selectedDate: $selectedDate)
                    Divider()
                    
                    .background(.white)
                    .padding(.top,10)
                
                // --- toggle ---
                Toggle("アラーム", isOn: $isAlarmOn)
//                                        .labelsHidden()
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding()
                    .onChange(of: isAlarmOn) { newValue in
                        
                        let calendar = Calendar.current
                        selectedDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: selectedDate) ?? selectedDate
                        //                       // 時刻が変更されたら、既存のupdateAlarm関数を呼び出す
                        if let alarms = alarmService.getAlarm(for: selectedDate){
                            alarmService.updateAlarm(
                                id: alarms.id,
                                date: selectedDate,
                                wakeUpTime: wakeUpTime,
                                leaveTime: leaveTime,
                                isOn: newValue // 現在のトグルの値を渡す
                            )
                            
                        }
                    }
                Divider()
                    .background(.white)
                // --- 状態表示文章 ---
                    
                    switch alarmstatus {
                    case .setted:
                        HStack(alignment: .center){
                            Spacer()
                            Image(systemName:"clock.badge.checkmark.fill")
                            Text(" アラームは設定されています")
                            Spacer()
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 16)
                        .padding(.top)
                    case .unsetted:
                        HStack(alignment: .center){
                            Spacer()
                            Image(systemName:"clock.badge.xmark.fill")
                            Text(" アラームは設定されていません")
                            Spacer()
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 16)
                        .padding(.top)
                    case .error:
                        HStack(alignment: .center){
                            Spacer()
                            Image(systemName:"exclamationmark.triangle.fill")
                                .symbolRenderingMode(.multicolor)
                            Text("出発時刻よりも起床時刻が早くなっています！アラームは作動しません！")
                            Spacer()
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 16)
                        .padding(.top)
                    }
                    
            
                
                // --- 時刻カード ---
                VStack(spacing: 28) {
                    TimeCardView(title: "起床時刻", time: wakeUpTime)
                        .onTapGesture { isShowWakuUpDetailView = true }
                    
                    TimeCardView(title: "出発時刻", time: leaveTime)
                        .onTapGesture { isShowLeaveDetailView = true }
                }
                .padding(.horizontal, 16)
                .padding(.top, 28)
                
                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("")
//             --- 詳細編集シート ---
            .sheet(isPresented: $showingAlarmDetail) {
                AlermDetailView(wakeUpTime: $wakeUpTime, leaveTime: $leaveTime)
            }
            // --- 起床時間モーダル ---
            .sheet(isPresented: $isShowWakuUpDetailView) {
                AlermWakuUpDetailView(
                    wakeUpTime: $wakeUpTime,
                    leaveTime: $leaveTime,
                    isShowWakuUpDetailView: $isShowWakuUpDetailView,
                    alarmStatus: $alarmstatus,
                    selectedDate: $selectedDate
                )
                .presentationDetents([.fraction(0.75)]) // 下から 3/4 覆う
                .presentationDragIndicator(.visible)
            }
            // --- 出発時間モーダル ---
            .sheet(isPresented: $isShowLeaveDetailView) {
                AlermLeaveDetailView(
                    wakeUpTime: $wakeUpTime,
                    leaveTime: $leaveTime,
                    isShowLeaveDetailView: $isShowLeaveDetailView,
                    alarmStatus: $alarmstatus,
                    selectedDate: $selectedDate
                    
                )
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.visible)
            }
            // --- データの反映 ---
            .onAppear {
                selectedDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
                if let alarms = alarmService.getAlarm(for: selectedDate){
                    editedAlarm = alarmService.getAlarm(for: selectedDate)
                    wakeUpTime = editedAlarm?.wakeUpTime ?? wakeUpTime
                    leaveTime = editedAlarm?.leaveTime ?? leaveTime
                    
                    isAlarmOn = alarms.isOn//追加
                    
                    print(alarms.wakeUpTime)
                    print(alarms.leaveTime)
                    
                    alarmstatus = .setted
                } else {
                    editedAlarm?.date = selectedDate
                    editedAlarm?.wakeUpTime = wakeUpTime
                    editedAlarm?.leaveTime = leaveTime
                    
                    alarmstatus = .unsetted
                }
                
            }
            .onChange(of: selectedDate) { _ in
                
                alarmService.fetchAlarms()
                
                alarms = self.alarmService.alarms
                
                print(alarms)
                
                let calendar = Calendar.current
                selectedDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: selectedDate) ?? selectedDate
                
                if let alarm = alarmService.getAlarm(for: selectedDate){
//                    editedAlarm = alarms
                    wakeUpTime = alarm.wakeUpTime ?? wakeUpTime
                    leaveTime = alarm.leaveTime ?? leaveTime
                    isAlarmOn = alarm.isOn//ついか
                    
                    print(alarm.wakeUpTime)
                    print(alarm.leaveTime)
                    
                    alarmstatus = .setted
                } else {
//                    editedAlarm = AlarmData()
                    wakeUpTime = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
                    leaveTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
                    
//                    editedAlarm?.date = selectedDate
//                    editedAlarm?.wakeUpTime = wakeUpTime
//                    editedAlarm?.leaveTime = leaveTime
                    
                    
                    
                    alarmstatus = .unsetted
                }
                
               
            }
//            .onChange(of: wakeUpTime) { _ in
//                            guard let alarm = editedAlarm else { return }
//                            // 時刻が変更されたら、既存のupdateAlarm関数を呼び出す
//                            alarmService.updateAlarm(
//                                id: alarm.id,
//                                date: selectedDate,
//                                wakeUpTime: wakeUpTime,
//                                leaveTime: leaveTime,
//                                isOn: isAlarmOn // 現在のトグルの値を渡す
//                            )
//                        }

        }
    }
    
    // MARK: - 日付表示ユーティリティ
    private var yearString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年"
        return f.string(from: selectedDate)
    }
}

#Preview {
    AlermView()
}
