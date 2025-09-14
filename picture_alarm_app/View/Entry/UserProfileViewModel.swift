//
//  UserProfileViewModel.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

@MainActor
class UserProfileViewModel: ObservableObject {
    
    // ユーザーとの関係性を表す状態
    enum FriendshipStatus {
        case none           // 何も関係がない
        case requestSent    // 自分から申請を送った
        case requestReceived// 相手から申請が来ている
        case friends        // すでに友達
    }
    
    @Published var friendshipStatus: FriendshipStatus = .none
    @Published var isLoading = false
    
    let profileUser: User // 表示対象のユーザー
    private var currentUser: FirebaseAuth.User? { Auth.auth().currentUser }
    private var incomingRequests: [FriendRequest] = []

    init(user: User) {
        self.profileUser = user
    }
    
    /// ユーザーとの現在の関係性をチェックする
    func checkFriendshipStatus() async {
        guard let currentUserId = currentUser?.uid else { return }
        
        // 自分自身のプロフィールなら何もしない
        if profileUser.id == currentUserId { return }

        self.isLoading = true
        
        // 1. すでに友達かどうかをチェック
        let areFriends = await checkIfFriends(userId1: currentUserId, userId2: profileUser.id)
        if areFriends {
            self.friendshipStatus = .friends
            self.isLoading = false
            return
        }
        
        // 2. 申請を送ったか、受け取ったかをチェック
        do {
            let request = try await checkFriendRequestStatus(from: currentUserId, to: profileUser.id)
            if let request = request {
                if request.fromId == currentUserId {
                    self.friendshipStatus = .requestSent
                } else {
                    // 承認できるように、リクエスト情報を保持しておく
                    self.incomingRequests.append(request)
                    self.friendshipStatus = .requestReceived
                }
            } else {
                self.friendshipStatus = .none
            }
        } catch {
            print("Error checking friend request status: \(error.localizedDescription)")
            self.friendshipStatus = .none
        }
        
        self.isLoading = false
    }
    
    /// 「友達になる」ボタンのアクション
    func sendRequest() {
        guard let currentUserId = currentUser?.uid else { return }
        isLoading = true
        
        UserService.shared.sendFriendRequest(to: profileUser.id, from: currentUserId) { error in
            self.isLoading = false
            if error == nil {
                self.friendshipStatus = .requestSent
            }
        }
    }
    
    /// 「承認する」ボタンのアクション
    func acceptRequest() {
        guard let requestToAccept = incomingRequests.first(where: { $0.fromId == profileUser.id }) else { return }
        isLoading = true
        
        UserService.shared.acceptFriendRequest(requestToAccept) { error in
            self.isLoading = false
            if error == nil {
                self.friendshipStatus = .friends
            }
        }
    }
    
    // --- 以下は内部で使う補助的な関数 ---
    
    private func checkIfFriends(userId1: String, userId2: String) async -> Bool {
        // user1のfriendsサブコレクションにuser2がいるかチェックするロジック
        // (UserServiceにこの関数を作っても良い)
        // ここでは簡易的に実装
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userId1).collection("friends").document(userId2)
        do {
            let document = try await docRef.getDocument()
            return document.exists
        } catch {
            return false
        }
    }
    
    private func checkFriendRequestStatus(from userId1: String, to userId2: String) async throws -> FriendRequest? {
        // from: A, to: B または from: B, to: A の申請を探す
        // (これもUserServiceに関数を作るとより綺麗)
        let db = Firestore.firestore()
        
        // A -> B のリクエスト
        let query1 = db.collection("friend_requests")
            .whereField("fromId", isEqualTo: userId1)
            .whereField("toId", isEqualTo: userId2)
        
        // B -> A のリクエスト
        let query2 = db.collection("friend_requests")
            .whereField("fromId", isEqualTo: userId2)
            .whereField("toId", isEqualTo: userId1)
            
        let snapshot1 = try await query1.getDocuments()
        if let doc = snapshot1.documents.first { return createRequest(from: doc) }
        
        let snapshot2 = try await query2.getDocuments()
        if let doc = snapshot2.documents.first { return createRequest(from: doc) }
        
        return nil
    }

    private func createRequest(from doc: QueryDocumentSnapshot) -> FriendRequest {
        let data = doc.data()
        return FriendRequest(
            id: doc.documentID,
            fromId: data["fromId"] as? String ?? "",
            toId: data["toId"] as? String ?? "",
            status: data["status"] as? String ?? "",
            createdAt: data["createdAt"] as? Timestamp ?? Timestamp()
        )
    }
}
