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
    // --- ここから友達機能 ---

        /// 友達申請を送る
        /// - Parameters:
        ///   - toUserId: 申請を送る相手のUID
        ///   - fromUserId: 自分のUID
        func sendFriendRequest(to toUserId: String, from fromUserId: String, completion: @escaping (Error?) -> Void) {
            let requestData: [String: Any] = [
                "fromId": fromUserId,
                "toId": toUserId,
                "status": "pending",
                "createdAt": Timestamp(date: Date())
            ]
            
            db.collection("friend_requests").addDocument(data: requestData, completion: completion)
        }
        
        /// 友達申請を承認する
        /// - Parameter request: 承認するFriendRequestオブジェクト
        func acceptFriendRequest(_ request: FriendRequest, completion: @escaping (Error?) -> Void) {
            // バッチ書き込みを開始
            let batch = db.batch()
            
            // 1. 申請ドキュメントを削除
            let requestRef = db.collection("friend_requests").document(request.id)
            batch.deleteDocument(requestRef)
            
            // 2. 自分のfriendsサブコレクションに相手を追加
            let currentUserFriendRef = db.collection("users").document(request.toId).collection("friends").document(request.fromId)
            batch.setData(["friendshipDate": Timestamp(date: Date())], forDocument: currentUserFriendRef)
            
            // 3. 相手のfriendsサブコレクションに自分を追加
            let senderUserFriendRef = db.collection("users").document(request.fromId).collection("friends").document(request.toId)
            batch.setData(["friendshipDate": Timestamp(date: Date())], forDocument: senderUserFriendRef)
            
            // 3つの処理をまとめて実行
            batch.commit(completion: completion)
        }

        /// 友達申請を拒否またはキャンセルする
        /// - Parameter requestId: 拒否/キャンセルする申請ドキュメントのID
        func declineFriendRequest(requestId: String, completion: @escaping (Error?) -> Void) {
            db.collection("friend_requests").document(requestId).delete(completion: completion)
        }

        /// 自分に届いている友達申請リストを取得する
        /// - Parameter userId: 自分のUID
        func fetchIncomingFriendRequests(for userId: String, completion: @escaping ([FriendRequest]?, Error?) -> Void) {
            db.collection("friend_requests")
              .whereField("toId", isEqualTo: userId)
              .whereField("status", isEqualTo: "pending")
              .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                let requests = snapshot?.documents.compactMap { doc -> FriendRequest? in
                    let data = doc.data()
                    return FriendRequest(
                        id: doc.documentID,
                        fromId: data["fromId"] as? String ?? "",
                        toId: data["toId"] as? String ?? "",
                        status: data["status"] as? String ?? "",
                        createdAt: data["createdAt"] as? Timestamp ?? Timestamp()
                    )
                }
                completion(requests, nil)
            }
        }
    /// ユーザー名（完全一致）でユーザーを検索する
       func searchUsers(byName nameQuery: String, completion: @escaping ([User]?, Error?) -> Void) {
           if nameQuery.isEmpty {
               completion([], nil)
               return
           }
           
           // ▼▼▼ このクエリ部分だけを変更します ▼▼▼
           db.collection("users")
             .whereField("name", isEqualTo: nameQuery) // "isEqualTo" で完全一致検索
             .getDocuments { snapshot, error in
           // ▲▲▲ このクエリ部分だけを変更します ▲▲▲
               
               if let error = error {
                   completion(nil, error)
                   return
               }
               
               let users = snapshot?.documents.compactMap { doc -> User? in
                   let data = doc.data()
                   let id = data["id"] as? String ?? ""
                   
                   if id == Auth.auth().currentUser?.uid {
                       return nil
                   }
                   
                   return User(
                       id: id,
                       name: data["name"] as? String ?? "",
                       createAt: data["createAt"] as? Timestamp ?? Timestamp()
                   )
               }
               completion(users, nil)
           }
       }
    }
