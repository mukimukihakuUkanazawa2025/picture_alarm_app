//
//  FriendRequestViewModel.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import Foundation
import FirebaseAuth
import FirebaseCore

// Viewが使いやすいように、申請情報と申請者の情報を組み合わせた構造体
struct FriendRequestInfo: Identifiable {
    let id: String // 申請ドキュメントのID
    let sender: User // 申請を送ってきたユーザー
    let request: FriendRequest // 元の申請情報
}

@MainActor
class FriendRequestsViewModel: ObservableObject {
    
    @Published var incomingRequests: [FriendRequestInfo] = []
    @Published var isLoading = false
    
    private let userService = UserService.shared
    
    func fetchRequests() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        // この関数を抜けるときに、必ずisLoadingをfalseにする
        defer {
            isLoading = false
        }
        
        do {
            let requests = try await userService.fetchIncomingFriendRequests(for: currentUserId)
            
            if requests.isEmpty {
                self.incomingRequests = []
                return // ここでreturnしても、上のdeferが実行されるので問題ない
            }
            
            let requestInfos = await withTaskGroup(of: FriendRequestInfo?.self, returning: [FriendRequestInfo].self) { group in
                for request in requests {
                    group.addTask {
                        if let user = try? await self.userService.fetchUser(withId: request.fromId) {
                            return FriendRequestInfo(id: request.id, sender: user, request: request)
                        }
                        return nil
                    }
                }
                
                var results: [FriendRequestInfo] = []
                for await result in group {
                    if let info = result {
                        results.append(info)
                    }
                }
                return results
            }
            
            self.incomingRequests = requestInfos
            
        } catch {
            print("Error fetching friend requests: \(error.localizedDescription)")
          
        }
    }
    
    
    /// 友達申請を承認する
    func acceptRequest(from requestInfo: FriendRequestInfo) async {
        do {
            try await userService.acceptFriendRequest(requestInfo.request)
            // 成功したらリストから即時削除してUIに反映
            incomingRequests.removeAll { $0.id == requestInfo.id }
        } catch {
            print("Error accepting friend request: \(error.localizedDescription)")
        }
    }
    
    /// 友達申請を拒否する
    func declineRequest(from requestInfo: FriendRequestInfo) async {
        do {
            try await userService.declineFriendRequest(requestId: requestInfo.id)
            // 成功したらリストから即時削除してUIに反映
            incomingRequests.removeAll { $0.id == requestInfo.id }
        } catch {
            print("Error declining friend request: \(error.localizedDescription)")
        }
    }
}


