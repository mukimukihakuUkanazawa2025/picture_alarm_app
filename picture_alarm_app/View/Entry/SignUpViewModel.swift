//
//  SignUpViewModel.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import SwiftUI
import Foundation
import FirebaseAuth

@MainActor // UI更新をメインスレッドで行う
class SignUpViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var message = ""
    @Published var isLoading = false
    @Published var isSignUpSuccessful = false
    
    func register() {
        isLoading = true
        message = ""
        
        // 1. AuthServiceにユーザー作成を依頼
        AuthService.shared.createUser(withEmail: email, password: password) { [weak self] authUser, error in
            guard let self = self else { return }
            
            if let error = error {
                self.message = "アカウント作成に失敗: \(error.localizedDescription)"
                self.isLoading = false
                return
            }
            
            guard let authUser = authUser else {
                self.message = "不明なエラーが発生しました"
                self.isLoading = false
                return
            }
            
            // 2. UserServiceにDBへの保存を依頼
            UserService.shared.saveUser(authData: authUser, name: self.displayName) { error in
                self.isLoading = false
                if let error = error {
                    self.message = "データベースへの保存に失敗: \(error.localizedDescription)"
                } else {
                    self.isSignUpSuccessful = true
                }
            }
        }
    }
}

