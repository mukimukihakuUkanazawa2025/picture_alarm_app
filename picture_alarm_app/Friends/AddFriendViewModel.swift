import Foundation
import Combine
import FirebaseAuth

@MainActor
class AddFriendViewModel: ObservableObject {
    
    enum RelationshipStatus {
        case none, requestSent, friends
    }
    
    @Published var searchText = ""
    @Published var searchResults: [User] = []
    @Published var relationshipStatus: [String: RelationshipStatus] = [:]
    @Published var isLoading = false
    
    private var sentRequests: [String: FriendRequest] = [:]
    private var cancellables = Set<AnyCancellable>()
    private let currentUserId = Auth.auth().currentUser?.uid
    private let userService = UserService.shared

    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task { await self?.performSearch(query: query) }
            }
            .store(in: &cancellables)
    }
    
    func performSearch(query: String) async {
        guard let currentUserId = self.currentUserId, !query.isEmpty else {
            self.searchResults = []
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let users = try await userService.searchUsers(byName: query)
            self.searchResults = users
            
            // TaskGroupを使って関係性を並行チェック
            self.relationshipStatus = await withTaskGroup(
                of: (String, RelationshipStatus, FriendRequest?).self,
                returning: [String: RelationshipStatus].self
            ) { group in
                
                for user in users {
                    let userId = user.id
                    
                    group.addTask {
                        if await self.userService.checkIfFriends(userId1: currentUserId, userId2: userId) {
                            return (userId, .friends, nil)
                        } else if let request = try? await self.userService.checkFriendRequestStatus(from: currentUserId, to: userId) {
                            if request.fromId == currentUserId {
                                return (userId, .requestSent, request)
                            }
                        }
                        return (userId, .none, nil)
                    }
                }
                
                var statuses: [String: RelationshipStatus] = [:]
                for await (userId, status, request) in group {
                    statuses[userId] = status
                    if let request = request { self.sentRequests[userId] = request }
                }
                return statuses
            }
        } catch {
            print("Error searching users: \(error.localizedDescription)")
            self.searchResults = []
        }
    }
    
    func sendFriendRequest(to user: User) async {
        guard let currentUserId = self.currentUserId else { return }
        let userId = user.id // 👇 guard letは不要
        
        relationshipStatus[userId] = .requestSent
        
        do {
            try await userService.sendFriendRequest(to: userId, from: currentUserId)
            await performSearch(query: self.searchText)
        } catch {
            print("Error sending friend request: \(error.localizedDescription)")
            relationshipStatus[userId] = .none
        }
    }
    
    func cancelFriendRequest(to user: User) async {
        let userId = user.id // 👇 guard letは不要
        guard let requestToCancel = self.sentRequests[userId] else { return }
        
        relationshipStatus[userId] = .none
        
        do {
            try await userService.declineFriendRequest(requestId: requestToCancel.id)
        } catch {
            print("Error canceling friend request: \(error.localizedDescription)")
            relationshipStatus[userId] = .requestSent
        }
    }
}
