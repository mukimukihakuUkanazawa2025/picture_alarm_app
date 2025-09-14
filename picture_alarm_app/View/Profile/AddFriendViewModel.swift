//
//  AddFriendViewModel.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//
import SwiftUI
import Foundation
import Combine
import FirebaseAuth

@MainActor
class AddFriendViewModel: ObservableObject {
    
    enum RequestStatus {
        case canRequest, requestSent
    }
    
    @Published var searchText = ""
    @Published var searchResults: [User] = []
    @Published var requestStatus: [String: RequestStatus] = [:]
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let currentUserId = Auth.auth().currentUser?.uid

    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    func performSearch(query: String) {
        isLoading = true
        UserService.shared.searchUsers(byName: query) { [weak self] users, error in
            self?.isLoading = false
            if let users = users {
                self?.searchResults = users
                users.forEach { user in
                    self?.requestStatus[user.id] = .canRequest
                }
            }
        }
    }
    
    func sendFriendRequest(to user: User) {
        guard let currentUserId = self.currentUserId else { return }
        
        requestStatus[user.id] = .requestSent
        
        UserService.shared.sendFriendRequest(to: user.id, from: currentUserId) { error in
            if let error = error {
                print("Error sending friend request: \(error.localizedDescription)")
                self.requestStatus[user.id] = .canRequest
            }
        }
    }
}
//#Preview {
//    AddFriendViewModel()
//}
