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
            VStack(spacing: 40) {
                Spacer()
                Text("寝顔人質カメラ")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 20) {
                    Button {
                        showLoginView = true
                    } label: {
                        Text("ログイン")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    
                    }
                    .fullScreenCover(isPresented: $showLoginView) {
                        LoginView()
                    }
                    
                    Button {
                        showSignUpView = true
                    } label: {
                        Text("アカウント作成")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(Color.blue, lineWidth: 2)
//                            )
                    }
                    .fullScreenCover(isPresented: $showSignUpView) {
                        SignUpView()
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .background(.black)
            .ignoresSafeArea()
        }
    }

#Preview {
    EntryView()
}
