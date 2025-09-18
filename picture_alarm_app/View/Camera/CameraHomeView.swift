//
//  CameraHomeView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/16.
//

import SwiftUI
import UIKit

struct CameraHomeView: View {
    @StateObject private var alarmService: AlarmService = .shared
    
    @StateObject var cameraviewmodel = CameraViewModel()
    
    @Environment(\.displayScale) private var displayScale
    
    @State var isShowImageCheck = false
    
    @State var capturedImage: UIImage?
    
    var body: some View {
        
        let cameraView:CameraView = CameraView(cameraviewmodel: cameraviewmodel)
        
        VStack{
            
            cameraView
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(Circle())
                .onChange(of: cameraviewmodel.isCameraOn){
                    print("フェイストラッキング設定変更")
                }
                .overlay{
                    Circle()
                        .stroke(lineWidth: 5)
                        .foregroundStyle(.green)
                        .opacity(cameraviewmodel.isCameraOn ? 1 : 0)
                }
            
            Button("撮影"){
                if let viewToRender = cameraviewmodel.arScnView{
                    let image = viewToRender.snapshot()
                    
                    capturedImage = image
                    
                    isShowImageCheck = true
                    // 写真アルバムに画像を保存
//                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                    print("✅ 写真を保存しました")
                } else {
//                    print("❌ 写真の保存に失敗しました")
                }
            }.disabled(!cameraviewmodel.isCameraOn)
        }
        .fullScreenCover(isPresented: $isShowImageCheck){
            CameraImageCheckView(cameraviewmodel: cameraviewmodel, CapturedImage: $capturedImage, isWakeupnow: false)
        }
    }
    
    
    
}


#Preview {
    CameraHomeView()
}



extension UIImage {
    /// 指定されたサイズに収まるように画像をリサイズする
    func preparingThumbnail(of size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
