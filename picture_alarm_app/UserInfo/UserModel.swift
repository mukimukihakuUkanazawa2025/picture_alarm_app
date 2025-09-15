//
//  UserModel.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/15.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct User: Identifiable {
    var id: String // Firebaseでの識別用ID
    
    var userName: String
    var userID: String // アプリ内でのユーザー固有ID
    
    var userImageURL: String?
    var failedImageURL: String?
}
