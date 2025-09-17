//
//  AlermView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

// アラーム一覧/当日表示UI

import SwiftUI
import UserNotifications
import SwiftData

struct AlermView: View {
    
//    @Query private var alarmdata: [AlarmData]
//    @Environment(\.modelContext) private var context
    
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
    @State private var selectedDate = Date()
    
    @State private var editedAlarm: AlarmData?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(yearString)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(.white)
                    MonthSelector(selectedDate: $selectedDate)
                    DaySelector(selectedDate: $selectedDate)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                VStack(spacing: 28) {
                    TimeCardView(title: "起床時間", time: wakeUpTime)
                    TimeCardView(title: "出発時間", time: leaveTime)
                }
                .padding(.horizontal, 16)
                .padding(.top, 28)

                Spacer()
            }
            .onAppear{
            }
            .onChange(of: selectedDate){
                
                //日付に合うアラームを取得
                editedAlarm =  alarmService.getAlarm(for: selectedDate)
                
                
                
                wakeUpTime = editedAlarm!.wakeUpTime
                leaveTime = editedAlarm!.leaveTime
                
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAlarmDetail = true }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingAlarmDetail) {
                AlermDetailView(wakeUpTime: $wakeUpTime, leaveTime: $leaveTime)
            }
            .onAppear {
                
                //その日のアラームを取得
                selectedDate = Date()
                editedAlarm =  alarmService.getAlarm(for: selectedDate)
                
                wakeUpTime = editedAlarm!.wakeUpTime
                leaveTime = editedAlarm!.leaveTime
            }
            .onChange(of: wakeUpTime) { _ in
                
                let gettedAlarm:AlarmData = alarmService.getAlarm(for: selectedDate)!
                
                alarmService.updateAlarm(id: gettedAlarm.id, date: selectedDate, wakeUpTime: wakeUpTime, leaveTime: leaveTime)
                
                //                if let todayAlarm = alarmService.getTodayAlarm() {
                //                    alarmService.updateAlarm(id: todayAlarm.id, date: selectedDate, wakeUpTime: wakeUpTime, leaveTime: leaveTime)
                //                } else {
                //                    alarmService.addAlarm(date: selectedDate, wakeUpTime: wakeUpTime, leaveTime: leaveTime)
                //                }
            }
            .onChange(of: leaveTime) { _ in
                let gettedAlarm:AlarmData = alarmService.getAlarm(for: selectedDate)!
                
                alarmService.updateAlarm(id: gettedAlarm.id, date: selectedDate, wakeUpTime: wakeUpTime, leaveTime: leaveTime)
//
//                if let todayAlarm = alarmService.getTodayAlarm() {
//                    alarmService.updateAlarm(id: todayAlarm.id, date: selectedDate, wakeUpTime: wakeUpTime, leaveTime: leaveTime)
//                } else {
//                    alarmService.addAlarm(date: selectedDate, wakeUpTime: wakeUpTime, leaveTime: leaveTime)
//                }
            }
        }
    }
    
    // MARK: - テスト用メソッド
    
    private func setWakeUpTimeOneMinuteLater() {
        let calendar = Calendar.current
        wakeUpTime = calendar.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
    }
    
    private func setLeaveTimeOneMinuteLater() {
        let calendar = Calendar.current
        leaveTime = calendar.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
    }
    
    private func setCurrentTimeOneMinuteLater() {
        // 現在時刻を1分後に設定（テスト用）
        let calendar = Calendar.current
        let oneMinuteLater = calendar.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
        
        // 起床時刻を現在時刻の1分後に設定
        wakeUpTime = oneMinuteLater
        
        // 出発時刻を起床時刻の1時間後に設定
        leaveTime = calendar.date(byAdding: .hour, value: 1, to: oneMinuteLater) ?? oneMinuteLater
    }

    // MARK: - 日付表示ユーティリティ
    private var calendar: Calendar { Calendar.current }
    private var yearString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年"
        return f.string(from: selectedDate)
    }
    private var monthString: String {
        let f = DateFormatter()
        f.dateFormat = "M月"
        return f.string(from: selectedDate)
    }
    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate) else { return [] }
        return range.compactMap { day in
            calendar.date(bySetting: .day, value: day, of: selectedDate)
        }
    }
    private func selectDay(_ day: Date) { selectedDate = day }
    private func isSelectedDay(_ day: Date) -> Bool { calendar.isDate(day, inSameDayAs: selectedDate) }
    private func dayNumberString(_ day: Date) -> String { String(calendar.component(.day, from: day)) }
    private func timeString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    // 月選択用
    private var monthsInYear: [Date] {
        let year = calendar.component(.year, from: selectedDate)
        return (1...12).compactMap { month -> Date? in
            var comps = DateComponents()
            comps.year = year
            comps.month = month
            comps.day = 1
            return calendar.date(from: comps)
        }
    }
    private func monthString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M月"
        return f.string(from: date)
    }
    private func isSameMonth(_ lhs: Date, _ rhs: Date) -> Bool {
        let l = calendar.dateComponents([.year, .month], from: lhs)
        let r = calendar.dateComponents([.year, .month], from: rhs)
        return l.year == r.year && l.month == r.month
    }
    private func setMonth(_ monthDate: Date) {
        let currentDay = calendar.component(.day, from: selectedDate)
        let range = calendar.range(of: .day, in: .month, for: monthDate) ?? 1..<29
        var comps = calendar.dateComponents([.year, .month], from: monthDate)
        comps.day = min(currentDay, range.count)
        selectedDate = calendar.date(from: comps) ?? monthDate
    }
}

// MARK: - Subviews

struct MonthSelector: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    
    private var monthsInYear: [Date] {
        let year = calendar.component(.year, from: selectedDate)
        return (1...12).compactMap { month -> Date? in
            var comps = DateComponents()
            comps.year = year
            comps.month = month
            comps.day = 1
            return calendar.date(from: comps)
        }
    }
    
    private func monthString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M月"
        return f.string(from: date)
    }
    
    private func isSameMonth(_ lhs: Date, _ rhs: Date) -> Bool {
        let l = calendar.dateComponents([.year, .month], from: lhs)
        let r = calendar.dateComponents([.year, .month], from: rhs)
        return l.year == r.year && l.month == r.month
    }
    
    private func setMonth(_ monthDate: Date) {
        let currentDay = calendar.component(.day, from: selectedDate)
        let range = calendar.range(of: .day, in: .month, for: monthDate) ?? 1..<29
        var comps = calendar.dateComponents([.year, .month], from: monthDate)
        comps.day = min(currentDay, range.count)
        selectedDate = calendar.date(from: comps) ?? monthDate
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(monthsInYear, id: \.self) { monthDate in
                    Button(action: { setMonth(monthDate) }) {
                        Text(monthString(from: monthDate))
                            .font(.title3)
                            .foregroundColor(isSameMonth(monthDate, selectedDate) ? .black : .white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(isSameMonth(monthDate, selectedDate) ? Color.white : Color.clear)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct DaySelector: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    
    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate) else { return [] }
        return range.compactMap { day in
            calendar.date(bySetting: .day, value: day, of: selectedDate)
        }
    }
    
    private func isSelectedDay(_ day: Date) -> Bool { calendar.isDate(day, inSameDayAs: selectedDate) }
    private func dayNumberString(_ day: Date) -> String { String(calendar.component(.day, from: day)) }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(daysInMonth, id: \.self) { day in
                    Button(action: { selectedDate = day }) {
                        Text(dayNumberString(day))
                            .font(.title2)
                            .foregroundColor(isSelectedDay(day) ? Color.white : Color.gray)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(isSelectedDay(day) ? Color.orange : Color.clear)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct TimeCardView: View {
    let title: String
    let time: Date
    
    private func timeString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(timeString(from: time))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.gray.opacity(0.28))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    AlermView()
}
