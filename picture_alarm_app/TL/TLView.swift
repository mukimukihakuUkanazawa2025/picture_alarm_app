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
    // ▼▼▼ 自身の最新投稿を抜き出すための計算プロパティ ▼▼▼
    private var myLatestPost: PostInfo? {
        viewModel.posts.first { $0.userId == currentUserId }
    }
    // ▼▼▼ 他のユーザーの投稿を抜き出すための計算プロパティ ▼▼▼
        private var otherUsersPosts: [PostInfo] {
            viewModel.posts.filter { $0.userId != currentUserId }
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
                    VStack(spacing: 16) {
                        // --- 自分の投稿だけ特別表示 ---
                        if let myPost = myLatestPost{
                            VStack {
                                if let url = myPost.imageUrl.flatMap({ URL(string: $0) }) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 200, height: 200)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 200, height: 200)
                                                .clipShape(Circle())
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 200, height: 200)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    print("共有ボタン tapped")
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.gray.opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            .padding(.bottom, 20)
                        }
                        
                        // --- 他人の投稿をリスト表示 ---
                        LazyVStack(spacing: 16) {
                            ForEach(otherUsersPosts) { post in
                                                            PostRowView(post: post)
                                                                .padding(.horizontal)
                            }
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
