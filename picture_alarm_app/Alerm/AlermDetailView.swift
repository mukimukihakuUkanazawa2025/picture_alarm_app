//
//  AlermDetailView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

// 日付選択機能付きアラーム設定画面

import SwiftUI

struct AlermDetailView: View {
    @Binding var wakeUpTime: Date
    @Binding var leaveTime: Date
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var selectedMonth = Date()
    @State private var selectedDay = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    init(wakeUpTime: Binding<Date>, leaveTime: Binding<Date>) {
        self._wakeUpTime = wakeUpTime
        self._leaveTime = leaveTime
        self._selectedDate = State(initialValue: Date())
        self._selectedMonth = State(initialValue: Date())
        self._selectedDay = State(initialValue: Date())
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 時刻設定（ホイール）エリア
                VStack(spacing: 28) {
                    // 起床時間
                    VStack(spacing: 16) {
                        Text("起床時間")
                            .font(.headline)
                            .foregroundColor(.white)
                        DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .tint(.white)
                            .environment(\.colorScheme, .dark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color.gray.opacity(0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    // 出発時間
                    VStack(spacing: 16) {
                        Text("出発時間")
                            .font(.headline)
                            .foregroundColor(.white)
                        DatePicker("", selection: $leaveTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .tint(.white)
                            .environment(\.colorScheme, .dark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color.gray.opacity(0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                
                Spacer()
            }
            .background(Color.black)
            .navigationTitle("アラーム設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveAlarm()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            setupInitialDate()
        }
    }
    
    // MARK: - 計算プロパティ
    
    private var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年"
        return formatter.string(from: selectedDate)
    }
    
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter.string(from: selectedDate)
    }
    
    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate) else { return [] }
        return range.compactMap { day in
            calendar.date(bySetting: .day, value: day, of: selectedDate)
        }
    }
    
    // MARK: - メソッド
    
    private func setupInitialDate() {
        selectedDate = Date()
        selectedMonth = Date()
        selectedDay = Date()
    }
    
    private func selectDay(_ day: Date) {
        selectedDay = day
        selectedDate = day
    }
    
    private func isSelectedDay(_ day: Date) -> Bool {
        calendar.isDate(day, inSameDayAs: selectedDay)
    }
    
    private func dayText(_ day: Date) -> String {
        let dayNumber = calendar.component(.day, from: day)
        let isSelected = isSelectedDay(day)
        return isSelected ? "\(dayNumber)日" : "\(dayNumber)"
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func saveAlarm() {
        // 選択した日付と時刻を組み合わせてアラームを設定
        let combinedDate = calendar.date(bySettingHour: calendar.component(.hour, from: wakeUpTime),
                                       minute: calendar.component(.minute, from: wakeUpTime),
                                       second: 0, of: selectedDate) ?? selectedDate
        
        let combinedLeaveTime = calendar.date(bySettingHour: calendar.component(.hour, from: leaveTime),
                                            minute: calendar.component(.minute, from: leaveTime),
                                            second: 0, of: selectedDate) ?? selectedDate
        
        // AlarmServiceにアラームを追加
        AlarmService.shared.addAlarm(date: selectedDate, wakeUpTime: combinedDate, leaveTime: combinedLeaveTime)
        
        dismiss()
    }
}

#Preview {
    AlermDetailView(
        wakeUpTime: .constant(Date()),
        leaveTime: .constant(Date())
    )
}
