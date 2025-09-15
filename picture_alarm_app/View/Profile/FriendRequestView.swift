//
//  FriendRequestView.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import SwiftUI

struct FriendRequestsView: View {
    @StateObject private var viewModel = FriendRequestsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.incomingRequests.isEmpty {
                    Text("新しい友達申請はありません")
                        .foregroundColor(.gray)
                } else {
                    List(viewModel.incomingRequests) { requestInfo in
                        HStack {
                            // 申請者の名前
                            Text(requestInfo.sender.name)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            // 承認ボタン
                            Button("承認") {
                                Task {
                                    await viewModel.acceptRequest(from: requestInfo)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            
                            // 拒否（削除）ボタン
                            Button("削除") {
                                Task {
                                    await viewModel.declineRequest(from: requestInfo)
                                }
                            }
                            .buttonStyle(.bordered)
                            .tint(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("届いた友達申請")
            .onAppear {
                // 画面が表示された時に申請リストを取得
                Task {
                    await viewModel.fetchRequests()
                }
            }
        }
    }
}

