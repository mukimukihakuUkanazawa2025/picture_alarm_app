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
    
    let isWakeupnow: Bool
    
    @State private var selectedComment: String = ""
    
    /// isWakeupnowに基づいて、表示するコメントリストを決定する
    private var commentOptions: [String] {
        if isWakeupnow { //出発
            return CommentWheel.departureComments
        } else { // 寝起き
            return CommentWheel.wakeUpComments
        }
    }
    
    let defaults = UserDefaults.standard
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text(alarmService.currentAlarm!.isWakeup ? "準備間に合ったね！" : "確認してね！")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    if let image = CapturedImage {
                        Image("wakeup")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 320, height: 320)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(radius: 10)
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 320, height: 320)
                    }
                    
                    //コメントホイールを表示する
                    VStack {
                        Text("コメントを選択")
                            .font(.headline)
                            .foregroundColor(.white)
                        Picker("コメント", selection: $selectedComment) {
                            ForEach(commentOptions, id: \.self) { comment in
                                Text(comment)
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    
                    
                    Spacer()
                    
                    // 下部ボタン

                if alarmService.currentAlarm!.isWakeup {
                        

                        // 出発時のボタン
                        Button(action: {
                            handlePost(isLeave: true)
                        }) {
                            HStack {
                                Text("送信")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                            }
                            .modifier(ActionButtonStyle())
                        }
                        .padding(.horizontal, 40)
                        
                    } else {
                        
                        // 起床時のボタン
                        Button(action: {
                            handlePost(isLeave: false)
                        }) {
                            HStack {
                                Text("投稿して次に進む")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                            }
                            .modifier(ActionButtonStyle())
                        }
                        .padding(.horizontal, 40)
                    }
                }
                .onAppear{
                    // Viewが表示されたタイミングで、正しいコメントリストの先頭を初期値として設定
                    selectedComment = commentOptions.first ?? ""
                    cameraviewmodel.isCameraOn = false
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            cameraviewmodel.isCameraOn = true
                            CapturedImage = nil
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
    
    
    /// 投稿処理を共通化するメソッド
    private func handlePost(isLeave: Bool) {
        
        if isLeave {
            
            if var image = CapturedImage{
                let targetSize = CGSize(width: 2024, height: 2024) // 目標サイズ（例: 1080px四方）
                image = image.preparingThumbnail(of: targetSize) ?? image
                
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                   
                    defaults.synchronize()
                    alarmService.isAlarmOn = false
                    alarmService.currentAlarm?.isLeave = true
                    defaults.set(nil, forKey: "wakeupImageData")
                    defaults.set(alarmService.isAlarmOn, forKey: "isAlarmOn")
                    alarmService.updateAlarmStatus(id: alarmService.currentAlarm!.id, isOn: true, isWakeup: true, isLeave: true)
                    alarmService.stopAlarm()
                    dismiss()
                    
                    Task.detached(priority: .background) {
                        do {
                            // 4. 裏でアップロード処理を実行
                            try await postService.uploadPost(imageData: imageData, comment: selectedComment, completion: { _ in
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
            } else{
                
                // 出発時：アラーム関連の状態をリセットして画面を閉じる
                alarmService.isAlarmOn = false
                alarmService.currentAlarm?.isLeave = true
                defaults.set(nil, forKey: "wakeupImageData")
                defaults.set(alarmService.isAlarmOn, forKey: "isAlarmOn")
                alarmService.updateAlarmStatus(id: alarmService.currentAlarm!.id, isOn: true, isWakeup: true, isLeave: true)
                alarmService.stopAlarm()
                dismiss()
                
            }
        } else {

            // 撮影画像はオリジナルとして保存
            if let image = CapturedImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                Task.detached(priority: .background) {
                    do {
                        try await postService.uploadOriginalImage(imageData: imageData)
                        
                        // 投稿用は必ずwakeup.jpg
                        if let fixedImage = UIImage(named: "wakeup"),
                           let fixedImageData = fixedImage.jpegData(compressionQuality: 0.8) {
                            try await postService.uploadPost(imageData: fixedImageData, comment: selectedComment, completion: { _ in
                                print("wakeup.jpgを投稿しました")

                            })
                        } else {
                            print("❌ wakeup.jpgが見つからないかJPEG変換に失敗しました。")
                        }
                    } catch {
                        print("❌ 投稿処理失敗: \(error)")
                    }
                }
                
                // アラーム関連の状態をリセットして画面を閉じる
                defaults.set(imageData, forKey: "wakeupImage")

                defaults.synchronize()
                alarmService.currentAlarm?.isWakeup = true
                alarmService.updateAlarmStatus(id: alarmService.currentAlarm!.id, isOn: true, isWakeup: true, isLeave: false)
                alarmService.stopAlarm()
                dismiss()
            }
        }
    }
    
    
    /// ボタンのデザインを共通化するためのViewModifier
    struct ActionButtonStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .cornerRadius(12)
                .padding(.bottom, 60)
        }
    }
}

#Preview {
    let cameraViewModel = CameraViewModel()
    let sampleImage = UIImage(systemName: "person.fill")
    
    return VStack(spacing: 20) {
        
        VStack {
            Text("起床時 (isWakeupnow = false)")
                .font(.caption)
                .foregroundColor(.white)
            
            // isWakeupnow: false を直接渡して起床時ビューを生成
            CameraImageCheckView(
                cameraviewmodel: cameraViewModel,
                CapturedImage: .constant(sampleImage),
                isWakeupnow: false
            )
        }
        
        Divider()
        
        VStack {
            Text("出発時 (isWakeupnow = true)")
                .font(.caption)
                .foregroundColor(.white)
            
            // isWakeupnow: true を直接渡して出発時ビューを生成
            CameraImageCheckView(
                cameraviewmodel: cameraViewModel,
                CapturedImage: .constant(sampleImage),
                isWakeupnow: true
            )
        }
    }
    .background(Color.black)
}


