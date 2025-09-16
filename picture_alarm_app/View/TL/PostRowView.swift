//
//  PostRowView.swift
//  picture_alarm_app
//
//  Created by 酒井みな実 on 2025/09/16.
//

import SwiftUI

struct PostRowView: View {
    let post: PostInfo

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 左カラム（ユーザー情報＋テキスト）
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)

                    Text(post.userName)
                        .font(.headline)
                        .foregroundColor(.white)
                }

                if let time = post.postTime {
                    Text(timeString(from: time))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                if !post.comments.isEmpty {
                    Text(post.comments.joined(separator: "\n"))
                        .font(.body)
                        .foregroundColor(.white)
                }

                Spacer()
            }

            Spacer()

            // 右カラム（投稿写真）
            if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
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
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.black) // 投稿背景は黒のまま
        .overlay(
            Divider().background(Color.gray),
            alignment: .bottom
        )
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
//import SwiftUI
//
//struct PostRowView: View {
//    let post: PostInfo
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack(alignment: .top, spacing: 12) {
//                // アイコン
//                Image(systemName: "person.circle.fill")
//                    .resizable()
//                    .frame(width: 40, height: 40)
//                    .foregroundColor(.gray)
//                
//                VStack(alignment: .leading, spacing: 4) {
//                    // ユーザー名 + 時間
//                    HStack {
//                        Text(post.userName)
//                            .font(.headline)
//                            .foregroundColor(.white)
//                        
//                        if let time = post.postTime {
//                            Text(timeString(from: time))
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    
//                    // コメント
//                    if !post.comments.isEmpty {
//                        Text(post.comments.joined(separator: "\n"))
//                            .font(.body)
//                            .foregroundColor(.white)
//                    }
//                }
//                
//                Spacer()
//            }
//                // 投稿写真
//                if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
//                    AsyncImage(url: url) { phase in
//                        switch phase {
//                        case .empty:
//                            ProgressView()
//                                .frame(height: 200)
//                                .frame(maxWidth: .infinity)
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 200,height: 200)
//                                .clipShape(Circle())
//                        case .failure:
//                            Image(systemName: "photo")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: 200)
//                                .foregroundColor(.gray)
//                        @unknown default:
//                            EmptyView()
//                        }
//                    }
//                }
//        
//            // 投稿ごとの仕切り線
//            Divider()
//                .background(Color.gray)
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 6)
//    }
//
//    private func timeString(from date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        return formatter.string(from: date)
//    }
//}
