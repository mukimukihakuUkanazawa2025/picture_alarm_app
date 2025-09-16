//
//  LoginView.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
//    @State private var email = ""
//    @State private var password = ""
//    @State private var errorMessage = ""
//    @State private var isLoggedIn: Bool = false
//    @State private var isLoading = false
    @StateObject private var viewModel = LoginViewModel()
    
    var onSuccess: (() -> Void)? = nil
    
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea()
            
            NavigationStack {
                VStack(spacing: 20) {
                    //                    Text("ログイン")
                    //                        .font(.title)
                    //                        .foregroundStyle(.white)
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
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    HStack{
                        Text(" パスワード")
                            .foregroundStyle(.white)
                            .font(.system(size:24))
                            .bold()
                        Spacer ()
                    }
                    SecureField("", text: $viewModel.password)
                        .padding(12)
                        .background(Color(hex: "6A6A6A"))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 80)
                    
                    Button(action: viewModel.login) {
                        if viewModel.isLoading {
                            // --- ローディング中 ---
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("ログイン中")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange) // オレンジ背景
                            .cornerRadius(10)
                        } else if viewModel.email.isEmpty || viewModel.password.isEmpty {
                            // --- 未入力 ---
                            Text("ログイン")
                                .fontWeight(.semibold)
                                .foregroundColor(.black) // 黒文字
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        } else {
                            // --- 入力済み ---
                            Text("ログイン")
                                .fontWeight(.semibold)
                                .foregroundColor(.white) // 白文字
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange) // オレンジ背景
                                .cornerRadius(10)
                        }
                    }
                    .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
                    // --- エラーメッセージ ---
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                    }
                }
                    
                    //                    Button(action: viewModel.login) {
                    //                        if viewModel.isLoading {
                    //                            ProgressView()
                    //                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    //                                .frame(maxWidth: .infinity)
                    //                                .padding()
                    //                        } else {
                    //                            Text("ログインする")
                    //                                .fontWeight(.semibold)
                    //                                .foregroundColor(.black)
                    //                                .frame(maxWidth: .infinity)
                    //                                .padding()
                    //                                .background(Color.white)
                    //                                .cornerRadius(8)
                    //                        }
                    //                    }
                    //                    .background(Color.white)
                    //                    .cornerRadius(8)
                    //
                    //                    .padding()
                    //                    .background(viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isLoading ? Color.gray : Color.blue)
                    //                    .cornerRadius(8)
                    //                    .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
                    //
                    //                    if !viewModel.errorMessage.isEmpty {
                    //                        Text(viewModel.errorMessage)
                    //                            .foregroundColor(.red)
                    //                    }
                    //                }
                    
                        .padding()
                        .navigationTitle("ログイン")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("ログイン")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .tint(.white)
                        .onChange(of: viewModel.isLoginSuccessful){ success in
                            if success{
                                onSuccess?()
                            }
                }
            }
        }
    }
}

//    private func login() {
//            isLoading = true
//            errorMessage = ""
//            
//            Auth.auth().signIn(withEmail: email, password: password) { result, error in
//                isLoading = false
//                
//                if let error = error {
//                    // エラーを日本語に変換
//                    errorMessage = localizedAuthError(error)
//                    return
//                }
//                
//                // ログイン成功
//                onSuccess?()
//            }
//        }
//        
//        private func localizedAuthError(_ error: Error) -> String {
//            let nsError = error as NSError
//            switch AuthErrorCode(rawValue: nsError.code) {
//            case .invalidEmail:
//                return "メールアドレスの形式が正しくありません"
//            case .userNotFound:
//                return "アカウントが存在しません"
//            case .wrongPassword:
//                return "パスワードが間違っています"
//            default:
//                return "ログインに失敗しました: \(error.localizedDescription)"
//            }
//        }
//    }
#Preview {
    LoginView()
}
