//
//  SignUpViewModel.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import Foundation
import FirebaseAuth

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var message = ""
    @Published var isLoading = false
    @Published var isSignUpSuccessful = false
    
    // 👇 register関数をasyncに変更
    func register() async {
        isLoading = true
        message = ""
        // deferブロックは、この関数がどんな形で終了しても最後に必ず実行される
        defer { isLoading = false }
        
        do {
            // Step 1: AuthServiceのcreateUserを `try await` で呼び出す
            let authUser = try await AuthService.shared.createUser(withEmail: email, password: password)
            
            // Step 2: UserServiceのsaveUserを `try await` で呼び出す
            try await UserService.shared.saveUser(authData: authUser, name: self.displayName)
            
            // すべて成功した場合
            self.isSignUpSuccessful = true
            
        } catch {
            // `createUser`または`saveUser`のどちらかでエラーが発生した場合、ここでキャッチする
            self.message = "アカウント作成に失敗: \(error.localizedDescription)"
            // ここでエラーの種類を判別して、より具体的なメッセージを出すことも可能
        }
    }
}
