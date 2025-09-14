//
//  UserViewModel.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/14.
//

import Foundation
import FirebaseFirestore

class UserViewModel: ObservableObject {
    private var db = Firestore.firestore()
    
    func saveUser(name: String, completion: @escaping (Error?) -> Void) {
        let docRef = db.collection("users").document()
        
        let user = User(id: docRef.documentID, name: name, createAt: Timestamp())
        
        docRef.setData([
            "id": user.id,
            "name": user.name,
            "createAt": user.createAt
        ]) { error in
            completion(error)
        }
    }
}
