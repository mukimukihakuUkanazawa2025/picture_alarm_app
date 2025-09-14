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
                // async関数を呼び出すためにTaskで囲む
                Task {
                    await self?.performSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    /// 検索を実行する
    func performSearch(query: String) async {
        isLoading = true
        defer { isLoading = false } // 関数を抜けるときに必ず実行される
        
        do {
            let users = try await UserService.shared.searchUsers(byName: query)
            self.searchResults = users
            // 新しい検索結果の申請状況を初期化
            users.forEach { user in
                self.requestStatus[user.id] = .canRequest
            }
        } catch {
            print("Error searching users: \(error.localizedDescription)")
            self.searchResults = [] // エラー時は結果をクリア
        }
    }
    
    /// 友達申請を送る
    func sendFriendRequest(to user: User) async {
        guard let currentUserId = self.currentUserId else { return }
        
        // UIに即時反映
        requestStatus[user.id] = .requestSent
        
        do {
            try await UserService.shared.sendFriendRequest(to: user.id, from: currentUserId)
        } catch {
            print("Error sending friend request: \(error.localizedDescription)")
            // エラーが起きたらボタンを元に戻す
            self.requestStatus[user.id] = .canRequest
        }
    }
}
