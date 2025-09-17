//
//  FriendsView.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/15.
//

import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                    // ローディング表示の色を白にする
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if viewModel.friends.isEmpty {
                    // 友達がいない場合の表示を改善
                    VStack(spacing: 10) {
                        Image(systemName: "person.2.slash")
                            .font(.largeTitle)
                        Text("まだ友達がいません")
                    }
                    .foregroundColor(.gray)
                } else {
                    // Listのスタイルをカスタマイズ
                    List(viewModel.friends) { friend in
                        NavigationLink(destination: UserProfileView(user: friend)) {
                            HStack(spacing: 15) {
                                // 実際のプロフィール画像を表示するように変更
                                AsyncImage(url: URL(string: friend.profileImageUrl ?? "")) { image in
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
                                
                                Text(friend.name)
                                    .fontWeight(.bold)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 8)
                        }
                        // 各行の背景を黒に設定
                        .listRowBackground(Color.black)
                        // 行の区切り線を非表示にする
                        .listRowSeparator(.hidden)
                    }
                    // List全体の背景を非表示にし、VStackの背景が見えるようにする
                    .scrollContentBackground(.hidden)
                    // Listの標準スタイルをPlainに設定
                    .listStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black) // VStackの背景を黒に
            .navigationTitle("友達")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await viewModel.fetchFriends()
                }
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    FriendsView()
}
