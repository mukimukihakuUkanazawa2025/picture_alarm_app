//
//  CameraImageCheckView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/16.
//

import SwiftUI

struct CameraImageCheckView: View {
    
    @ObservedObject  var cameraviewmodel : CameraViewModel
    
    @StateObject private var alarmService = AlarmService.shared
    
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var CapturedImage: UIImage?
    var postService = PostService()
    
    @State private var goToCountdown = false   // ← 遷移フラグ
    
    let defaults = UserDefaults.standard
    
    
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
//                            guard let image = CapturedImage else {
//                                // 画像がない場合は何もしないで画面を閉じる
//                                defaults.set(nil, forKey: "wakuupImage")
//                                defaults.synchronize()
//                                alarmService.isWakeupnow = true
//                                alarmService.stopAlarm()
//                                dismiss()
//                                return
//                            }
                            
                            if var image = CapturedImage{
                                let targetSize = CGSize(width: 2024, height: 2024) // 目標サイズ（例: 1080px四方）
                                image = image.preparingThumbnail(of: targetSize) ?? image
                                
                                if let imageData = image.jpegData(compressionQuality: 0.8) {
                                    defaults.set(nil, forKey: "wakuupImage")
                                    defaults.synchronize()
                                    alarmService.isAlarmOn = false
                                    alarmService.isPrepareDone = true
                                    alarmService.stopAlarm()
                                    dismiss()
                                    
                                    Task.detached(priority: .background) {
                                            do {
                                                // 4. 裏でアップロード処理を実行
                                                try await postService.uploadPost(imageData: imageData, completion: { _ in
                                                     print("a")
                                                })
                                                
                                                // 5. (任意) アップロード成功後、裏で何か処理が必要な場合はここで行う
                                                // 例: アプリ全体の投稿リストを更新する通知を送るなど
                                                await MainActor.run {
                                                    // alarmService.postsNeedRefresh = true
                                                }
                                                
                                            } catch {
                                                // エラーが発生してもUIは既にないので、コンソールにログを出すなどの対応
                                                print("❌ バックグラウンドでの投稿に失敗しました: \(error.localizedDescription)")
                                            }
                                        }
                                }
                            }else{
                                defaults.set(nil, forKey: "wakuupImage")
                                defaults.synchronize()
                                alarmService.isAlarmOn = false
                                alarmService.isPrepareDone = false
                                alarmService.stopAlarm()
                                dismiss()
                        
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
                            if var image = CapturedImage{
                                let targetSize = CGSize(width: 1080, height: 1080) // 目標サイズ（例: 1080px四方）
                                image = image.preparingThumbnail(of: targetSize) ?? image

                                
                                if let imageData = image.jpegData(compressionQuality: 0.8) {
                                    
                                    
                                    defaults.set(imageData, forKey: "wakuupImage")
                                    defaults.synchronize()
                                    alarmService.isWakeupnow = true
                                    alarmService.stopAlarm()
                                    dismiss()
                                    
                                }
                            }
                            
//                            guard let image = CapturedImage,
//                                  let imageData = image.jpegData(compressionQuality: 0.3) else {
//                                // 画像がない場合は何もしないで画面を閉じる
//                                defaults.set(nil, forKey: "wakuupImage")
//                                defaults.synchronize()
//                                alarmService.isWakeupnow = true
//                                alarmService.stopAlarm()
//                                dismiss()
//                                return
//                            }
//                            
//                            defaults.set(imageData, forKey: "wakuupImage")
//                            defaults.synchronize()
//                            alarmService.isWakeupnow = true
//                            alarmService.stopAlarm()
//                            dismiss()
//                            
//                            Task.detached(priority: .background) {
//                                    do {
//                                        // 4. 裏でアップロード処理を実行
//                                        try await postService.uploadPost(imageData: imageData, completion: { _ in
//                                             print("a")
//                                        })
//                                        
//                                        // 5. (任意) アップロード成功後、裏で何か処理が必要な場合はここで行う
//                                        // 例: アプリ全体の投稿リストを更新する通知を送るなど
//                                        await MainActor.run {
//                                            // alarmService.postsNeedRefresh = true
//                                        }
//                                        
//                                    } catch {
//                                        // エラーが発生してもUIは既にないので、コンソールにログを出すなどの対応
//                                        print("❌ バックグラウンドでの投稿に失敗しました: \(error.localizedDescription)")
//                                    }
//                                }

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
                }.onAppear{
                    print("テキスト")
                    cameraviewmodel.isCameraOn = false
                }

//                 🔗 遷移リンク（裏に隠す）
//                NavigationLink(
//                    destination: DepartureCountdownView(
//                        departureTime: alarmService.currentAlarm?.leaveTime ?? Date(), // ← leaveTimeを参照
//                        wakeUpImage: CapturedImage
//                    ),
//                    isActive: $goToCountdown
//                ) {
//                    EmptyView()
//                }
            }
           
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        cameraviewmodel.isCameraOn = true
//                        cameraviewmodel.isFaceOn = false
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
