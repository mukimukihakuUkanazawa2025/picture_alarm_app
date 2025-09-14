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

struct User {
    var id: String
    var name: String
    var createAt: Timestamp
}
