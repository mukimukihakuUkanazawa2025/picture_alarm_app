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
    let columns = [GridItem(.flexible())]
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                if viewModel.posts.isEmpty {
                    Text("まだ投稿はありません")
                        .foregroundStyle(.gray)
                        .padding()
                }
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.posts) { post in
                        postView(for: post)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)  // 各セル内上下余白
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private func postTimeString(from date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    @ViewBuilder
    private func postView(for post: PostInfo) -> some View {
        let postTimeString = postTimeString(from: post.postTime)
        let commentString = post.comments.joined(separator: "\n")
        
        HStack {
            PostView(
                userName: post.userName,
                postTime: postTimeString,
                userComment: commentString,
                userImage: nil,
                postImage: nil
            )
            if let imageUrlString = post.imageUrl, let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 100, height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    TLView()
}
