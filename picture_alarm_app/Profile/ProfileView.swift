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

//import SwiftUI
//import FirebaseAuth
//
//struct ProfileView: View {
//    @State var showAddFriendView: Bool = false
//    @State var showSettingView: Bool = false
//    @State var showFriendRequestView: Bool = false
//    @State var showFriendsView: Bool = false
//
//    // ログイン中のユーザー情報（AuthのUserを明示）
//    private var currentUser: FirebaseAuth.User? {
//        Auth.auth().currentUser
//    }
//
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//
//            ScrollView {
//                VStack(spacing: 24) {
//
//                    // --- プロフィールヘッダー ---
//                    VStack(spacing: 12) {
//                        Image(systemName: "person.circle.fill")
//                            .resizable()
//                            .frame(width: 100, height: 100)
//                            .foregroundColor(.gray)
//
//                        // 🔹 displayName は FirebaseAuth.User のプロパティ
//                        Text(currentUser?.displayName ?? "ゲストユーザー")
//                            .font(.title2)
//                            .foregroundColor(.white)
//                    }
//                    .padding(.top, 20)
//
//                    Divider().background(Color.gray)
//
//                    // --- フレンド関連 ---
//                    VStack(spacing: 16) {
//                        profileButton(title: "フレンド追加", action: { showAddFriendView.toggle() })
//                            .sheet(isPresented: $showAddFriendView) {
//                                AddFriendView()
//                            }
//
//                        profileButton(title: "フレンド申請確認", action: { showFriendRequestView.toggle() })
//                            .sheet(isPresented: $showFriendRequestView) {
//                                FriendRequestsView()
//                            }
//
//                        profileButton(title: "フレンド一覧", action: { showFriendsView.toggle() })
//                            .sheet(isPresented: $showFriendsView) {
//                                FriendsView()
//                            }
//                    }
//
//                    Divider().background(Color.gray)
//
//                    // --- 設定関連 ---
//                    VStack(spacing: 16) {
//                        profileButton(title: "設定", action: { showSettingView.toggle() })
//                            .sheet(isPresented: $showSettingView) {
//                                SettingView()
//                            }
//
//                        Button(action: {
//                            do {
//                                try Auth.auth().signOut()
//                                print("ログアウトしました")
//                                // TODO: EntryView に戻る処理
//                            } catch {
//                                print("ログアウトエラー: \(error.localizedDescription)")
//                            }
//                        }) {
//                            Text("ログアウト")
//                                .font(.headline)
//                                .foregroundColor(.red)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.gray.opacity(0.2))
//                                .cornerRadius(10)
//                        }
//                    }
//                }
//                .padding(.horizontal, 20)
//            }
//        }
//        .navigationTitle("プロフィール")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("プロフィール")
//                    .font(.headline)
//                    .foregroundColor(.white)
//            }
//        }
//        .tint(.white)
//    }
//
//    // 共通のボタンデザイン
//    private func profileButton(title: String, action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            HStack {
//                Text(title)
//                    .font(.headline)
//                    .foregroundColor(.white)
//                Spacer()
//                Image(systemName: "chevron.right")
//                    .foregroundColor(.gray)
//            }
//            .padding()
//            .background(Color.gray.opacity(0.2))
//            .cornerRadius(10)
//        }
//    }
//}
//import SwiftUI
//
//struct ProfileView: View {
//
//    @State var showAddFriendView: Bool = false
//    @State var showSettingView: Bool = false
//    @State var showFriendRequestView: Bool = false
//    @State var showFriendsView: Bool = false
//
//    var body: some View {
//        VStack {
//            Button {
//                showAddFriendView.toggle()
//            } label: {
//                Text("フレンド追加画面へ")
//            }
//            .sheet(isPresented: $showAddFriendView) {
//                AddFriendView()
//            }
//
//            Button {
//                showFriendRequestView.toggle()
//            } label: {
//                Text("フレンド申請確認画面へ")
//            }
//            .sheet(isPresented: $showFriendRequestView) {
//                FriendRequestsView()
//            }
//            Button {
//                showFriendsView.toggle()
//            } label: {
//                Text("フレンド一覧画面へ")
//            }
//            .sheet(isPresented: $showFriendsView) {
//                FriendsView()
//            }
//
//            Button {
//                showSettingView.toggle()
//            } label: {
//                Text("設定画面へ")
//            }
//            .sheet(isPresented: $showSettingView) {
//                SettingView()
//            }
//        }
//    }
//}
//
//#Preview {
//    ProfileView()
//}
