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
    
    // サインアップ成功時に親ビューに通知するためのクロージャ
    var onSuccess: (() -> Void)? = nil
    
    var body: some View {

        //                        .fontWeight(.semibold)
        ZStack{
            Color.black
                .ignoresSafeArea()
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
//                    .background(Color(hex: "6A6A6A"))
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
//                    .background(Color(hex: "6A6A6A"))
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
//                    .background(Color(hex: "6A6A6A"))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
                    .padding(.bottom, 80)
                
                //                Button(action: viewModel.register) {
                //                    if viewModel.isLoading {
                //                        ProgressView()
                //                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                //                            .frame(maxWidth: .infinity)
                //                            .padding()
                //                    } else {
                //                        Text("登録する")
                //                            .fontWeight(.semibold)
                //                            .foregroundColor(.white)
                //                            .frame(maxWidth: .infinity)
                //                            .padding()
                //                    }
                //                }
                Button(action: {
                    Task {
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
                .disabled(viewModel.displayName.isEmpty || viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
                
                // --- エラーメッセージ ---
                if !viewModel.message.isEmpty {
                    Text(viewModel.message)
                        .foregroundColor(.red)
                }
                //                .background(viewModel.displayName.isEmpty || viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isLoading ? Color.gray : Color.blue)
                //                .cornerRadius(8)
                //                .disabled(viewModel.displayName.isEmpty || viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
                //                if !viewModel.message.isEmpty{
                //                    Text(viewModel.message)
                //                        .foregroundColor(.red)
                //                }
                //            }
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
//    /// ユーザー登録と同時に、Firestoreにユーザー情報を作成する
//    private func register() {
//        isLoading = true
//        message = ""
//
//        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//            if let error = error {
//                self.message = localizedAuthError(error)
//                self.isLoading = false
//                return
//            }
//
//            guard let user = authResult?.user else {
//                self.message = "不明なエラーが発生しました"
//                self.isLoading = false
//                return
//            }
//
//            // 表示名を更新
//            let changeRequest = user.createProfileChangeRequest()
//            changeRequest.displayName = self.displayName
//            changeRequest.commitChanges { commitError in
//                if let commitError = commitError {
//                    print("DisplayName更新失敗: \(commitError.localizedDescription)")
//                }
//
//                // Firestoreに保存
//                let db = Firestore.firestore()
//                db.collection("users").document(user.uid).setData([
//                    "uid": user.uid,
//                    "displayName": self.displayName,
////                    "email": self.email,
//                    "createdAt": Timestamp(date: Date())
//                ]) { err in
//                    self.isLoading = false
//                    if let err = err {
//                        self.message = "データベース保存失敗: \(err.localizedDescription)"
//                    } else {
//                        self.message = ""
//                        onSuccess?() // 親ビューへ成功通知
//                    }
//                }
//            }
//        }
//    }
//
//    /// Firebaseエラーをユーザー向けの日本語メッセージに変換
//    private func localizedAuthError(_ error: Error) -> String {
//        let nsError = error as NSError
//        switch AuthErrorCode(rawValue: nsError.code) {
//        case .invalidEmail:
//            return "メールアドレスの形式が正しくありません"
//        case .emailAlreadyInUse:
//            return "このメールアドレスは既に登録されています"
//        case .weakPassword:
//            return "パスワードは6文字以上にしてください"
//        default:
//            return "登録に失敗しました: \(error.localizedDescription)"
//        }
//    }
//}

#Preview {
    SignUpView()
}
