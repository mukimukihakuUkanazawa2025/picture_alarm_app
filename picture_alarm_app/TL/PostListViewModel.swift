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
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        Task {
            do {
                // 自分と友達のIDを取得
                var friendIds = try await userService.fetchFriendIds(forUserId: currentUserId)
                friendIds.append(currentUserId)

                // Firestoreからpostsを取得
                db.collection("posts")
                    .whereField("userId", in: friendIds)
                    .order(by: "postTime", descending: true)
                    .addSnapshotListener { [weak self] snapshot, error in
                        guard let self = self, let documents = snapshot?.documents else { return }

                        Task {
                            var newPosts: [PostInfo] = []
                            var userCache: [String: User] = [:] // cache fetched users

                            await withTaskGroup(of: (String, User?).self) { group in
                                for doc in documents {
                                    let data = doc.data()
                                    let userId = data["userId"] as? String ?? ""

                                    group.addTask {
                                        if let cachedUser = userCache[userId] {
                                            return (userId, cachedUser)
                                        }
                                        let user = try? await self.userService.fetchUser(withId: userId)
                                        return (userId, user)
                                    }
                                }

                                for await (userId, user) in group {
                                    userCache[userId] = user
                                }
                            }

                            for doc in documents {
                                let data = doc.data()
                                let userId = data["userId"] as? String ?? ""

                                let post = PostInfo(
                                    id: doc.documentID,
                                    userId: userId,
                                    postTime: (data["postTime"] as? Timestamp)?.dateValue(),
                                    imageUrl: data["imageUrl"] as? String,
                                    goodCount: data["goodCount"] as? Int ?? 0,
                                    comments: data["comments"] as? [String] ?? [],
                                    user: userCache[userId],
                                    status: data["status"] as? String,
                                    thumbnailUrl: data["thumbnailUrl"] as? String
                                )
                                newPosts.append(post)
                            }

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
