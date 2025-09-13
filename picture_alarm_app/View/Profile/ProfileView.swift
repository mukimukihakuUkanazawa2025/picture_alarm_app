//
//  ProfileView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

// 自分の投稿情報やアカウント設定を行う画面

import SwiftUI

struct ProfileView: View {
    
    @State var showAddFriendView: Bool = false
    @State var showSettingView: Bool = false
    
    var body: some View {
        Button {
            showAddFriendView.toggle()
        } label: {
            Text("フレンド追加画面へ")
        }
        .fullScreenCover(isPresented: $showAddFriendView) {
            AddFriendView()
        }
        
        
        Button {
            showSettingView.toggle()
        } label: {
            Text("設定画面へ")
        }
        .fullScreenCover(isPresented: $showSettingView) {
            SettingView()
        }
    }
}

#Preview {
    ProfileView()
}
