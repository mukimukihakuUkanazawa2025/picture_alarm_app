//
//  PostListViewModel.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/15.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class PostListViewModel: ObservableObject {
    @Published var posts: [PostInfo] = []
    
    private let db = Firestore.firestore()
    private let userService = UserService.shared
    
    init() {
        fetchPosts()
    }
    
    func fetchPosts() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        Task {
            do {
                // 友達のIDリストを取得
                var friendIds = try await userService.fetchFriendIds(forUserId: currentUserId)
                // 自分のIDも追加して、自分の投稿も表示されるようにする
                friendIds.append(currentUserId)
                
                // 友達と自分の投稿のみを取得する
                db.collection("posts")
                    .whereField("userId", in: friendIds)
                    .order(by: "postTime", descending: true)
                    .addSnapshotListener { [weak self] snapshot, error in
                        guard let self = self, let documents = snapshot?.documents else {
                            print("Error fetching posts: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        
                        // ユーザー情報を紐付ける
                        Task {
                            var newPosts: [PostInfo] = []
                            for doc in documents {
                                let data = doc.data()
                                let userId = data["userId"] as? String ?? ""
                                
                                // 投稿データからPostInfoを作成
                                var post = PostInfo(
                                    id: doc.documentID,
                                    userId: userId,
                                    postTime: (data["postTime"] as? Timestamp)?.dateValue(),
                                    imageUrl: data["imageUrl"] as? String,
                                    goodCount: data["goodCount"] as? Int ?? 0,
                                    comments: data["comments"] as? [String] ?? []
                                )
                                
                                // ユーザー情報を取得してpostにセット
                                post.user = try? await self.userService.fetchUser(withId: userId)
                                newPosts.append(post)
                            }
                            
                            // @Publishedプロパティの更新はメインスレッドで行う
                            await MainActor.run {
                                self.posts = newPosts
                            }
                        }
                    }
            } catch {
                print("Error fetching friends: \(error.localizedDescription)")
            }
        }
    }
}
