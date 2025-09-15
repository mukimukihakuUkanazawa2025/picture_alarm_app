//
//  PostInfoViewModel.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/15.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class PostService {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func uploadPost(userName: String, imageData: Data, completion: @escaping (Error?) -> Void) {
        
        // サインイン状態確認
        guard let currentUser = Auth.auth().currentUser else {
            print("投稿失敗: ユーザー未サインイン")
            completion(NSError(domain: "PostService", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "ユーザー未サインイン"]))
            return
        }
        print("サインイン済み UID: \(currentUser.uid)")
        
        Task {
            do {
                // Firestoreの参照
                let postRef = db.collection("posts").document()
                
                // Storageに画像をアップロード
                let storageRef = storage.reference().child("posts/\(postRef.documentID).jpg")
                _ = try await storageRef.putDataAsync(imageData, metadata: nil)
                
                let url = try await storageRef.downloadURL()
                guard let urlString = url.absoluteString as String? else {
                    let error = NSError(domain: "PostService", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL取得失敗"])
                    print("Error: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                
                // Firestoreに投稿情報を保存
                let post: [String: Any] = [
                    "id": postRef.documentID,
                    "userName": userName,
                    "postTime": FieldValue.serverTimestamp(),
                    "imageUrl": urlString,
                    "goodCount": 0,
                    "comments": []
                ]
                
                try await postRef.setData(post)
                
                completion(nil)
            } catch {
                print("Error uploading post: \(error.localizedDescription)")
                completion(error)
            }
        }
    }
}
