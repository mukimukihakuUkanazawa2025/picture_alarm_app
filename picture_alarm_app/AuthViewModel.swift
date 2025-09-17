import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    // 変更をViewに通知するための@Publishedプロパティ
    // ログインしていればFirebaseのUserオブジェクトが、していなければnilが入る
    @Published var user: FirebaseAuth.User?

    // Firebaseの認証状態監視リスナーへの参照を保持するためのハンドル
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        // AuthViewModelが初期化されたときに、Firebaseの認証状態の監視を開始
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            // 認証状態が変化するたびに、このクロージャが呼ばれる
            // [weak self]で循環参照を防ぐ
            self?.user = user ?? nil
        }
    }

    deinit {
        // AuthViewModelが破棄されるときに、リスナーを解除してメモリリークを防ぐ
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
