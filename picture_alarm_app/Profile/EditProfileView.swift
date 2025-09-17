//
//  SettingView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

import SwiftUI

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
                        }
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
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    EditProfileView()
}
