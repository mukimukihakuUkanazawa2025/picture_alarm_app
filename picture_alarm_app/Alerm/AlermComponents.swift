//
//  AlermComponents.swift
//  picture_alarm_app
//
//  Created by 酒井みな実 on 2025/09/17.
//

import SwiftUI

// 月選択コンポーネント
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
            comps.hour = 12 // タイムゾーン問題を避けるため正午に設定
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
        ScrollViewReader { proxy in
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
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(isSameMonth(monthDate, selectedDate) ? Color.white : Color.clear)
                                )
                        }
                        .id(monthDate)
                    }
                }
                .padding(.horizontal, 16)
            }
            .onChange(of: selectedDate) { newDate in
                withAnimation {
                    scrollToCenter(for: newDate, proxy: proxy)
                }
            }
            .onAppear {
                scrollToCenter(for: selectedDate, proxy: proxy)
            }
        }
    }
    
    private func scrollToCenter(for date: Date, proxy: ScrollViewProxy) {
        var components = calendar.dateComponents([.year, .month], from: date)
        components.day = 1
        components.hour = 12
        
        if let startOfMonth = calendar.date(from: components) {
            proxy.scrollTo(startOfMonth, anchor: .center)
        }
    }
}

// 日付選択コンポーネント
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
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(daysInMonth, id: \.self) { day in
                        Button(action: { selectedDate = day }) {
                            Text(dayNumberString(day))
                                .font(.title3)
                                .foregroundColor(isSelectedDay(day) ? Color.white : Color.gray)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(isSelectedDay(day) ? Color(hex: "FF8300") : Color.clear)
                                )
                        }
                        .padding(.horizontal, 2)
                    }
                }
                .padding(.horizontal, 16)
            }
            .onChange(of: selectedDate) { newDate in
                withAnimation {
                    proxy.scrollTo(newDate, anchor: .center)
                }
            }
        }
    }
}

// 時刻表示カード
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
