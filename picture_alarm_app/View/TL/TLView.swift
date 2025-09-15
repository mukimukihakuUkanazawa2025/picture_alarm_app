//
//  TLView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

// 自分や他人の投稿を表示する画面

import SwiftUI
import FirebaseFirestore

struct TLView: View {
    
    @StateObject private var viewModel = PostListViewModel()
    

    var body: some View {
        NavigationView {
            List(viewModel.posts) { post in
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.userName)
                        .font(.headline)
                    if let postTime = post.postTime {
                        Text(postTime, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(height: 300)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    HStack {
                        Text("いいね: \(post.goodCount)")
                        Spacer()
                        Text("コメント: \(post.comments.count)")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("投稿一覧")
        }
    }
}

#Preview {
    TLView()
}
