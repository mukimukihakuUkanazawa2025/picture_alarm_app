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
    /// プロフィール画像を削除する
        func deleteProfileImage(for userId: String) async throws {
            let storageRef = storage.reference().child("profile_images/\(userId).jpg")
            
            do {
                try await storageRef.delete()
            } catch let error as NSError {
                // `objectNotFound` エラーの場合は、画像が元々存在しなかっただけなので、エラーを無視する
                if error.domain == StorageErrorDomain, error.code == StorageErrorCode.objectNotFound.rawValue {
                    print("プロフィール画像が見つからなかったため、削除をスキップします。")
                    // ここでエラーを投げずに正常終了とする
                } else {
                    // その他の場合は、予期せぬエラーとして再度エラーを投げる
                    throw error
                }
            }
        }
}
