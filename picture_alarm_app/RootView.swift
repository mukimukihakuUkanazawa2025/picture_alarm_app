import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    
    var body: some View {
        Group{
            if let _ = authViewModel.user {
                // 🔹 ログイン済み → いきなり本体
                ContentView()
            } else {
                if !hasLaunchedBefore {
                    // 🔹 未ログイン + 初回起動 → チュートリアル
                    TutorialView(onFinish: {
                        hasLaunchedBefore = true
                    })
                } else {
                    // 🔹 未ログイン + 2回目以降 → EntryView
                    EntryView()
                }
            }
        }
//        アニメーション入れるならここ
    }
}
