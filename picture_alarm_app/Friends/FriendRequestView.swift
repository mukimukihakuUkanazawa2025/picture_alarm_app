//
//  FriendRequestView.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/14.
//

import SwiftUI

struct FriendRequestsView: View {
    @StateObject private var viewModel = FriendRequestsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if viewModel.incomingRequests.isEmpty {
                    // 友達申請がない場合の表示
                    VStack(spacing: 10) {
                        Image(systemName: "bell.slash")
                            .font(.largeTitle)
                        Text("新しい友達申請はありません")
                    }
                    .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(viewModel.incomingRequests) { requestInfo in
                            HStack(spacing: 15) {
                                // 申請者のプロフィール画像を表示
                                AsyncImage(url: URL(string: requestInfo.sender.profileImageUrl ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                                
                                // 申請者の名前
                                VStack{
                                    Text(requestInfo.sender.name)
                                        .fontWeight(.bold)
                                        .font(.subheadline)
                                }
                                Spacer()
                                
                                // 承認ボタン
                                Button("承認") {
                                    Task {
                                        await viewModel.acceptRequest(from: requestInfo)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                                .fontWeight(.bold)
                                .font(.subheadline)
                                
                                // 削除ボタン
                                Button("削除") {
                                    Task {
                                        await viewModel.declineRequest(from: requestInfo)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .tint(.gray)
                                .font(.subheadline)
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color.black)
                        .listRowSeparator(.hidden)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .navigationTitle("届いた友達申請")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await viewModel.fetchRequests()
                }
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button("閉じる"){
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    FriendRequestsView()
}
