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
    
    @Published var users: [User] = []
    
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
    
    func fetchUsers() {
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.users = snapshot?.documents.map {
                    User(id: $0.documentID,
                         name: $0.data()["name"] as? String ?? "",
                         createAt: $0.data()["createAt"] as? Timestamp ?? Timestamp())
                } ?? []
            }
        }
    }
}
