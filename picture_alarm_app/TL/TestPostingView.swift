//
//  TestPostingView.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/15.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                print("画像取得成功: \(image)")
            } else {
                print("画像が nil です")
            }
            picker.dismiss(animated: true)
        }
    }
}

struct TestPostingView: View {
    
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var isUploading = false
    @State private var message = ""
    
    private let postService = PostService()
    private let userName = "Aoi" // ← 実際は Firestore/Auth から取得
    
    var body: some View {
        VStack(spacing: 20) {
            if let capturedImage = capturedImage {
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }
            
            Button("カメラを起動") {
                showCamera = true
            }
            .buttonStyle(.borderedProminent)
            
            if let image = capturedImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                Button("投稿する") {
                    print("投稿開始: 画像データサイズ = \(imageData.count) バイト")
                    isUploading = true
                    postService.uploadPost(userName: userName, imageData: imageData) { error in
                        isUploading = false
                        if let error = error {
                            print("投稿エラー詳細: \(error)")
                            message = "投稿失敗: \(error.localizedDescription)"
                        } else {
                            message = "投稿完了！"
                            capturedImage = nil
                        }
                    }
                }
                .buttonStyle(.bordered)
            }
            
            if isUploading {
                ProgressView("アップロード中…")
            }
            
            Text(message)
                .foregroundColor(.blue)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $capturedImage)
        }
    }
}

#Preview {
    TestPostingView()
}
