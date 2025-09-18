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
            if isWakeupnow {
                return CommentWheel.departureComments
            } else {
                return CommentWheel.wakeUpComments
            }
        }
        
        
        let defaults = UserDefaults.standard
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text(alarmService.isWakeupnow ? "準備間に合ったね！" : "確認してね！")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    if let image = CapturedImage {
                        Image(uiImage: image)
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
                    if alarmService.isWakeupnow {
                        // 出発時のボタン
                        Button(action: {
                            handlePost(isDeparture: true)
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
                            handlePost(isDeparture: false)
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
    private func handlePost(isDeparture: Bool) {
        guard var image = CapturedImage else {
            // 画像がない場合は画面を閉じるだけ
            if !isDeparture {
                alarmService.isWakeupnow = true
                alarmService.stopAlarm()
            }
            dismiss()
            return
        }
        
        // 画像をリサイズ
        let targetSize = CGSize(width: 1080, height: 1080)
        image = image.preparingThumbnail(of: targetSize) ?? image
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("画像データの変換に失敗しました")
            return
        }
        
        // 投稿処理をバックグラウンドタスクで実行
        Task.detached(priority: .background) {
            do {
                try await postService.uploadPost(imageData: imageData, comment: selectedComment, completion: { _ in
                    print("投稿完了！ コメント: \(selectedComment)")
                })
            } catch {
                print("バックグラウンドでの投稿に失敗しました: \(error.localizedDescription)")
            }
        }
        
        // UI側の処理を先に進める
        if isDeparture {
            // 出発時：アラーム関連の状態をリセットして画面を閉じる
            alarmService.isAlarmOn = false
            alarmService.isPrepareDone = true
            alarmService.stopAlarm()
        } else {
            // 起床時：次のステップ（出発カウントダウン）に進む
            alarmService.isWakeupnow = true
            alarmService.stopAlarm()
        }
        dismiss()
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

