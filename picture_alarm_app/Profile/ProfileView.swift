//  ProfileView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

// 自分の投稿情報やアカウント設定を行う画面
import SwiftUI
import Kingfisher

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    // 各シートの表示状態を管理
    @State private var showFriendsView = false
    @State private var showAddFriendView = false
    @State private var showFriendRequestView = false
    @State private var showSettingsView = false
    @State private var selectedPostToDelete: PostInfo?
    
    
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    // 日付を文字列にフォーマットする
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else if let user = viewModel.currentUser {
                        
                        // --- プロフィールヘッダー ---
                        VStack(spacing: 12) {
                            Button(action: { showSettingsView = true }) {
                                
                                if let profileUrlStr = user.profileImageUrl, let profileUrl = URL(string: profileUrlStr) {
                                    
                                    KFImage(profileUrl)
                                        .resizable()
                                        .cancelOnDisappear(true)
                                        .cacheOriginalImage()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle())
                                        .overlay(alignment: .bottomTrailing) {
                                            Image(systemName: "square.and.pencil")
                                                .font(.title)
                                                .foregroundColor(.white)
                                        }
                                        .frame(width: 100, height: 100)
                                } else {
                                    
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                
            
                            }
                            
                            Text(user.name)
                                .font(.title2).fontWeight(.bold)
                        }
                        .padding(.top)
                        
                        // --- 友達情報 ---
                        Button(action: { showFriendsView = true }) {
                            VStack {
                                Text("\(viewModel.friendCount)")
                                    .font(.title3).fontWeight(.bold)
                                Text("友達")
                                    .font(.caption).foregroundColor(.gray)
                            }
                        }
                        
                        Divider().background(Color.gray.opacity(0.5))
                        
                        // --- 投稿一覧グリッド ---
                        LazyVGrid(columns: columns, spacing: 4) {
                            ForEach(viewModel.userPosts) { post in
                                
                                if let userPostImageUrlStr = post.imageUrl, let userPostImageUrl = URL(string: userPostImageUrlStr) {
                                    
                                    KFImage(userPostImageUrl)
                                        .resizable()
                                        .cancelOnDisappear(true)
                                        .cacheOriginalImage()
                                        .frame(width:160,height:160)
                                        .clipShape(Circle())
                                        .overlay(alignment: .topLeading) {
                                            // 日付を画像の上に表示
                                            Text(formatDate(post.postTime))
                                                .font(.subheadline).bold()
                                                .padding(4)
                                                .background(.white)
                                                .foregroundColor(.black)
                                                .cornerRadius(4)
                                                .padding(4)
                                        }
                                        .aspectRatio(1, contentMode: .fit) // 正方形に
                                        .clipped()
                                        .onLongPressGesture {
                                            selectedPostToDelete = post
                                        }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .alert("投稿を削除", isPresented: .constant(selectedPostToDelete != nil), actions: {
                Button("キャンセル", role: .cancel) {
                    selectedPostToDelete = nil
                }
                Button("削除", role: .destructive) {
                    if let postToDelete = selectedPostToDelete {
                        Task {
                            await viewModel.deletePost(postToDelete)
                        }
                    }
                    selectedPostToDelete = nil
                }
            }, message: {
                Text("この投稿を完全に削除しますか？")
            })
            
            .background(.black)
            .foregroundColor(.white)
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // ツールバーのボタンを整理
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showAddFriendView = true }) {
                        Image(systemName: "person.badge.plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFriendRequestView = true }) {
                        Image(systemName: "bell")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettingsView = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            // --- 各画面をシートで表示 ---
            .sheet(isPresented: $showFriendsView) { FriendsView() }
            .sheet(isPresented: $showAddFriendView) { AddFriendView() }
            .sheet(isPresented: $showFriendRequestView) { FriendRequestsView() }
            .sheet(isPresented: $showSettingsView) { EditProfileView(onProfileUpdate:{
                Task{
                    await viewModel.fetchUserProfile()
                }
            }) }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            Task {
                await viewModel.fetchUserProfile()
                viewModel.fetchUserPosts()
            }
        }
    }
}
