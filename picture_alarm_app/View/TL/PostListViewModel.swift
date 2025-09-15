//
//  PostListViewModel.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/15.
//

import SwiftUI
import FirebaseFirestore

class PostListViewModel: ObservableObject {
    @Published var posts: [PostInfo] = []
    
    private let db = Firestore.firestore()
    
    init() {
        fetchPosts()
    }
    
    func fetchPosts() {
        db.collection("posts")
            .order(by: "postTime", descending: true) // 最新順
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Firestore fetch error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self?.posts = documents.compactMap { doc in
                    let data = doc.data()
                    return PostInfo(
                        id: doc.documentID,
                        userName: data["userName"] as? String ?? "",
                        postTime: (data["postTime"] as? Timestamp)?.dateValue(),
                        imageUrl: data["imageUrl"] as? String,
                        goodCount: data["goodCount"] as? Int ?? 0,
                        comments: data["comments"] as? [String] ?? []
                    )
                }
            }
    }
}
