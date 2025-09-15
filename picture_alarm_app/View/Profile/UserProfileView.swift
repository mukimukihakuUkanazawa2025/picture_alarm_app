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
    
    @State private var isShowingRemoveFriendAlert = false
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
                    Button("申請を取り消す") {
                        Task{
                            await viewModel.cancelRequest()
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.gray)
                case .requestReceived:
                    Button("🎉 承認する") {
                        Task{
                            await viewModel.acceptRequest()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    
                case .friends:
                    Button("友達から削除") {
                        isShowingRemoveFriendAlert = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
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
        .alert("友達から削除", isPresented: $isShowingRemoveFriendAlert) {
                    Button("削除", role: .destructive) {
                        Task {
                            await viewModel.removeFriend()
                        }
                    }
                } message: {
                    Text("\(viewModel.profileUser.name)さんを友達から削除しますか？この操作は取り消せません。")
                }
    }
}

//#Preview {
//    UserProfileView()
//}
