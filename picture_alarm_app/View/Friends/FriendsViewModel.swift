//
//  FriendsViewModel.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/15.
//

import Foundation
import FirebaseAuth

@MainActor
class FriendsViewModel: ObservableObject {
    
    @Published var friends: [User] = []
    @Published var isLoading = false
    
    private let userService = UserService.shared
    
    func fetchFriends() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Step 1: 友達のIDリストを取得
            let friendIds = try await userService.fetchFriendIds(forUserId: currentUserId)
            
            if friendIds.isEmpty {
                self.friends = []
                return
            }
            
            // Step 2: IDリストを元に、各ユーザーのプロフィール情報を並行して取得
            let friendsList = await withTaskGroup(of: User?.self, returning: [User].self) { group in
                for id in friendIds {
                    group.addTask {
                        return try? await self.userService.fetchUser(withId: id)
                    }
                }
                
                var results: [User] = []
                for await user in group {
                    if let user = user {
                        results.append(user)
                    }
                }
                return results
            }
            
            self.friends = friendsList
            
        } catch {
            print("Error fetching friends: \(error.localizedDescription)")
        }
    }
}
