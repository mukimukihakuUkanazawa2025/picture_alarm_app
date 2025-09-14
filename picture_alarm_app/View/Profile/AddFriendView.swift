//
//  AddFriendView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//

import SwiftUI

struct AddFriendView: View {
    @StateObject private var viewModel = AddFriendViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                    Spacer()
                } else {
                    List(viewModel.searchResults) { user in
                        HStack {
                            Text(user.name)
                            Spacer()
                            
                            if let status = viewModel.requestStatus[user.id] {
                                switch status {
                                case .canRequest:
                                    Button("追加") {
                                        viewModel.sendFriendRequest(to: user)
                                    }
                                    .buttonStyle(.borderedProminent)
                                case .requestSent:
                                    Button("申請済み") {}
                                    .buttonStyle(.bordered)
                                    .disabled(true)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("友達を追加")
            .searchable(text: $viewModel.searchText, prompt: "ユーザー名で検索")
            .textInputAutocapitalization(.never)
        }
    }
}

#Preview {
    AddFriendView()
}
