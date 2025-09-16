//
//  EntryView.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import SwiftUI

struct EntryView: View {
    @State private var navigateToLogin = false
    @State private var navigateToSignUp = false
    @State private var navigateToContent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 80) {
                Spacer()
                
                Text("寝顔人質カメラ")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("ログインまたはアカウント作成")
                    .foregroundStyle(.white)
                    .font(.system(size: 18))
                
                VStack(spacing: 20) {
                    // ログイン
                    NavigationLink(destination: LoginView(onSuccess: {
                        self.navigateToContent = true
                    }), isActive: $navigateToLogin) {
                        Text("ログイン")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 1.0, green: 131/255.0, blue: 0.0))
                            .cornerRadius(12)
                    }
                    
                    // サインアップ
                    NavigationLink(destination: SignUpView(onSuccess: {
                        self.navigateToContent = true
                    }), isActive: $navigateToSignUp) {
                        Text("アカウント作成")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 20)
                    Text("続行することで利用規約及びプライバシーポリシーに同意したとみなします")
                        .foregroundStyle(.white)
                        .font(.system(size: 15))
                        .padding(.bottom, 20)
                }
                .foregroundStyle(.white)
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
                
                // 成功したら ContentView へ
                NavigationLink(destination: ContentView(),
                               isActive: $navigateToContent,
                               label: { EmptyView() })
            }
            .background(.black)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    EntryView()
}
//developに統合するために無駄に書いたよ！
