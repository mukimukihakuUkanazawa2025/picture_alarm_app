//
//  TLView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

// 自分や他人の投稿を表示する画面

import SwiftUI
import FirebaseFirestore

struct TLView: View {
    @StateObject private var viewModel = PostListViewModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                if viewModel.posts.isEmpty {
                    Text("まだ投稿はありません")
                        .foregroundStyle(.gray)
                        .padding()
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.posts) { post in
                            PostRowView(post: post) // ← 投稿1つ分を PostRowView に渡す
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

//struct TLView: View {
//    
//    @StateObject private var viewModel = PostListViewModel()
//    
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//            
//            ScrollView {
//                if viewModel.posts.isEmpty {
//                    Text("まだ投稿はありません")
//                        .foregroundStyle(.gray)
//                        .padding()
//                } else {
//                    LazyVStack(spacing: 16) {   // ← 縦方向に投稿を並べる
//                        ForEach(viewModel.posts) { post in
//                            PostView(
//                                userName: post.userName,
//                                postTime: postTimeString(from: post.postTime),
//                                userComment: post.comments.joined(separator: "\n"),
//                                userImage: nil,
//                                postImageUrl: post.imageUrl != nil ? URL(string: post.imageUrl!) : nil
//                            )
//                            .padding(.horizontal)
//                        }
//                    }
//                    .padding(.vertical, 8)
//                }
//            }
//            .navigationTitle("タイムライン")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("タイムライン")
//                    .font(.headline)
//                    .foregroundColor(.white)
//            }
//        }
//        .tint(.white)
//    }
//    
//    private func postTimeString(from date: Date?) -> String {
//        guard let date = date else { return "" }
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        return formatter.string(from: date)
//    }
//}
//
//
//
//
//
//#Preview {
//    TLView()
//}
