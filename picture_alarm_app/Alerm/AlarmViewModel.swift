//
//  AlarmViewModel.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/17.
//
//
//import SwiftUI
//import SwiftData
//
//// ObservableObjectに準拠させることで、ViewがViewModelの変更を監視できるようになる
//@MainActor // UIの更新はメインスレッドで行うため
//class AlarmViewModel: ObservableObject {
//    
//    private let alarmService: AlarmService
//    
//    // ViewModelの初期化時にModelContextを受け取る
//    init(modelContext: ModelContext) {
//        // 受け取ったcontextを使ってServiceを初期化する
//        self.alarmService = AlarmService(modelContext: modelContext)
//    }
//    
////    // Viewから呼び出される関数
////    func saveButtonTapped() {
////        print("Save button was tapped in ViewModel.")
////        alarmService.saveAlarm()
////    }
//}
