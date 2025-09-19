//
//  CameraViewWrapper.swift
//  picture_alarm_app
//
//  Created by 酒井みな実 on 2025/09/17.
//

import SwiftUI



struct CameraViewWrapper: View {
    @StateObject private var alarmService: AlarmService = .shared
    @StateObject private var cameraviewmodel = CameraViewModel()
    @State private var capturedImage: UIImage? = nil
    @State private var isShowingCheckView = false
    @State private var wakeuptime:String = ""
    @Binding var isShowingSecondModal: Bool
    
    let onDismissAll: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // --- 起床時刻ラベル（仮の固定表示） ---
                VStack(spacing: 8) {
                    Text("起床時刻")
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                        .font(.headline)
                        .padding(.top, 60)

                    Text(wakeuptime) // TODO: Firestoreやアラーム設定から取得する
                        .foregroundColor(.white)
                        .font(.system(size: 45))
                        .font(.system(size: 28, weight: .bold))
                        .padding(.bottom, 20)
                }

                // --- カメラ映像 ---
                CameraView(cameraviewmodel: cameraviewmodel)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                cameraviewmodel.isFaceOn ? Color(hex: "FF8300") : .white,
                                lineWidth: 4
                            )
                    )
                    .frame(width: 380, height: 380)

                Spacer()
                
                Text("写真を撮ってアラームを止めよう！")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .font(.system(size: 28, weight: .bold))
                    .padding(.bottom, 20)
                
                Button(action: {
                    if let view = cameraviewmodel.arScnView {
                        let snapshot = view.snapshot()
                        self.capturedImage = snapshot
                        self.isShowingCheckView = true
                        cameraviewmodel.isCameraOn = false
                        print("sdsdf")
                    }
                }) {
                    if cameraviewmodel.isFaceOn {
                        // --- 顔があるとき（有効） ---
                        Text("撮影")
                            .fontWeight(.semibold)
                            .foregroundColor(.white) // 白文字
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange) // オレンジ背景
                            .cornerRadius(10)
                    } else {
                        // --- 顔がないとき（無効） ---
                        Text("撮影")
                            .fontWeight(.semibold)
                            .foregroundColor(.black) // 黒文字
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white) // 白背景
                            .cornerRadius(10)
                    }
                }
                .disabled(!cameraviewmodel.isFaceOn) // 顔がないときは押せない
                .padding(.horizontal, 40)
                .padding(.bottom, 80)
            }
        }
        // --- 撮影後の確認画面へ遷移 ---
        .fullScreenCover(isPresented: $isShowingCheckView) {
            if let capturedImage = capturedImage {
                CameraImageCheckView(
                    cameraviewmodel: cameraviewmodel,
                    CapturedImage: $capturedImage,
                    isWakeupnow: alarmService.currentAlarm!.isWakeup, onDismissAll: onDismissAll
                    )
            }
        }
        .onAppear{
            settime()
            cameraviewmodel.isCameraOn = true
        }
    }
    
    private func settime() {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH時mm分"
        
        wakeuptime = dateFormatter.string(from: alarmService.currentAlarm!.wakeUpTime )
    }
    
}

//#Preview {
//    CameraViewWrapper()
//}
