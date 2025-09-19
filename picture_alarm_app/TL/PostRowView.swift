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
                    // ユーザー確認を行なっていないため、無条件でelseになる
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
                
                switch post.status {
                case "iswakeup":
                    Text("起床済み")
                        .font(.caption2).foregroundColor(.gray)
                case "isleave":
                    Text("出発済み")
                        .font(.caption2).foregroundColor(.gray)
                case "noaction":
                    Text("その他")
                        .font(.caption2).foregroundColor(.gray)
                case .none:
                    Text("その他")
                        .font(.caption2).foregroundColor(.gray)
                    //                    break
                case .some(_):
                    Text("その他")
                        .font(.caption2).foregroundColor(.gray)
                }
                
            }
            Spacer()
            // 右カラム（投稿写真）
            if  post.status != "iswakeup" {
                
                
                
                if let thumb = post.thumbnailUrl, let url = URL(string: thumb) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                                .frame(width: 150, height: 150).clipShape(Circle())
                                .onAppear { print("Thumbnail loaded successfully: \(url.absoluteString)") }
                        default:
                            // fallback to full image if thumbnail fails
                            if let full = post.imageUrl, let fullUrl = URL(string: full) {
                                AsyncImage(url: fullUrl) { fullPhase in
                                    switch fullPhase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                            .frame(width: 150, height: 150).clipShape(Circle())
                                            .onAppear { print("Full image loaded as fallback: \(fullUrl.absoluteString)") }
                                    default:
                                        ProgressView().frame(width: 150, height: 150)
                                    }
                                }
                            } else {
                                ProgressView().frame(width: 150, height: 150)
                            }
                        }
                    }
                } else if let full = post.imageUrl, let fullUrl = URL(string: full) {
                    AsyncImage(url: fullUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                                .frame(width: 150, height: 150).clipShape(Circle())
                                .onAppear { print("Full image loaded: \(fullUrl.absoluteString)") }
                        default:
                            ProgressView().frame(width: 150, height: 150)
                        }
                    }
                } else {
                    
                }
               
                
                
            }else{
                VStack(alignment: .center){
                    Spacer()
                    
                    Text("起床成功！")
                        .bold()
                    //                            .font(.title)
                        .foregroundStyle(.white)
                        .font(.system(.title, design: .rounded))
 
                    Spacer()
                    
                    
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
