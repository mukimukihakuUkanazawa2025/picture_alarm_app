//
//  EntryView.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import SwiftUI

struct EntryView: View {
    @State var showLoginView: Bool = false
    @State var showSignUpView: Bool = false
    
    var body: some View {
        VStack{
            Text("寝顔人質カメラ")
            Button{
                showLoginView = true
            }label: {
                Text("ログイン")
            }
            .fullScreenCover(isPresented: $showLoginView){
                LoginView()
            }
            Button{
                showSignUpView = true
            }label: {
                Text("アカウント作成")
            }
            .fullScreenCover(isPresented: $showSignUpView){
                SignUpView()
            }
        }
        }
        
    }


#Preview {
    EntryView()
}
