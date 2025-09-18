//
//  PostRowView.swift
//  picture_alarm_app
//
//  Created by 酒井みな実 on 2025/09/16.
//

// picture_alarm_app/TL/PostRowView.swift

import SwiftUI

struct PostRowView: View {
    let post: PostInfo

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 左カラム（ユーザー情報＋テキスト）
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    // post.user からプロフィール画像を
                    if let profileUrlString = post.user?.profileImageUrl, let url = URL(string: profileUrlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fill)
                                     .frame(width: 40, height: 40).clipShape(Circle())
                            default:
                                Image(systemName: "person.circle.fill").resizable()
                                     .frame(width: 40, height: 40).foregroundColor(.gray)
                            }
                        }
                    } else {
                        Image(systemName: "person.circle.fill").resizable()
                             .frame(width: 40, height: 40).foregroundColor(.gray)
                    }

                    // post.user からユーザー名を表示
                    Text(post.user?.name ?? "名無しさん")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                if let time = post.postTime {
                    Text(timeString(from: time))
                        .font(.subheadline).foregroundColor(.gray)
                }
                if !post.comments.isEmpty {
                    Text(post.comments.joined(separator: "\n"))
                        .font(.body).foregroundColor(.white)
                }
                Spacer()
            }
            Spacer()
            // 右カラム（投稿写真）
            if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                             .frame(width: 150, height: 150).clipShape(Circle())
                    default:
                        ProgressView().frame(width: 150, height: 150)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.black)
        .overlay(Divider().background(Color.gray), alignment: .bottom)
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
