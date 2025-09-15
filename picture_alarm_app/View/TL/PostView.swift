//
//  PostView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

// TLViewに流れてくる投稿の単位画面

import SwiftUI

struct PostView: View {
    
    @State var userName: String
    @State var postTime: String
    @State var userComment: String
    @State var userImage: UIImage?
    @State var postImage: UIImage?
    
    var body: some View {
        HStack {
            
            // アカウント情報
            VStack {
                HStack {
                    // ユーザー画像
                    Image(uiImage: userImage ?? UIImage(systemName: "person.circle")!)
                        .resizable()
                        .foregroundStyle(.gray)
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                    
                    VStack {
                        // アカウント名
                        Text(userName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        // 投稿時間
                        Text(postTime)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    
                    Spacer()
                }
                
                HStack {
                    // コメント
                    Text(userComment)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
            }
            
            // 投稿写真
            Image(uiImage: userImage ?? UIImage(systemName: "photo.artframe.circle.fill")!)
                .resizable()
                .foregroundStyle(.black)
                .frame(width: 150, height: 150)
                .clipShape(Circle())

        }
        .padding()
    }
}

#Preview {
    PostView(userName: "あおすけ", postTime: "07:21", userComment: "起きれたー\n絶対準備間に合わせる！")
}
