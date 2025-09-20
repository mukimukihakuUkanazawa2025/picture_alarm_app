//
//  ContentView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/12.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct ContentView: View {
    
    @StateObject var alarmService = AlarmService.shared
    
    @State var isShowAlermStartView: Bool = false
    @State var isShowSecondView:Bool = false
    
    @State var isShowPopover: Bool = true
    
    @State var wakeuptime = ""
    @State var leaveTime = ""
    
    var body: some View {
        
        ZStack{
            TabView {
                
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
                
                //            AlarmStartView()
                //                .tabItem {
                //                    Image(systemName: "camera.circle.fill")
                //                    Text("プロフィール")
                //                }
            }
            .tint(Color(hex: "FF8300"))
            .navigationBarBackButtonHidden(true)
            
            // カメラ起動ボタン
            if !alarmService.isWakeup || !alarmService.isLeave {
                VStack{
                    Spacer()
                    Button{
                        isShowAlermStartView = true
                    }label:{
                        Image(systemName: "camera")
                            .resizable()
                            .foregroundStyle(.white)
                            .scaledToFit()
                            .scaleEffect(0.5)
                            .frame(width: 50, height: 50)
                            .background(.orange)
                            .clipShape(Circle())
                        
                        
                        
                    }
                    .opacity(alarmService.isAlarmOn ? 1 : 0)
                    .padding(.bottom, 75) // 下から30ポイント上に配置
                    
                    
                    
//                    .popover(isPresented: .constant(true)) {
//                        popoverView
//                            .presentationCompactAdaptation(PresentationAdaptation.popover)
//                            .offset(y: -75)
//                    }
                }
            }
            
        }
        .fullScreenCover(isPresented: $isShowAlermStartView){
            AlarmStartView(isShowingSecondModal: $isShowAlermStartView,
                           onDismissAll: {
                // このクロージャが呼ばれたら、全ての状態をfalseにする
                isShowAlermStartView = false
                isShowSecondView = false
            }
            )
        }
        .onAppear{
//            if alarmService.isWakeupnow && alarmService.currentAlarm != nil{
//                
//                
//                
//            } else if !alarmService.isWakeupnow && alarmService.currentAlarm != nil{
//                
//                
//            }else{
//                
//                isShowPopover = false
//            }
        }
        
        
    }
    
    var popoverView: some View {
        
        
        
        VStack{
//            if alarmService.isWakeupnow && alarmService.currentAlarm != nil{
//                Text("出発時刻")
//                Text(wakeuptime)
//                
//                
//            } else if !alarmService.isWakeupnow && alarmService.currentAlarm != nil{
//                
//                Text("起床時間")
//                Text(leaveTime)
//                
//            }else{
//                Text("アラームが設定されていないよ！")
//                //                isShowAlermStartView = false
//            }r
        }.onAppear{
            settime()
        }
        .padding()
        
        
    }
    
    private func settime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH時mm分"
        
        if let current = alarmService.currentAlarm {
            wakeuptime = dateFormatter.string(from: current.wakeUpTime)
            leaveTime  = dateFormatter.string(from: current.leaveTime)
        } else {
            wakeuptime = "--:--"
            leaveTime  = "--:--"
        }
    }
    
    
}

#Preview {
    ContentView()
    
}
