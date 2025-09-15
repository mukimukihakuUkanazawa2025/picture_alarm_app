//
//  testView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/14.
//

import SwiftUI
import FirebaseFirestore

struct TestView: View {
    
    @State private var name: String = ""
    @ObservedObject private var viewModel = UserViewModel()
    
    var body: some View {
        VStack {
            Text("テスト画面")
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save") {
                viewModel.saveUser(name: name) { error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else {
                        print("User saved successfully!")
                    }
                }
            }
            
            List(viewModel.users) { user in
                VStack(alignment: .leading) {
                    Text(user.name)
                    Text("ID: \(user.id)")
                }
            }
            .onAppear {
                viewModel.fetchUsers()
            }
        }
    }
}

#Preview {
    TestView()
}
