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
    @State var showFriendRequestView: Bool = false
    @State var showFriendsView: Bool = false
    
    var body: some View {
        VStack {
            Button {
                showAddFriendView.toggle()
            } label: {
                Text("フレンド追加画面へ")
            }
            .fullScreenCover(isPresented: $showAddFriendView) {
                AddFriendView()
            }
            Button {
                showFriendRequestView.toggle()
            } label: {
                Text("フレンド申請確認画面へ")
            }
            .fullScreenCover(isPresented: $showFriendRequestView) {
                FriendRequestsView()
            }
            Button {
                showFriendsView.toggle()
            } label: {
                Text("フレンド一覧画面へ")
            }
            .fullScreenCover(isPresented: $showFriendsView) {
                FriendsView()
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
}

#Preview {
    ProfileView()
}
