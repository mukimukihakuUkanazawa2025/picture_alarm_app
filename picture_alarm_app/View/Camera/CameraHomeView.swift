//
//  CameraHomeView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/16.
//

import SwiftUI

struct CameraHomeView: View {
    @StateObject private var alarmService: AlarmService = .shared
    
    @StateObject var cameraviewmodel = CameraViewModel()
    
    @Environment(\.displayScale) private var displayScale
    
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
            
            Button("保存"){
                if let viewToRender = cameraviewmodel.arScnView{
                    let image = viewToRender.snapshot()
                    
                    // 写真アルバムに画像を保存
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    print("✅ 写真を保存しました")
                } else {
                    print("❌ 写真の保存に失敗しました")
                }
            }
        }
    }
    
    
    
}


#Preview {
    CameraHomeView()
}
