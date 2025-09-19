import Foundation
import FirebaseAuth

@MainActor
class UserProfileViewModel: ObservableObject {
    
    enum FriendshipStatus {
        case none, requestSent, requestReceived, friends
    }
    
    @Published var friendshipStatus: FriendshipStatus = .none
    @Published var isLoading = false
    
    let profileUser: User
    
    private var currentUser: FirebaseAuth.User? { Auth.auth().currentUser }
    //申請情報保持のためのプロパティ
    
    private var sentRequest: FriendRequest?//自分から送った申請
    private var receivedRequest: FriendRequest?//相手から受け取った申請

    init(user: User) {
        self.profileUser = user
    }
    
    /// ユーザーとの現在の関係性をチェックする
    func checkFriendshipStatus() async {
        guard let currentUserId = currentUser?.uid, profileUser.id != currentUserId else { return }
        
        isLoading = true
        // deferブロックは、この関数がどんな形で終了しても（returnやエラーでも）最後に必ず実行される
        defer { isLoading = false }
        
        if await UserService.shared.checkIfFriends(userId1: currentUserId, userId2: profileUser.id) {
            self.friendshipStatus = .friends
        } else {
            do {
                if let request = try await UserService.shared.checkFriendRequestStatus(from: currentUserId, to: profileUser.id) {
                    if request.fromId == currentUserId {
                        self.sentRequest = request
                        self.friendshipStatus = .requestSent
                    } else {
                        self.receivedRequest = request
                        self.friendshipStatus = .requestReceived
                    }
                } else {
                    self.friendshipStatus = .none
                }
            } catch {
                print("Error checking friend request status: \(error.localizedDescription)")
                self.friendshipStatus = .none
            }
        }
    }
    
    /// 「友達になる」ボタンのアクション
    func sendRequest() async {
        guard let currentUserId = currentUser?.uid else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await UserService.shared.sendFriendRequest(to: profileUser.id, from: currentUserId)
            await checkFriendshipStatus()
            self.friendshipStatus = .requestSent
        } catch {
            print("Error sending request: \(error.localizedDescription)")
        }
    }
    
    /// 「承認する」ボタンのアクション
    func acceptRequest() async {
        guard let requestToAccept = self.receivedRequest else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await UserService.shared.acceptFriendRequest(requestToAccept)
            self.friendshipStatus = .friends
        } catch {
            print("Error accepting request: \(error.localizedDescription)")
        }
    }
    /// 申請を取り消す
        func cancelRequest() async {
            guard let requestToCancel = self.sentRequest else { return }
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await UserService.shared.declineFriendRequest(requestId: requestToCancel.id)
                self.friendshipStatus = .none
            } catch {
                print("Error canceling request: \(error.localizedDescription)")
            }
        }
        
        /// 友達を削除する
        func removeFriend() async {
            guard let currentUserId = currentUser?.uid else { return }
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await UserService.shared.removeFriend(currentUserId: currentUserId, friendId: profileUser.id)
                self.friendshipStatus = .none
            } catch {
                print("Error removing friend: \(error.localizedDescription)")
            }
        }
    }
