//
//  AuthService.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import SwiftUI
import Foundation
import FirebaseAuth

// 認証を専門に担当するクラス
class AuthService {
    static let shared = AuthService()
    private init() {}
    
    /// メールアドレスとパスワードでユーザーを新規作成する
    func createUser(withEmail email: String, password: String) async throws -> FirebaseAuth.User {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            return authResult.user
    }
    
    /// メールアドレスとパスワードでサインインする
    func signIn(withEmail email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            completion(error)
        }
    }
    /// 現在のユーザーをサインアウトする
        func signOut() {
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }
        
        /// 現在のユーザーアカウントを削除する
        func deleteAccount() async throws {
            guard let user = Auth.auth().currentUser else {
                // ユーザーがnilの場合はエラーを投げるか、特定の処理を行う
                throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "ユーザーが見つかりません"])
            }
            try await user.delete()
        }
}
