//
//  UserViewModel.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/15.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

// Storageに画像をアップロードしてURLを返す共通関数
extension Storage {
    func uploadImage(_ data: Data, path: String) async throws -> String {
        let ref = reference().child("userImages/\(path).jpg")
        _ = try await ref.putDataAsync(data)   // async/await API
        return try await ref.downloadURL().absoluteString
    }
}

@MainActor
class UserViewModel: ObservableObject {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    @Published var users: [User] = []
    
    // ユーザー登録
    func saveUser(userName: String, userID: String, userImageData: Data?, failedImageData: Data?) async throws {
        let docRef = db.collection("userInfo").document()
        
        // Storageにアップロード（データがある場合のみ）
        let userImageURL = try await userImageData.map { try await storage.uploadImage($0, path: "\(docRef.documentID)_user") }
        let failedImageURL = try await failedImageData.map { try await storage.uploadImage($0, path: "\(docRef.documentID)_failed") }
        
        let user = User(
            id: docRef.documentID,
            userName: userName,
            userID: userID,
            userImageURL: userImageURL,
            failedImageURL: failedImageURL
        )
        
        try await docRef.setData([
            "id": user.id,
            "userName": user.userName,
            "userID": user.userID,
            "userImageURL": user.userImageURL ?? "",
            "failedImageURL": user.failedImageURL ?? ""
        ])
    }
    
    // Firestoreからユーザー一覧を取得
    func fetchUsers() async throws {
        let snapshot = try await db.collection("userInfo").getDocuments()
        self.users = snapshot.documents.compactMap { doc in
            try? doc.data(as: User.self)
        }
    }
}
