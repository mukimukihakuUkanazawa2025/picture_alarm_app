//
//  ShowUserStatusView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/19.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct ShowUserStatusView: View {
    
    @StateObject private var viewModel = UserStatusViewModel()
    
    private var currentUserId: String?{
        Auth.auth().currentUser?.uid
    }
    
    
    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//        if viewModel.
        VStack{
            HStack{
                Text("出発済みのユーザー")
                    .font(.subheadline)
                    .bold()
                    .padding(.top,4)
                Spacer()
                
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(viewModel.isLeaveUsers) { info in
                        VStack{
                            if let profileUrlString = info.user?.profileImageUrl, let url = URL(string: profileUrlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().aspectRatio(contentMode: .fill)
                                             .frame(width: 50, height: 50)
                                             .clipShape(RoundedRectangle(cornerRadius: 10))
//                                             .padding()
                                    default:
                                        Image(systemName: "person").resizable()
                                            .foregroundStyle(.black)
                                            .background(.gray)
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            } else {
                                Image(systemName: "person").resizable()
                                    .foregroundStyle(.black)
                                    .background(.gray)
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            if let username = info.user?.name{
                                Text(username)
                                    .font(.caption)
                            }else{
                                Text("no name")
                                    .font(.caption)
                            }
                        }.padding(.trailing,8)
                    }
                }
                .padding(.horizontal, 16)
            }
            Divider().background(Color.gray)
                
            HStack{
                Text("起床済みのユーザー")
                    .font(.subheadline)
                    .bold()
                    .padding(.top,4)
                Spacer()
                
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(viewModel.isWakeupUsers) { info in
                        VStack{
                            if let profileUrlString = info.user?.profileImageUrl, let url = URL(string: profileUrlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().aspectRatio(contentMode: .fill)
                                             .frame(width: 70, height: 70)
                                             .clipShape(RoundedRectangle(cornerRadius: 10))
//                                             .padding()
                                    default:
                                        Image(systemName: "person").resizable()
                                            .foregroundStyle(.black)
                                            .background(.gray)
                                            .frame(width: 70, height: 70)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                                            .padding()
                                            
                                    }
                                }
                            } else {
                                Image(systemName: "person").resizable()
                                    .foregroundStyle(.black)
                                    .background(.gray)
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            if let username = info.user?.name{
                                Text(username)
                                    .font(.caption)
                            }else{
                                Text("no name")
                                    .font(.caption)
                            }
                        }.padding(.trailing,8)
                    }
                }
                .padding(.horizontal, 16)
            }
            Divider().background(Color.gray)
            HStack{
                Text("未投稿のユーザー")
                    .font(.subheadline)
                    .bold()
                    .padding(.top,4)
                Spacer()
                
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(viewModel.noActionsUsers) { info in
                        VStack{
                            if let profileUrlString = info.user?.profileImageUrl, let url = URL(string: profileUrlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().aspectRatio(contentMode: .fill)
                                             .frame(width: 70, height: 70)
                                             .clipShape(RoundedRectangle(cornerRadius: 10))
//                                             .padding()
                                    default:
                                        Image(systemName: "person").resizable()
                                            .foregroundStyle(.black)
                                            .background(.gray)
                                            .frame(width: 70, height: 70)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            } else {
                                Image(systemName: "person").resizable()
                                    .foregroundStyle(.black)
                                    .background(.gray)
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            if let username = info.user?.name{
                                Text(username)
                                    .font(.caption)
                            }else{
                                Text("no name")
                                    .font(.caption)
                            }
                        }.padding(.trailing,8)
                    }
                }
                .padding(.horizontal, 16)
            }
            
        }
        .padding(.horizontal,10)
        .onAppear{
            viewModel.fetchUsersStatus()
        }
        
    }
}

#Preview {
    ShowUserStatusView()
}
