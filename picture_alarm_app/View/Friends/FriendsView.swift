//
//  FriendsView.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/15.
//

import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.friends.isEmpty {
                    Text("まだ友達がいません")
                        .foregroundColor(.gray)
                } else {
                    List(viewModel.friends) { friend in
                        // 各行をタップすると、その友達のプロフィール画面に遷移
                        NavigationLink(destination: UserProfileView(user: friend)) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text(friend.name)
                                    .fontWeight(.semibold)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("友達")
            .onAppear {
                // 画面が表示された時に友達リストを取得
                Task {
                    await viewModel.fetchFriends()
                }
            }
        }
    }
}

#Preview {
    FriendsView()
}
