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
        VStack{
            Text("出発済み")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(viewModel.isLeaveUsers) { info in
                        VStack{
                            if let profileUrlString = info.user?.profileImageUrl, let url = URL(string: profileUrlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().aspectRatio(contentMode: .fill)
                                             .frame(width: 40, height: 40)
                                             .clipShape(Circle())
                                    default:
                                        Image(systemName: "person.circle.fill").resizable()
                                             .frame(width: 40, height: 40)
                                             .foregroundColor(.gray)
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle.fill").resizable()
                                     .frame(width: 40, height: 40)
                                     .foregroundColor(.gray)
                            }
                            
                            if let username = info.user?.name{
                                Text(username)
                                    .font(.caption)
                            }else{
                                Text("no name")
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            Text("起床済み")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(viewModel.isWakeupUsers) { info in
                        VStack{
                            if let profileUrlString = info.user?.profileImageUrl, let url = URL(string: profileUrlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().aspectRatio(contentMode: .fill)
                                             .frame(width: 40, height: 40)
                                             .clipShape(Circle())
                                    default:
                                        Image(systemName: "person.circle.fill").resizable()
                                             .frame(width: 40, height: 40)
                                             .foregroundColor(.gray)
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle.fill").resizable()
                                     .frame(width: 40, height: 40)
                                     .foregroundColor(.gray)
                            }
                            
                            if let username = info.user?.name{
                                Text(username)
                                    .font(.caption)
                            }else{
                                Text("no name")
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            Text("予定無しor寝坊")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(viewModel.noActionsUsers) { info in
                        VStack{
                            if let profileUrlString = info.user?.profileImageUrl, let url = URL(string: profileUrlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().aspectRatio(contentMode: .fill)
                                             .frame(width: 40, height: 40)
                                             .clipShape(Circle())
                                    default:
                                        Image(systemName: "person.circle.fill").resizable()
                                             .frame(width: 40, height: 40)
                                             .foregroundColor(.gray)
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle.fill").resizable()
                                     .frame(width: 40, height: 40)
                                     .foregroundColor(.gray)
                            }
                            
                            if let username = info.user?.name{
                                Text(username)
                                    .font(.caption)
                            }else{
                                Text("no name")
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            
        }.onAppear{
            viewModel.fetchUsersStatus()
        }
        
    }
}

#Preview {
    ShowUserStatusView()
}
