import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.user != nil {
            // ログイン済みならContentViewを表示
            ContentView()
        } else {
            // 未ログインならEntryViewを表示
            EntryView()
        }
    }
}
