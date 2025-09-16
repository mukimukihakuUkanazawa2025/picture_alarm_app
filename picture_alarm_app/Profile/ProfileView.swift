//
//  ProfileView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

// 自分の投稿情報やアカウント設定を行う画面
import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State var showFriendsView: Bool = false
    @State var showAddFriendView: Bool = false
    @State var showFriendRequestView: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // プロフィールアイコン
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                    
                    // ユーザー名
                    Text(Auth.auth().currentUser?.displayName ?? "ゲストユーザー")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    // 友達数（仮）
                    VStack {
                        Text("友達")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        Button(action: {
                            showFriendsView.toggle()
                        }) {
                            Text("15") // ← ここは将来的に Firestore の friends.count に置き換え
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // プロフィールシェアボタン
                    Button(action: {
                        print("プロフィールをシェア tapped")
                    }) {
                        Label("プロフィールをシェア", systemImage: "square.and.arrow.up")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Divider().background(Color.gray)
                    
                    // 投稿一覧（仮で6個）
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(0..<9) { _ in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                // 左上にフレンド追加アイコン
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showAddFriendView.toggle() }) {
                        Image(systemName: "person.2.badge.plus.fill")
                            .foregroundColor(.white)
                    }
                }
                
                //フレンド申請確認画面
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {showFriendRequestView.toggle()}){
                        Image(systemName: "bell.fill")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showFriendRequestView) {
                FriendRequestsView()
            }
            .sheet(isPresented: $showAddFriendView) {
                AddFriendView()
            }
            .sheet(isPresented: $showFriendsView){
                FriendsView()
            }
        }
    }
}

#Preview {
    ProfileView()
}

