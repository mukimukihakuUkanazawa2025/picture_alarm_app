import SwiftUI
import Kingfisher

struct PostRowView: View {
    let post: PostInfo
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 左カラム：プロフィール
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    if let profileUrl = post.user?.profileImageUrl, let url = URL(string: profileUrl) {
                        KFImage(url)
                            .resizable()
                            .cancelOnDisappear(true)
                            .cacheOriginalImage()
                            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 40, height: 40)))
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    }
                    Text(post.user?.name ?? "名無しさん")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                if let time = post.postTime {
                    Text(timeString(from: time))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                if !post.comments.isEmpty {
                    Text(post.comments.joined(separator: "\n"))
                        .font(.body)
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            // 右カラム：投稿画像（サムネイル優先）
            ZStack {
                // 元画像を下に置く（フォールバック）
                if let fullUrlStr = post.imageUrl, let fullUrl = URL(string: fullUrlStr) {
                    KFImage(fullUrl)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                }
                
                // サムネイルを上に重ねる
                if let thumbUrlStr = post.thumbnailUrl, let thumbUrl = URL(string: thumbUrlStr) {
                    KFImage(thumbUrl)
                        .resizable()
                        .cancelOnDisappear(true)
                        .cacheOriginalImage()
                        .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 150, height: 150)))
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.black)
        .overlay(Divider().background(Color.gray), alignment: .bottom)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
