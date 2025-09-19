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
    //    @State var wakeUpTime: String
    //    @State var departTime: String
    @State var userComment: String
    @State var userImage: UIImage?
    @State var postImage: UIImage? = nil
    var postImageUrl: URL? = nil
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                // --- 左側（ユーザ情報） ---
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        // ユーザアイコン（userImage が nil の場合はデフォルトアイコンを表示）
                        if let userImage = userImage {
                            Image(uiImage: userImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            // ユーザー名
                            Text(userName)
                                .font(.headline)
                                .foregroundColor(.white)
                            // 投稿時間
                            Text(postTime)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // コメント
                    if !userComment.isEmpty {
                        Text(userComment)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
                
                // --- 右側（投稿写真） ---
                // 投稿画像
                if let url = postImageUrl {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 150, height: 150)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                // 区切り線
                Divider().background(Color.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    PostView(userName: "あおすけ", postTime: "07:21", userComment: "起きれたー\n絶対準備間に合わせる！")
}
