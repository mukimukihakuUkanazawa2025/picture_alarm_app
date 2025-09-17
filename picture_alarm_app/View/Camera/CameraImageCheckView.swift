//
//  CameraImageCheckView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/16.
//

import SwiftUI

struct CameraImageCheckView: View {
    
    @StateObject private var alarmService = AlarmService.shared
    @Environment(\.dismiss) private var dismiss
    
    @Binding var CapturedImage: UIImage?
    var postService = PostService()
    
    @State private var goToCountdown = false   // ← 遷移フラグ
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 44) {
                    // 上部メッセージ
                    Text(alarmService.isWakeupnow ? "準備間に合ったね！" : "確認してね！")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    // 撮影画像（丸型）
                    if let image = CapturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 380, height: 380)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(radius: 10)
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 380, height: 380)
                    }
                    
                    Spacer()
                    
                    // 下部ボタン
                    if alarmService.isWakeupnow {
                        Button(action: {
                            Task {
                                if let image = CapturedImage,
                                   let imageData = image.jpegData(compressionQuality: 0.8) {
                                    postService.uploadPost( imageData: imageData) { _ in
                                        alarmService.isPrepareDone = true
                                        alarmService.stopAlarm()
                                        //                                        dismiss()
                                        goToCountdown = true  // ← 遷移トリガー
                                        
                                        dismiss()
                                    }
                                } else {
                                    alarmService.isPrepareDone = true
                                    alarmService.stopAlarm()
                                    dismiss()
                                }
                            }
                        }) {
                            HStack {
                                Text("送信")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(12)
                            .padding(.bottom, 80)
                        }
                        .padding(.horizontal, 40)
                    } else {
                        Button(action: {
                            alarmService.isWakeupnow = true
                            alarmService.stopAlarm()
                            dismiss()
                        }) {
                            HStack {
                                Text("確認")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(12)
                            .padding(.bottom, 80)
                        }
                        .padding(.horizontal, 40)
                    }
                }
                // 🔗 遷移リンク（裏に隠す）
                NavigationLink(
                    destination: DepartureCountdownView(
                        departureTime: alarmService.currentAlarm?.leaveTime ?? Date(), // ← leaveTimeを参照
                        wakeUpImage: CapturedImage
                    ),
                    isActive: $goToCountdown
                ) {
                    EmptyView()
                }
            }
           
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        CapturedImage = nil
                        dismiss()
                        // ← 戻るボタンなのでここはdismiss()でOK
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                // 左上に戻る「＜」ボタン
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        CapturedImage = nil
//                        dismiss() }) {
//                        Image(systemName: "chevron.left")
//                            .foregroundColor(.white)
//                    }
//                }
//            }
//        }
//    }
//}
