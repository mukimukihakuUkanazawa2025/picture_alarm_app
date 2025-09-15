//
//  UserModel.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/14.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var createAt: Timestamp
    var name_lowercase: String?
    var profileImageUrl: String?
}
