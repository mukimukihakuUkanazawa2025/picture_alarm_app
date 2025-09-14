//
//  TestPostView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/14.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct TestPostView: View {
    @StateObject private var viewModel = DayRecordViewModel()
    
    @State private var wakeUpTime: Date = Date()   // 起床時刻
    @State private var leaveTime: Date = Date()    // 出発時刻
    
    @State private var message: String = ""        // 保存結果
    
    var body: some View {
        VStack(spacing: 20) {
            Text("テスト投稿画面")
                .font(.headline)
            
            // 起床時刻入力
            VStack(alignment: .leading) {
                Text("起床時刻")
                DatePicker(
                    "起床時刻を選択",
                    selection: $wakeUpTime,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden() // ラベル非表示（シンプルにする）
            }
            .padding(.horizontal)
            
            // 出発時刻入力
            VStack(alignment: .leading) {
                Text("出発時刻")
                DatePicker(
                    "出発時刻を選択",
                    selection: $leaveTime,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
            }
            .padding(.horizontal)
            
            Button("Firestoreに保存") {
                viewModel.saveDayrecord(
                    wakeUpTime: wakeUpTime,
                    leaveTime: leaveTime
                ) { error in
                    if let error = error {
                        message = "保存失敗: \(error.localizedDescription)"
                    } else {
                        message = "保存成功！"
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
            
            Text(message)
                .foregroundColor(.blue)
                .padding()
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    TestPostView()
}
