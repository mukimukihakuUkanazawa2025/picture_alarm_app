//
//  LoginView.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn: Bool = false
    @State private var isLoading = false
    
    var onSuccess: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("ログイン")
                    .font(.title)
                    //.leading
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: login) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("ログインする")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(email.isEmpty || password.isEmpty || isLoading ? Color.gray : Color.blue)
                .cornerRadius(8)
                .disabled(email.isEmpty || password.isEmpty || isLoading)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
    }

    private func login() {
            isLoading = true
            errorMessage = ""
            
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                isLoading = false
                
                if let error = error {
                    // エラーを日本語に変換
                    errorMessage = localizedAuthError(error)
                    return
                }
                
                // ログイン成功
                onSuccess?()
            }
        }
        
        private func localizedAuthError(_ error: Error) -> String {
            let nsError = error as NSError
            switch AuthErrorCode(rawValue: nsError.code) {
            case .invalidEmail:
                return "メールアドレスの形式が正しくありません"
            case .userNotFound:
                return "アカウントが存在しません"
            case .wrongPassword:
                return "パスワードが間違っています"
            default:
                return "ログインに失敗しました: \(error.localizedDescription)"
            }
        }
    }
#Preview {
    LoginView()
}
