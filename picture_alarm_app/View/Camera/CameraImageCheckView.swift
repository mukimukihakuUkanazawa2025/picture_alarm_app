//
//  CameraImageCheckView.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/16.
//

import SwiftUI

struct CameraImageCheckView: View {
    
    @StateObject var cameraviewmodel = CameraViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    //撮影された写真
    @Binding var CapturedImage:UIImage?
    
    var postService = PostService()
    
    
    var body: some View {
        VStack{
            Image(uiImage: CapturedImage!)
                .resizable()
                .scaledToFit()
            
            Button("けす"){
                dismiss()
            }
            
            
            if cameraviewmodel.isWakeupnow  {
                Button("送信") {
                    Task {
                        do{
                            // Safely unwrap the image and convert it to Data
                            guard let image = CapturedImage,
                                  let imageData = image.jpegData(compressionQuality: 0.8) else {
                                print("Error: Image data is invalid.")
                                dismiss()
                                return
                            }
    //
                            // Call the upload service
                            postService.uploadPost(userName: "test", imageData: imageData) { result in
    
                                dismiss()
    
                                return
                            }
                        }
                       
                    }
                }
                .padding()
            } else {
                Button("確認") {
                    cameraviewmodel.isWakeupnow = true
                    
                    dismiss()
                }
                .padding()
            }
            
            
        }
        
        
    }
}

//#Preview {
//    CameraImageCheckView()
//}
