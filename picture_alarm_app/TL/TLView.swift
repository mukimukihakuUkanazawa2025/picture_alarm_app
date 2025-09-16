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
    
    // ログイン中のユーザー名を保持
    private var currentUserName: String? {
        Auth.auth().currentUser?.displayName
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
                        if let currentUserName,
                           let myPost = viewModel.posts.first(where: { $0.userName == currentUserName }) {
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
                            ForEach(viewModel.posts.filter { post in
                                guard let currentUserName else { return true }
                                return post.userName != currentUserName
                            }) { post in
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

//struct TLView: View {
//    // 本来は Firebase のデータを使うけど、
//    // 今はサンプルで動かしたいから viewModel を外す！
//    // @StateObject private var viewModel = PostListViewModel()
//
//    let posts = SamplePosts.posts
//
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//
//            ScrollView {
//                if posts.isEmpty {
//                    Text("まだ投稿はありません")
//                        .foregroundStyle(.gray)
//                        .padding()
//                } else {
//                    // ← 一番上だけ特別に表示
//                    if let firstPost = posts.first {
//                        VStack {
//                            AsyncImage(url: URL(string: firstPost.imageUrl ?? "")) { phase in
//                                switch phase {
//                                case .empty:
//                                    ProgressView()
//                                        .frame(width: 200, height: 200)
//                                case .success(let image):
//                                    image
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 200, height: 200)
//                                        .clipShape(Circle())
//                                case .failure:
//                                    Image(systemName: "photo")
//                                        .resizable()
//                                        .frame(width: 200, height: 200)
//                                        .foregroundColor(.gray)
//                                @unknown default:
//                                    EmptyView()
//                                }
//                            }
//
//                            Button(action: {
//                                // 共有処理は後で実装
//                                print("共有ボタン押された")
//                            }) {
//                                Image(systemName: "square.and.arrow.up")
//                                    .font(.title2)
//                                    .foregroundColor(.white)
//                            }
//                            .padding(.top, 8)
//                        }
//                        .padding(.bottom, 16)
//                    }
//
//                    // 残りの投稿をリスト表示
//                    LazyVStack(spacing: 16) {
//                        ForEach(posts.dropFirst()) { post in
//                            PostRowView(post: post)
//                                .padding(.horizontal)
//                        }
//                    }
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
//}

//struct TLView: View {
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
//                    VStack(spacing: 16) {
//                        // --- 自分の投稿だけ特別表示 ---
//                        if let myPost = viewModel.posts.first(where: { $0.userName == "自分" }) {
//                            VStack {
//                                if let url = myPost.imageUrl.flatMap({ URL(string: $0) }) {
//                                    AsyncImage(url: url) { phase in
//                                        switch phase {
//                                        case .empty:
//                                            ProgressView()
//                                                .frame(width: 200, height: 200)
//                                        case .success(let image):
//                                            image
//                                                .resizable()
//                                                .scaledToFill()
//                                                .frame(width: 200, height: 200)
//                                                .clipShape(Circle())
//                                        case .failure:
//                                            Image(systemName: "photo")
//                                                .resizable()
//                                                .scaledToFit()
//                                                .frame(width: 200, height: 200)
//                                                .foregroundColor(.gray)
//                                        @unknown default:
//                                            EmptyView()
//                                        }
//                                    }
//                                }
//
//                                // 共有ボタン
//                                Button(action: {
//                                    print("共有ボタン tapped")
//                                }) {
//                                    Image(systemName: "square.and.arrow.up")
//                                        .foregroundColor(.white)
//                                        .padding()
//                                        .background(Color.gray.opacity(0.5))
//                                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                                }
//                            }
//                            .padding(.bottom, 20)
//                        }
//
//                        // --- 他人の投稿をリスト表示 ---
//                        LazyVStack(spacing: 16) {
//                            ForEach(viewModel.posts.filter { $0.userName != "自分" }) { post in
//                                PostRowView(post: post)
//                                    .padding(.horizontal)
//                            }
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
//}

//import SwiftUI
//import FirebaseFirestore
//import FirebaseAuth
//
//struct TLView: View {
//    @StateObject private var viewModel = PostListViewModel()
//
//    // 現在のユーザー名を取得（Auth から取れるならこっちが安全）
//    private var currentUserName: String {
//        Auth.auth().currentUser?.displayName ?? "自分"
//    }
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
//                    // --- 自分の最新投稿を一番上に ---
//                    if let myPost = viewModel.posts
//                        .filter({ $0.userName == currentUserName }) // 自分の投稿だけ
//                        .sorted(by: { ($0.postTime ?? Date.distantPast) > ($1.postTime ?? Date.distantPast) }) // 新しい順
//                        .first {
//
//                        // ここでは写真だけ大きく見せる
//                        if let imageUrl = myPost.imageUrl,
//                           let url = URL(string: imageUrl) {
//                            AsyncImage(url: url) { phase in
//                                switch phase {
//                                case .empty:
//                                    ProgressView()
//                                        .frame(width: 250, height: 250)
//                                case .success(let image):
//                                    image
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 250, height: 250)
//                                        .clipShape(Circle())
//                                case .failure:
//                                    Image(systemName: "photo")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 250, height: 250)
//                                        .foregroundColor(.gray)
//                                @unknown default:
//                                    EmptyView()
//                                }
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding(.top, 16)
//                        }
//                    }
//
//                    // --- 他の投稿だけをタイムラインに表示 ---
//                    LazyVStack(spacing: 16) {
//                        ForEach(viewModel.posts.filter { $0.userName != currentUserName }) { post in
//                            PostRowView(post: post)
//                                .padding(.horizontal)
//                        }
//                    }
//                    //                    LazyVStack(spacing: 16) {
//                    //                        ForEach(viewModel.posts) { post in
//                    //                            PostRowView(post: post) // ← 投稿1つ分を PostRowView に渡す
//                    //                                .padding(.horizontal)
//                    //                        }
//                    //                    }
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
//}
//


#Preview {
    TLView()
}
