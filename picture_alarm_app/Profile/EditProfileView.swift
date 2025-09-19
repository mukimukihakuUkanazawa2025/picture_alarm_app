//
//  SettingView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @StateObject private var viewModel = EditProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var onProfileUpdate: (() -> Void)?
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // --- プロフィール画像ピッカー ---
                        PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                            VStack {
                                if let image = viewModel.profileImage {
                                    Image(uiImage: image)
                                        .resizable().aspectRatio(contentMode: .fill)
                                } else {
                                    AsyncImage(url: URL(string: viewModel.user?.profileImageUrl ?? "")) { image in
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable().foregroundColor(.gray.opacity(0.5))
                                    }
                                }
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(alignment: .bottomTrailing) {
                                Image(systemName: "camera.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text(viewModel.displayName)
                            .font(.title2).fontWeight(.bold)
                        
                        // --- テキストフィールド ---
                        VStack {
                            TextField("名前", text: $viewModel.displayName)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            
                            // 複数行の自己紹介にはTextEditorを使う
                            TextEditor(text: $viewModel.bio)
                                .frame(height: 150)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            // --- 顔質画像ピッカー ---
                            PhotosPicker(selection: $viewModel.selectHitozichiPhoto, matching: .images) {
                                VStack {
                                    if let image = viewModel.hitozichiImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else {
                                        Image(systemName: "person")
                                            .resizable().foregroundColor(.gray.opacity(0.5))
                                    }
                                }
                                .background(.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                            }
                        }
                        
                        // --- ログアウト・アカウント削除ボタン ---
                        VStack(spacing: 15) {
                            Button(action: {
                                viewModel.logout()
                            }) {
                                Text("ログアウト")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.4))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(role: .destructive) {
                                viewModel.isShowingDeleteAlert = true
                            } label: {
                                Text("アカウントを削除")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top, 40) // 上の要素との間隔を調整
                    }
                    .padding()
                }
                
                // --- ローディング表示 ---
                if viewModel.isLoading {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .navigationTitle("プロフィールを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        Task {
                            await viewModel.saveProfile()
                        }
                    }
                }
            }
            // 保存が成功したら画面を閉じる
            .onChange(of: viewModel.didSaveProfile) { success in
                if success {
                    onProfileUpdate?()
                    dismiss()
                }
            }
            // アカウント削除の確認アラート
            .alert("アカウントを削除", isPresented: $viewModel.isShowingDeleteAlert) {
                Button("削除", role: .destructive) {
                    Task {
                        await viewModel.deleteAccount()
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("この操作は取り消せません。アカウントを削除すると、プロフィールや投稿など、関連する全てのデータが完全に失われます。本当によろしいですか？")
            }
            // エラー表示用アラート
            .alert("エラー", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            }, message: {
                Text(viewModel.errorMessage ?? "")
            })
        }
        .preferredColorScheme(.dark)
    }
}


#Preview {
    EditProfileView()
}
