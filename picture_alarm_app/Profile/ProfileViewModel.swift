//
//  ProfileViewModel.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/17.
//

import Foundation
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    
    @Published var currentUser: User?
    @Published var friendCount = 0
    @Published var isLoading = false
    
    private let userService = UserService.shared
    
    func fetchUserProfile() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 自分のユーザー情報をFirestoreから取得
            self.currentUser = try await userService.fetchUser(withId: currentUserId)
            
            // 自分の友達リストのIDを取得し、その数をカウント
            let friendIds = try await userService.fetchFriendIds(forUserId: currentUserId)
            self.friendCount = friendIds.count
            
        } catch {
            print("Error fetching user profile: \(error.localizedDescription)")
        }
    }
}
