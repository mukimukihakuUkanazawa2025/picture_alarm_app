//
//  DepartureCountdownView.swift
//  picture_alarm_app
//
//  Created by 酒井みな実 on 2025/09/17.
//

import SwiftUI

struct DepartureCountdownView: View {
    let departureTime: Date                // 出発時刻
    let wakeUpImage: UIImage?              // 寝起きで撮影した写真
    
    @State private var remainingTime: TimeInterval = 0
    
    // Combine のタイマー（毎秒更新）
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // --- 出発まであとラベル ---
                Text("出発まであと")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // --- カウントダウン表示 ---
                Text(timeString(from: remainingTime))
                    .font(.system(size: 35, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // --- 寝起き写真を表示（円形に切り抜き） ---
                if let image = wakeUpImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 280, height: 280)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.orange, lineWidth: 5))
                        .clipped()
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 280, height: 280)
                        .overlay(Circle().stroke(Color.orange, lineWidth: 5))
                }
                
                Spacer()
            }
            .padding(.top, 60)
        }
        .onAppear {
            updateRemainingTime()
        }
        .onReceive(timer) { _ in
            updateRemainingTime()
        }
    }
    
    private func updateRemainingTime() {
        let now = Date()
        remainingTime = max(departureTime.timeIntervalSince(now), 0)
        
        // 出発時間になったらアラーム鳴動
        if remainingTime == 0 {
            AlarmService.shared.startAlarm()
        }
    }
    
    /// 残り時間を「xx時間xx分xx秒」または「xx分xx秒」に整形
    private func timeString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        if hours > 0 {
            return String(format: "%02d時間%02d分%02d秒", hours, minutes, seconds)
        } else {
            return String(format: "%02d分%02d秒", minutes, seconds)
        }
    }
}

#Preview {
    DepartureCountdownView(
        departureTime: Date().addingTimeInterval(3600 + 290), // 1時間後
        wakeUpImage: UIImage(systemName: "person.fill")        // 仮の画像
    )
}
//import SwiftUI
//
//struct DepartureCountdownView: View {
//    let departureTime: Date
//    let wakeUpImage: UIImage?  // 寝起きで撮影した写真を受け取る
//
//    @State private var remainingTime: TimeInterval = 0
//    @State private var timer: Timer? = nil
//    
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//            
//            VStack(spacing: 32) {
//                // --- 出発まであとラベル ---
//                Text("出発まであと")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                
//                // --- カウントダウン表示 ---
//                Text(timeString(from: remainingTime))
//                    .font(.system(size: 35, weight: .bold, design: .rounded))
//                    .foregroundColor(.white)
//                
//                // --- 寝起き写真を表示（円形に切り抜き） ---
//                Image(uiImage: wakeUpImage)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 280, height: 280)
//                    .clipShape(Circle())
//                    .overlay(
//                        Circle().stroke(Color.orange, lineWidth: 5)
//                    )
//                    .clipped()
//                
//                Spacer()
//            }
//            .padding(.top, 60)
//        }
//        .onAppear {
//            updateRemainingTime()
//            startTimer()
//        }
//        .onDisappear {
//            timer?.invalidate()
//        }
//    }
//    
//    private func updateRemainingTime() {
//        let now = Date()
//        remainingTime = max(departureTime.timeIntervalSince(now), 0)
//    }
//    
//    private func startTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            updateRemainingTime()
//        }
//    }
//    
//    private func timeString(from interval: TimeInterval) -> String {
//        let hours = Int(interval) / 3600
//        let minutes = (Int(interval) % 3600) / 60
//        let seconds = Int(interval) % 60
//        if hours > 0 {
//            return String(format: "%02d時間%02d分%02d秒", hours, minutes, seconds)
//        } else {
//            return String(format: "%02d分%02d秒", minutes, seconds)
//        }
//    }
//}
//
//#Preview {
//    // ダミー画像を入れてプレビュー
//    DepartureCountdownView(
//        departureTime: Date().addingTimeInterval(3600 + 290),
//        wakeUpImage: UIImage(systemName: "person.fill")! // 仮の画像
//    )
//}
