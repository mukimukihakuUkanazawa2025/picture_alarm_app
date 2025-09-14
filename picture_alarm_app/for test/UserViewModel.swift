//
//  UserViewModel.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/14.
//

import Foundation
import FirebaseFirestore

class UserViewModel: ObservableObject {
    
    // Firestoreのインスタンスを作成
    // db.collection("users")とすれば「users」コレクションにアクセス可能
    private var db = Firestore.firestore()
    
    // ユーザーデータをアプリ側に保持
    // @Published... 値が変わると自動的にViewが更新される
    @Published var users: [User] = []
    
    // Firestoreへ保存する関数
    func saveUser(name: String, completion: @escaping (Error?) -> Void) {
        
        // 「users」コレクションにランダムなIDのドキュメントを作成
        // docRef... Firestoreが自動生成したID
        let docRef = db.collection("users").document()
        
        // Userモデルを作成
        // Timestamp()... Firestore用の現在時刻
        let user = User(id: docRef.documentID, name: name, createAt: Timestamp())
        
        // Firestoreにデータを書き込み
        // 書き込み結果が完了したらcompletionでエラーを返す(成功時はnil)
        docRef.setData([
            "id": user.id,
            "name": user.name,
            "createAt": user.createAt
        ]) { error in
            completion(error)
        }
    }
    
    // Firestoreから取得
    func fetchUsers() {
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.users = snapshot?.documents.map {
                    User(id: $0.documentID,
                         name: $0.data()["name"] as? String ?? "",
                         createAt: $0.data()["createAt"] as? Timestamp ?? Timestamp())
                } ?? []
            }
        }
    }
}
