//
//  UserService.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseAuth

// ユーザーのデータベース処理を専門に担当するクラス
class UserService {
    static let shared = UserService()
    private init() {}
    
    private let db = Firestore.firestore()
    
    /// Authで作成されたユーザー情報をFirestoreに保存する
    func saveUser(authData: FirebaseAuth.User, name: String, completion: @escaping (Error?) -> Void) {
        let user = User(id: authData.uid, name: name, createAt: Timestamp())
        
        let userData: [String: Any] = [
            "id": user.id,
            "name": user.name,
            "createAt": user.createAt
        ]
        
        // ドキュメントIDをAuthのUIDと一致させて保存
        db.collection("users").document(user.id).setData(userData, completion: completion)
    }
}
