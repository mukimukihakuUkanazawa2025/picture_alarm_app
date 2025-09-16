//
//  LoginViewModel.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import SwiftUI

import Foundation
import FirebaseAuth

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var isLoginSuccessful = false
    
    func login() {
        isLoading = true
        errorMessage = ""
        
        AuthService.shared.signIn(withEmail: email, password: password) { [weak self] error in
            self?.isLoading = false
            if let error = error {
                self?.errorMessage = self?.localizedAuthError(error) ?? "不明なエラーが発生しました"
            } else {
                self?.isLoginSuccessful = true
            }
        }
    }
    private func localizedAuthError(_ error: Error) -> String {
            let nsError = error as NSError
            switch AuthErrorCode(rawValue: nsError.code) {
            case .userNotFound:
                return "このメールアドレスは登録されていません"
            case .wrongPassword:
                return "パスワードが間違っています"
            case .invalidEmail:
                return "メールアドレスの形式が正しくありません"
            default:
                // その他の予期せぬエラーの場合は、汎用的なメッセージを表示する
                return "ログインに失敗しました。しばらくしてから再度お試しください。"
            }
        }
}
