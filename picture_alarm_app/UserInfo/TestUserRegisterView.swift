//
//  TestUserRegisterView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/15.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import PhotosUI

struct UserRegisterView: View {
    @StateObject private var viewModel = UserViewModel()
    
    @State private var userName = ""
    @State private var userID = ""
    
    @State private var selectedUserImage: PhotosPickerItem?
    @State private var selectedFailedImage: PhotosPickerItem?
    @State private var userImageData: Data?
    @State private var failedImageData: Data?
    
    @State private var message: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("ユーザー登録")
                .font(.largeTitle)
                .bold()
            
            TextField("ユーザー名", text: $userName)
                .textFieldStyle(.roundedBorder)
            TextField("ユーザーID", text: $userID)
                .textFieldStyle(.roundedBorder)
            
            // 成功画像ピッカー
            PhotosPicker("ユーザー画像を選択", selection: $selectedUserImage, matching: .images)
            if let data = userImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
            }
            
            // 失敗画像ピッカー
            PhotosPicker("失敗画像を選択", selection: $selectedFailedImage, matching: .images)
            if let data = failedImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
            }
            
            Button("登録") {
                Task {
                    do {
                        try await viewModel.saveUser(
                            userName: userName,
                            userID: userID,
                            userImageData: userImageData,
                            failedImageData: failedImageData
                        )
                        message = "登録成功！"
                    } catch {
                        message = "登録失敗: \(error.localizedDescription)"
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            Text(message)
                .foregroundColor(.blue)
                .padding(.top, 10)
        }
        .padding()
        // 成功画像が選ばれたらDataに変換
        .onChange(of: selectedUserImage) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    userImageData = data
                }
            }
        }
        // 失敗画像が選ばれたらDataに変換
        .onChange(of: selectedFailedImage) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    failedImageData = data
                }
            }
        }
    }
}

#Preview {
    TestUserRegisterView()
}
