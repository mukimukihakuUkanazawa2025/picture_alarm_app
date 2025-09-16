//
//  ContentView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/12.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @StateObject var cameraviewmodel = CameraViewModel()
    
    
    var body: some View {
        
        TabView {
            CameraView(cameraviewmodel: cameraviewmodel)
                .tabItem{
                    Text("実験")
                }
            TLView()
                .tabItem {

                    Image(systemName: "house")
                    Text("タイムライン")

                }
            AlermView()
                .tabItem {
                    Image(systemName: "deskclock")
                    Text("アラーム")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("プロフィール")
                }
            
            TestPostingView()
                .tabItem {
                    Image(systemName: "camera.circle.fill")
                    Text("プロフィール")
                }
        }.onChange(of: cameraviewmodel.isCameraOn){
            print("フェイストラッキング設定変更")
        }
    
//        .tint(Color(hex: "FF8300"))
    }
    
}

#Preview {
    ContentView()
    
}
