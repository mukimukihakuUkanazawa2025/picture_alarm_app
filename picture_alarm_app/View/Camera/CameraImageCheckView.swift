//
//  CameraImageCheckView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/16.
//

import SwiftUI

struct CameraImageCheckView: View {
    
    @ObservedObject var cameraviewmodel:CameraViewModel
    
    //撮影された写真
    @Binding var CaptureedImage:UIImage?
    
    
    var body: some View {
        Image(uiImage: CaptureedImage!)
            .resizable()
            .scaledToFit()
    }
}

//#Preview {
//    CameraImageCheckView()
//}
