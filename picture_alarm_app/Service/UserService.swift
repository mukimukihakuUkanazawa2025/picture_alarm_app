import Foundation
import FirebaseFirestore
import FirebaseAuth

// ユーザーのデータ構造
struct User: Identifiable, Codable {
    var id: String
    var name: String
    var createAt: Timestamp
    var name_lowercase: String?
    var profileImageUrl: String?
    var bio: String?
}

// ユーザーのビューモデル
class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    private init() {}
    
    /// Authで作成されたユーザー情報をFirestoreに保存する
    func saveUser(authData: FirebaseAuth.User, name: String) async throws {
        let user = User(
            id: authData.uid,
            name: name,
            createAt: Timestamp(),
            name_lowercase: name.lowercased() // 検索用の小文字の名前も保持
        )
        
        // Firestoreに保存するための辞書データを作成
        let userData: [String: Any] = [
            "id": user.id,
            "name": user.name,
            "createAt": user.createAt,
            "name_lowercase": user.name_lowercase ?? ""
        ]
        
        // ドキュメントIDをAuthのUIDと一致させて保存
        try await db.collection("users").document(user.id).setData(userData)
    }
    
    /// 友達申請を送る
    func sendFriendRequest(to toUserId: String, from fromUserId: String) async throws {
        let requestData: [String: Any] = [
            "fromId": fromUserId,
            "toId": toUserId,
            "status": "pending",
            "createdAt": Timestamp(date: Date())
        ]
        
        // addDocumentは完了ハンドラしか持たないため、`withCheckedThrowingContinuation`でラップする
        try await db.collection("friend_requests").addDocument(data: requestData)
    }
    
    /// 友達申請を承認する
    func acceptFriendRequest(_ request: FriendRequest) async throws {
        let batch = db.batch()
        
        let requestRef = db.collection("friend_requests").document(request.id)
        batch.deleteDocument(requestRef)
        
        let currentUserFriendRef = db.collection("users").document(request.toId).collection("friends").document(request.fromId)
        batch.setData(["friendshipDate": Timestamp(date: Date())], forDocument: currentUserFriendRef)
        
        let senderUserFriendRef = db.collection("users").document(request.fromId).collection("friends").document(request.toId)
        batch.setData(["friendshipDate": Timestamp(date: Date())], forDocument: senderUserFriendRef)
        
        try await batch.commit()
    }
    
    /// 友達申請を拒否またはキャンセルする
    func declineFriendRequest(requestId: String) async throws {
        try await db.collection("friend_requests").document(requestId).delete()
    }
    
    /// 自分に届いている友達申請リストを取得する
    func fetchIncomingFriendRequests(for userId: String) async throws -> [FriendRequest] {
        let snapshot = try await db.collection("friend_requests")
            .whereField("toId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        
        let requests = snapshot.documents.compactMap { doc -> FriendRequest? in
            let data = doc.data()
            return FriendRequest(
                id: doc.documentID,
                fromId: data["fromId"] as? String ?? "",
                toId: data["toId"] as? String ?? "",
                status: data["status"] as? String ?? "",
                createdAt: data["createdAt"] as? Timestamp ?? Timestamp()
            )
        }
        return requests
    }
    
    /// ユーザー名（完全一致・大文字小文字を区別しない）でユーザーを検索する
    func searchUsers(byName nameQuery: String) async throws -> [User] {
        if nameQuery.isEmpty {
            return []
        }
        
        let lowercaseQuery = nameQuery.lowercased()
                let endQuery = lowercaseQuery + "\u{f8ff}"
                
                let snapshot = try await db.collection("users")
                                           .whereField("name_lowercase", isGreaterThanOrEqualTo: lowercaseQuery)
                                           .whereField("name_lowercase", isLessThan: endQuery)
                                           .getDocuments()
        
        let users = snapshot.documents.compactMap { doc -> User? in
            let data = doc.data()
            let id = data["id"] as? String ?? ""
            
            if id == Auth.auth().currentUser?.uid { return nil }
            
            return User(
                            id: id, //ドキュメントIDをidにセット
                            name: data["name"] as? String ?? "",
                            createAt: data["createAt"] as? Timestamp ?? Timestamp(),
                            name_lowercase: data["name_lowercase"] as? String ?? "",
                            profileImageUrl: data["profileImageUrl"] as? String ?? "",
                            bio: data["bio"] as? String ?? ""
                        )
        }
        return users
    }
    
    /// ユーザーIDを指定して、単一のユーザー情報を取得する
    func fetchUser(withId uid: String) async throws -> User? {
            let document = try await db.collection("users").document(uid).getDocument()
            
            guard let data = document.data() else { return nil }
            
            //Userモデルを作成
            return User(
                id: document.documentID, // ドキュメントIDをidにセット
                name: data["name"] as? String ?? "",
                createAt: data["createAt"] as? Timestamp ?? Timestamp(),
                name_lowercase: data["name_lowercase"] as? String ?? "",
                profileImageUrl: data["profileImageUrl"] as? String ?? "",
                bio: data["bio"] as? String ?? ""
            )
        }
    /// 2人のユーザーが既に友達かどうかをチェックする
    func checkIfFriends(userId1: String, userId2: String) async -> Bool {
        let docRef = db.collection("users").document(userId1).collection("friends").document(userId2)
        do {
            return try await docRef.getDocument().exists
        } catch {
            return false
        }
    }
    
    /// 2人のユーザー間の友達申請の状態をチェックする
    func checkFriendRequestStatus(from userId1: String, to userId2: String) async throws -> FriendRequest? {
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
    
    // `checkFriendRequestStatus`が使うヘルパー関数
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
    //FriendsView用
    func fetchFriendIds(forUserId userId: String) async throws -> [String] {
        let snapshot = try await db.collection("users").document(userId).collection("friends").getDocuments()
        
        // ドキュメントIDが友達のUIDなので、それを抽出して配列にする
        let friendIds = snapshot.documents.map { $0.documentID }
        return friendIds
    }
    
    /// 友達関係を削除する
    func removeFriend(currentUserId: String, friendId: String) async throws {
        let batch = db.batch()
        
        // 1. 自分のfriendsサブコレクションから相手を削除
        let currentUserFriendRef = db.collection("users").document(currentUserId).collection("friends").document(friendId)
        batch.deleteDocument(currentUserFriendRef)
        
        // 2. 相手のfriendsサブコレクションから自分を削除
        let friendUserFriendRef = db.collection("users").document(friendId).collection("friends").document(currentUserId)
        batch.deleteDocument(friendUserFriendRef)
        
        try await batch.commit()
    }
    
    /// ユーザー情報を更新する
       func updateUserProfile(userId: String, name: String, bio: String?, newProfileImageUrl: String?) async throws {
           var data: [String: Any] = [
               "name": name,
               "name_lowercase": name.lowercased()
           ]
           
           if let bio = bio {
               data["bio"] = bio // bioはオプショナルなので、存在すれば追加
           }
           
           if let newProfileImageUrl = newProfileImageUrl {
               data["profileImageUrl"] = newProfileImageUrl // 新しい画像URLが存在すれば追加
           }
           
           // .merge() を使うと、指定したフィールドだけを更新できる
           try await db.collection("users").document(userId).setData(data, merge: true)
       }
    /// Firestoreからユーザー情報を削除する
        func deleteUser(userId: String) async throws {
            try await db.collection("users").document(userId).delete()
        }
}

