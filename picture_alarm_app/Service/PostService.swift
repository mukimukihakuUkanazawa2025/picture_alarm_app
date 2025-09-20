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
    var thumbnailUrl: String? // サムネイルURL
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

        // Compress image before upload
        guard let image = UIImage(data: imageData),
              let compressedData = image.jpegData(compressionQuality: 0.3) else {
            completion(NSError(domain: "PostService", code: -2, userInfo: [NSLocalizedDescriptionKey: "画像圧縮失敗"]))
            return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.cacheControl = "public,max-age=3600"

        _ = try await storageRef.putDataAsync(compressedData, metadata: metadata)
        let url = try await storageRef.downloadURL()

        // Resize Images対応：サムネイルURLを取得、存在しなければフル画像を使用
        let thumbRef = storage.reference().child("thumbnails/\(postRef.documentID)_400x400.jpg")
        let thumbURL = try? await thumbRef.downloadURL()

        let post: [String: Any] = [
            "id": postRef.documentID,
            "userId": currentUser.uid,
            "postTime": FieldValue.serverTimestamp(),
            "imageUrl": url.absoluteString,
            "thumbnailUrl": thumbURL?.absoluteString ?? url.absoluteString,
            "goodCount": 0,
            "comments": [comment ?? ""],
            "status": status.rawValue
        ]

        do {
            try await postRef.setData(post)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    
    func uploadOriginalImage(imageData: Data) async throws {
        let storageRef = storage.reference().child("originals/\(UUID().uuidString).jpg")
        _ = try await storageRef.putDataAsync(imageData, metadata: nil)
    }

    func deletePost(postId: String) async throws {
        // Firestoreの投稿を削除
        try await db.collection("posts").document(postId).delete()

        // Storageの画像を削除
        let imageRef = storage.reference().child("posts/\(postId).jpg")
        try? await imageRef.delete()

        // Storageのサムネイルを削除
        let thumbnailRef = storage.reference().child("thumbnails/\(postId)_400x400.jpg")
        try? await thumbnailRef.delete()
        
        let originalRef = storage.reference().child("originals/\(postId).jpg")
        try? await originalRef.delete()
    }
}
