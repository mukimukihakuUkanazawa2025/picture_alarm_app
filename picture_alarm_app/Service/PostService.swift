//
//  PostInfoViewModel.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/15.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct PostInfo: Identifiable {
    var id: String // Firebaseでの識別用
    var userId: String // ユーザーのID
    var postTime: Date? // 投稿時刻
    var imageUrl: String?
    var goodCount: Int = 0 // いいね数
    var comments: [String] = [] // コメント
    var user: User?
    var status:String? //ユーザーの起床状況
}

class PostService {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let userService = UserService.shared
    
    func uploadPost(imageData: Data, comment: String?, status:UserStatus, completion: @escaping (Error?) -> Void) async throws {
        
        guard let currentUser = Auth.auth().currentUser else {
            completion(NSError(domain: "PostService", code: -1, userInfo: [NSLocalizedDescriptionKey: "ユーザー未サインイン"]))
            return
        }
        
        let postRef = db.collection("posts").document()
        let storageRef = storage.reference().child("posts/\(postRef.documentID).jpg")
        
        _ = try await storageRef.putDataAsync(imageData, metadata: nil)
        let url = try await storageRef.downloadURL()
        
        let post: [String: Any] = [
            "id": postRef.documentID,
            "userId": currentUser.uid,
            "postTime": FieldValue.serverTimestamp(),
            "imageUrl": url.absoluteString,
            "goodCount": 0,
            "comments": [comment ?? ""],
            "stutus" : status.rawValue
        ]
        
        try await postRef.setData(post)
    }
    
    
    func uploadOriginalImage(imageData: Data) async throws {
        let storageRef = storage.reference().child("originals/\(UUID().uuidString).jpg")
        _ = try await storageRef.putDataAsync(imageData, metadata: nil)
    }
}
