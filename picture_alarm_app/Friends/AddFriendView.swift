//
//  AddFriendView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/12.
//
//
import SwiftUI

struct AddFriendView: View {
    @StateObject private var viewModel = AddFriendViewModel()
    @Environment(\.dismiss) private var dismiss

    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading && !viewModel.searchText.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if !viewModel.searchText.isEmpty && viewModel.searchResults.isEmpty {
                    // 検索しても結果がなかった場合の表示
                    ContentUnavailableView("ユーザーが見つかりません", systemImage: "person.fill.questionmark")
                } else if viewModel.searchResults.isEmpty {
                    // 初期状態（まだ検索していない）の表示
                    ContentUnavailableView("ユーザー名で友達を検索", systemImage: "magnifyingglass")
                } else {
                    // 検索結果リスト
                    List(viewModel.searchResults) { user in
                        HStack(spacing: 15) {
                            // ユーザーのプロフィール画像を表示
                            AsyncImage(url: URL(string: user.profileImageUrl ?? "")) { image in
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
                            
                            Text(user.name)
                                .font(.subheadline)
                                .bold()
                            Spacer()
                            
                            if let status = viewModel.requestStatus[user.id] {
                                switch status {
                                case .canRequest:
                                    Button("追加") {
                                        Task {
                                            await viewModel.sendFriendRequest(to: user)
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue)
                                case .requestSent:
                                    Button("申請済み") {}
                                    .buttonStyle(.bordered)
                                    .disabled(true)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(Color.black)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
                Spacer() // 検索結果が少ない場合にリストが中央に来るのを防ぐよう
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .navigationTitle("友達を追加")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "ユーザー名で検索")
            .textInputAutocapitalization(.never)
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
    AddFriendView()
}
