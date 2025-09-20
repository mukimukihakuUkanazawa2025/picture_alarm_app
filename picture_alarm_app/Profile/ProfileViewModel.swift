//  ProfileViewModel.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/17.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {
    
    @Published var currentUser: User?
    @Published var friendCount = 0
    @Published var isLoading = false
    @Published var userPosts: [PostInfo] = []
    
    private let userService = UserService.shared
    private let postService = PostService()
    private let db = Firestore.firestore()
    
    func fetchUserProfile() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            self.currentUser = try await userService.fetchUser(withId: currentUserId)
            let friendIds = try await userService.fetchFriendIds(forUserId: currentUserId)
            self.friendCount = friendIds.count
        } catch {
            print("Error fetching user profile: \(error.localizedDescription)")
        }
    }
    
    //userId で投稿を検索す
    func fetchUserPosts() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("posts")
            .whereField("userId", isEqualTo: currentUserId)
            .order(by: "postTime", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                self?.userPosts = documents.compactMap { doc in
                    let data = doc.data()
                    return PostInfo(
                        id: doc.documentID,
                        userId: data["userId"] as? String ?? "",
                        postTime: (data["postTime"] as? Timestamp)?.dateValue(),
                        imageUrl: data["imageUrl"] as? String
                    )
                }
            }
    }

    func deletePost(_ post: PostInfo) async {
        do {
            try await postService.deletePost(postId: post.id)
            // UIから投稿を削除
            userPosts.removeAll { $0.id == post.id }
        } catch {
            print("Error deleting post: \(error.localizedDescription)")
        }
    }
}
