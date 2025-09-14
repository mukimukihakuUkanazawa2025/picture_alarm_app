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
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""
    @State private var isLoading = false
    
    // サインアップ成功時に親ビューに通知するためのクロージャ
    var onSuccess: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("アカウント作成")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("表示名", text: $displayName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
            
            TextField("メールアドレス", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            
            SecureField("パスワード(6文字以上)", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
            
            Button(action: register) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("登録する")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(displayName.isEmpty || email.isEmpty || password.isEmpty || isLoading ? Color.gray : Color.blue)
            .cornerRadius(8)
            .disabled(displayName.isEmpty || email.isEmpty || password.isEmpty || isLoading)
            
            Text(message)
                .foregroundColor(.red)
        }
        .padding()
    }
    
    /// ユーザー登録と同時に、Firestoreにユーザー情報を作成する
    private func register() {
        isLoading = true
        message = ""
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.message = localizedAuthError(error)
                self.isLoading = false
                return
            }
            
            guard let user = authResult?.user else {
                self.message = "不明なエラーが発生しました"
                self.isLoading = false
                return
            }
            
            // 表示名を更新
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = self.displayName
            changeRequest.commitChanges { commitError in
                if let commitError = commitError {
                    print("DisplayName更新失敗: \(commitError.localizedDescription)")
                }
                
                // Firestoreに保存
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "uid": user.uid,
                    "displayName": self.displayName,
//                    "email": self.email,
                    "createdAt": Timestamp(date: Date())
                ]) { err in
                    self.isLoading = false
                    if let err = err {
                        self.message = "データベース保存失敗: \(err.localizedDescription)"
                    } else {
                        self.message = ""
                        onSuccess?() // 親ビューへ成功通知
                    }
                }
            }
        }
    }
    
    /// Firebaseエラーをユーザー向けの日本語メッセージに変換
    private func localizedAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        switch AuthErrorCode(rawValue: nsError.code) {
        case .invalidEmail:
            return "メールアドレスの形式が正しくありません"
        case .emailAlreadyInUse:
            return "このメールアドレスは既に登録されています"
        case .weakPassword:
            return "パスワードは6文字以上にしてください"
        default:
            return "登録に失敗しました: \(error.localizedDescription)"
        }
    }
}

#Preview {
    SignUpView()
}
