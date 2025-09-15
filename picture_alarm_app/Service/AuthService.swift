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
}
