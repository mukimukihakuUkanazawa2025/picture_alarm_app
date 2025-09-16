//
//  FriendRequest.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import Foundation
import FirebaseFirestore

struct FriendRequest: Identifiable {
    var id: String
    var fromId: String
    var toId: String
    var status: String
    var createdAt: Timestamp
}
