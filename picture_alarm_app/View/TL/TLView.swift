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
    
    @State private var name: String = ""
    @ObservedObject private var viewModel = UserViewModel()
    
    var body: some View {
        VStack {
            Text("タイムライン画面")
            
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
        }
    }
}

#Preview {
    TLView()
}
