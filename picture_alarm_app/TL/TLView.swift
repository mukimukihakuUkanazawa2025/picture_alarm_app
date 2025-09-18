//
//  TLView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

// 自分や他人の投稿を表示する画面

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TLView: View {
    @StateObject private var viewModel = PostListViewModel()
    
//    // ログイン中のユーザー名を保持
//    private var currentUserName: String? {
//        Auth.auth().currentUser?.displayName
//    }
    
    private var currentUserId: String?{
        Auth.auth().currentUser?.uid
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                if viewModel.posts.isEmpty {
                    Text("まだ投稿はありません")
                        .foregroundStyle(.gray)
                        .padding()
                } else {
                    
                
                        // 投稿をリスト表示 ---
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.posts) { post in
                                PostRowView(post: post)
                                    .padding(.horizontal)
                            }
                        }
                    
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("タイムライン")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("タイムライン")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .tint(.white)
    }
}
#Preview {
    TLView()
}
