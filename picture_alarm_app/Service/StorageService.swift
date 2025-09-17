//
//  StorageService.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/17.
//

import Foundation
import FirebaseStorage
import UIKit

enum StorageError: Error {
    case imageDataConversionFailed
}

class StorageService {
    static let shared = StorageService()
    private init() {}
    
    private let storage = Storage.storage()
    
    /// プロフィール画像をアップロードし、ダウンロードURLを返す
    func uploadProfileImage(_ image: UIImage, for userId: String) async throws -> URL {
        let storageRef = storage.reference().child("profile_images/\(userId).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            // ▼▼▼ 2. 独自のエラーを投げるように修正 ▼▼▼
            throw StorageError.imageDataConversionFailed
        }
        
        _ = try await storageRef.putDataAsync(imageData)
        
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL
    }
}
