//
//  TutorialView.swift
//  picture_alarm_app
//
//  Created by 酒井みな実 on 2025/09/19.
//

import SwiftUI

//struct TutorialView: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var currentPage = 0
//    
//    var body: some View {
//        VStack {
//            TabView(selection: $currentPage) {
struct TutorialView: View {
    var onFinish: () -> Void
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
                // --- 1枚目 ---
                VStack(spacing: 20) {
                    Image(systemName: "bed.double.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.orange)
                    Text("顔質アラームへようこそ！")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text("このアプリは寝坊を防ぎ、\n確実に起きて出発できるようにサポートします。")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                .tag(0)
                
                // --- 2枚目 ---
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.orange)
                    Text("寝起きの顔を撮影！")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    Text("起床時刻になるとアラームが鳴り、\n寝起きの写真を撮らないと止まりません。")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                .tag(1)
                
                // --- 3枚目 ---
                VStack(spacing: 20) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.orange)
                    Text("出発を証明！")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    Text("出発時刻までに写真を投稿しないと、\n寝起き写真が公開されてしまいます。")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                .tag(2)
                
                // --- 4枚目 (最後) ---
            VStack(spacing: 20) {
                            Image(systemName: "sparkles")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.orange)
                            Text("準備完了！")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            Text("さっそく顔質アラームを体験してみましょう！")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                            
                            Button("はじめる") {
                                onFinish()  // ← ここで RootView の状態を更新
                            }
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                        }
                        .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .background(Color.black.ignoresSafeArea())
                }
            }
//            VStack(spacing: 20) {
//                            Image(systemName: "sparkles")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 120, height: 120)
//                                .foregroundColor(.orange)
//                            Text("準備完了！")
//                                .font(.title)
//                                .bold()
//                                .foregroundColor(.white)
//                            Text("さっそく顔質アラームを体験してみましょう！")
//                                .multilineTextAlignment(.center)
//                                .foregroundColor(.gray)
//
//                            Button("はじめる") {
//                                onFinish()
//                            }
//                            .bold()
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.orange)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                            .padding(.horizontal, 40)
//                            .padding(.top, 20)
//                        }
//                        .tag(3)
//                    }
//                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//                    .background(Color.black.ignoresSafeArea())
//                }
//            }
//            
//            
//                VStack(spacing: 20) {
//                    Image(systemName: "sparkles")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 120, height: 120)
//                        .foregroundColor(.orange)
//                    Text("準備完了！")
//                        .font(.title)
//                        .bold()
//                        .foregroundColor(.white)
//                    Text("さっそく顔質アラームを体験してみましょう！")
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(.gray)
//                    
//                    Button(action: { dismiss() }) {
//                        Text("はじめる")
//                            .bold()
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.orange)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                            .padding(.horizontal, 40)
//                            .padding(.top, 20)
//                    }
//                }
//                .tag(3)
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//            .background(Color.black.ignoresSafeArea())
//        }
//    }
//}
//
//#Preview {
//    TutorialView()
//}
