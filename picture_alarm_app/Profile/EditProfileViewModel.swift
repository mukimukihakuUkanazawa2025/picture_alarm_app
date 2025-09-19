//
//  EditProfileViewModel.swift
//  picture_alarm_app
//
//  Created by Keiju Hiramoto on 2025/09/17.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

@MainActor
class EditProfileViewModel: ObservableObject {
    
    let defaults = UserDefaults.standard
    
    @Published var user: User?
    
    // 編集可能なフィールド
    @Published var displayName = ""
    @Published var bio = ""
    
    // 画像選択のためのプロパティ
    @Published var selectedPhoto: PhotosPickerItem? {
        didSet { Task { await loadImage(from: selectedPhoto) } }
    }
    @Published var profileImage: UIImage?
    @Published var hitozichiImage: UIImage?
    
    @Published var isLoading = false
    @Published var didSaveProfile = false
    
    @Published var isShowingDeleteAlert = false
    @Published var errorMessage: String?
    
    @Published var selectHitozichiPhoto: PhotosPickerItem? {
        didSet { Task { await loadHitozichiImage(from: selectHitozichiPhoto) } }
    }
    private let userService = UserService.shared
    private let storageService = StorageService.shared
    private let authService = AuthService.shared
    
    
    init() {
        Task {
            await fetchCurrentUser()
        }
    }
    
    /// 現在のユーザー情報を取得して、編集フィールドにセットする
    func fetchCurrentUser() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        self.user = try? await userService.fetchUser(withId: currentUserId)
        
        self.displayName = self.user?.name ?? ""
        self.bio = self.user?.bio ?? ""
        
        if let imageData = defaults.data(forKey: "hitozichiImage"){
            self.hitozichiImage = UIImage(data: imageData)
        }
    }
    
    /// 選択されたフォトライブラリのアイテムをUIImageに変換する
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        self.profileImage = UIImage(data: data)
    }
    
    /// 選択されたフォトライブラリのアイテムをUIImageに変換する
    private func loadHitozichiImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        self.hitozichiImage = UIImage(data: data)
    }
    
    /// 変更を保存する
    func saveProfile() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let originalUserName = self.user?.name else { return }
        isLoading = true
        var newImageUrl: String?
        
        do {
            // 1. もし新しい画像が選択されていたら、Storageにアップロード
            if let image = self.profileImage {
                let url = try await storageService.uploadProfileImage(image, for: currentUserId)
                newImageUrl = url.absoluteString
            }
            
            // 2. Firestoreのユーザー情報を更新
            try await userService.updateUserProfile(
                userId: currentUserId,
                name: displayName,
                bio: bio,
                newProfileImageUrl: newImageUrl
            )
            
            //人質写真をUserdefaultsに保存
            if let hitozichiimage = self.hitozichiImage {
                let data = hitozichiimage.jpegData(compressionQuality: 0.8) as NSData?
                if let imageData = data {
                    //                           saveArray.append(imageData)
                    
                    defaults.set(imageData, forKey: "hitozichiImage")
                    defaults.synchronize()
                }
            }
            
            self.didSaveProfile = true
            
        }catch {
            // どの種類のエラーが発生したかを判別する
            if let storageError = error as? StorageError, storageError == .imageDataConversionFailed {
                // もし画像変換エラーだったら、ユーザーに分かりやすいメッセージを表示
                print("画像の変換に失敗しました。")
                // self.message = "画像のフォーマットに問題がある可能性があります。別の写真をお試しください。"
            } else {
                // それ以外のエラー
                print("Error saving profile: \(error.localizedDescription)")
            }
        }
        isLoading = false
    }
    /// ログアウト処理
    func logout() {
        authService.signOut()
    }
    
    /// アカウント削除処理
    func deleteAccount() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        do {
            // 1. Storageのプロフィール画像を削除
            try await storageService.deleteProfileImage(for: currentUserId)
            
            // 2. Firestoreのユーザー情報を削除
            try await userService.deleteUser(userId: currentUserId)
            
            // 3. Authからアカウントを削除
            try await authService.deleteAccount()
            
            isLoading = false
            
        } catch {
            isLoading = false
            
            // Firebase Authのエラーかどうかをチェック
            if let authError = error as NSError?, authError.domain == AuthErrorDomain {
                if authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                    // 再認証が必要な場合のエラーメッセージ
                    self.errorMessage = "セキュリティのため、一度ログアウトしてから再度ログインし、アカウント削除を行ってください。"
                } else {
                    // その他のAuthエラー
                    self.errorMessage = "アカウントの削除に失敗しました: \(error.localizedDescription)"
                }
            } else {
                // Auth以外のエラー（StorageやFirestoreなど）
                self.errorMessage = "アカウントデータの削除中にエラーが発生しました: \(error.localizedDescription)"
            }
        }
    }
}
