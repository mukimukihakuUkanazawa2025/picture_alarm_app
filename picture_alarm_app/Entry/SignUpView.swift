//
//  SignUpView.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
// バグメモ→Authだけ保存してFireStoreに保存されないことがある。2025/09/14/16:32

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @State private var passwordConfirm = ""
    
    // サインアップ成功時に親ビューに通知するためのクロージャ
    var onSuccess: (() -> Void)? = nil
    
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                HStack{
                    Text(" ユーザー名")
                        .foregroundStyle(.white)
                        .font(.system(size:24))
                        .bold()
                    Spacer ()
                }
                TextField("", text: $viewModel.displayName)
                    .padding(12)
                    .background(Color(hex: "6A6A6A"))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
                
                HStack{
                    Text(" Email")
                        .foregroundStyle(.white)
                        .font(.system(size:24))
                        .bold()
                    Spacer()
                }
                TextField("", text: $viewModel.email)
                    .padding(12)
                    .background(Color(hex: "6A6A6A"))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                
                HStack{
                    Text(" パスワード(6文字以上)")
                        .foregroundStyle(.white)
                        .font(.system(size:24))
                        .bold()
                    Spacer()
                }
                SecureField("", text: $viewModel.password)
                    .padding(12)
                    .background(Color(hex: "6A6A6A"))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
                
                HStack{
                    Text(" パスワード(確認用)")
                        .foregroundStyle(.white)
                        .font(.system(size:24))
                        .bold()
                    Spacer()
                }
                SecureField("", text: $passwordConfirm)
                    .padding(12)
                    .background(Color(hex: "6A6A6A"))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
                    .padding(.bottom, 40)

                Button(action: {
                    Task {
                        if viewModel.password != passwordConfirm {
                                                    viewModel.message = "パスワードが一致しません"
                                                    return
                                                }
                        await viewModel.register()   // ← async 関数を Task 内で呼び出す
                    }
                }) {
                    if viewModel.isLoading {
                        // --- ローディング中 ---
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("作成中")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange) // オレンジ背景
                        .cornerRadius(10)
                    } else if viewModel.displayName.isEmpty || viewModel.email.isEmpty || viewModel.password.isEmpty {
                        // --- 未入力 ---
                        Text("作成")
                            .fontWeight(.semibold)
                            .foregroundColor(.black) // 黒文字
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white) // 白背景
                            .cornerRadius(10)
                    } else {
                        // --- 入力済み ---
                        Text("作成")
                            .fontWeight(.semibold)
                            .foregroundColor(.white) // 白文字
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange) // オレンジ背景
                            .cornerRadius(10)
                    }
                }
                .disabled(viewModel.displayName.isEmpty || viewModel.email.isEmpty || viewModel.password.isEmpty || passwordConfirm.isEmpty || viewModel.isLoading)
                
                // --- エラーメッセージ ---
                if !viewModel.message.isEmpty {
                    Text(viewModel.message)
                        .foregroundColor(.red)
                        .bold()
                }
            }
            .padding()
            .navigationTitle("アカウント作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("アカウント作成")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .tint(.white)
            .onChange(of: viewModel.isSignUpSuccessful){ success in
                if success {
                    onSuccess?()
                }
            }
        }
    }
}
