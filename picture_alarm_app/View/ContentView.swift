//
//  ContentView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/12.
//

import SwiftUI
import SwiftData

struct ContentView: View {
   

    var body: some View {

        TabView {
            TLView()
                .tabItem {
                        Image(systemName: "house")
                        Text("タイムラインa")
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
        }

    }

}

#Preview {
    ContentView()

}
