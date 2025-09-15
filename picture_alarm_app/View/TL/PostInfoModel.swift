//
//  PostInfoModel.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/15.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct PostInfo: Identifiable {
    var id: String // Firebaseでの識別用
    var userName: String // ユーザー名
    var postTime: Date? // 投稿時刻
    var imageUrl: String?
    var goodCount: Int = 0 // いいね数
    var comments: [String] = [] // コメント
}
