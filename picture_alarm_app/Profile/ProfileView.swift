//
//  ProfileView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

// 自分の投稿情報やアカウント設定を行う画面
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    // 各シートの表示状態を管理
    @State private var showFriendsView = false
    @State private var showAddFriendView = false
    @State private var showFriendRequestView = false
    @State private var showSettingsView = false 
    
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
                                AsyncImage(url: URL(string: user.profileImageUrl ?? "")) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable().foregroundColor(.gray.opacity(0.5))
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            }
                            
                            Text(user.name)
                                .font(.title2).fontWeight(.bold)
                        }
                        .padding(.top)
                        
                        // --- 友達情報 ---
                        Button(action: { showFriendsView = true }) {
                            VStack {
                                // 👇 友達の数をViewModelから動的に表示
                                Text("\(viewModel.friendCount)")
                                    .font(.title3).fontWeight(.bold)
                                Text("友達")
                                    .font(.caption).foregroundColor(.gray)
                            }
                        }
                        
                        Divider().background(Color.gray.opacity(0.5))
                        
                        // --- 投稿一覧グリッド (仮) ---
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                            ForEach(0..<9) { _ in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                        
                    }
                }
                .padding(.horizontal)
            }
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
            }
        }
    }
}
