//
//  UserProfileView.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import SwiftUI

struct UserProfileView: View {
    // StateObjectとしてViewModelを初期化
    @StateObject private var viewModel: UserProfileViewModel
    
    // このViewは表示したいユーザー情報を受け取って初期化される
    init(user: User) {
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(user: user))
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // プロフィール情報
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text(viewModel.profileUser.name)
                .font(.title)
                .fontWeight(.bold)
            
            // 友達関係ボタン
            if viewModel.isLoading {
                ProgressView()
            } else {
                // ViewModelの状態に応じてボタンを切り替え
                switch viewModel.friendshipStatus {
                case .none:
                    Button("🤝 友達になる") {
                        Task{
                            await viewModel.sendRequest()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                case .requestSent:
                    Button("✅ 申請済み") {
                        // ここで申請取り消しロジックを呼ぶこともできる
                    }
                    .buttonStyle(.bordered)
                    .disabled(true)
                    
                case .requestReceived:
                    Button("🎉 承認する") {
                        Task{
                            await viewModel.acceptRequest()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    
                case .friends:
                    Button("🧑‍🤝‍🧑 友達です") {
                        // ここで友達解除ロジックを呼ぶこともできる
                    }
                    .buttonStyle(.bordered)
                    .disabled(true)
                }
            }
        }
        .padding()
        .onAppear {
            // 画面が表示されたら、友達関係のチェックを開始する
            Task {
                await viewModel.checkFriendshipStatus()
            }
        }
    }
}

//#Preview {
//    UserProfileView()
//}
