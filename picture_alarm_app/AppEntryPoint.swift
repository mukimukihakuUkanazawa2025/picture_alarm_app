//
//  AppEntryPoint.swift
//  picture_alarm_app
//
//  Created by 酒井みな実 on 2025/09/19.
//

import SwiftUI
import FirebaseAuth

struct AppEntryPoint: View {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        Group {
            if !hasLaunchedBefore {
                // 初回起動 → チュートリアル
                TutorialView {
                    hasLaunchedBefore = true
                }
            } else {
                if isLoggedIn {
                    // ログイン済みなら TLView から開始
                    ContentView()
                } else {
                    // 未ログインなら EntryView へ
                    EntryView()
                }
            }
        }
        .onAppear {
            checkAuthStatus()
        }
    }
    
    private func checkAuthStatus() {
        if Auth.auth().currentUser != nil {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
}
