//
//  SamplePost.swift
//  picture_alarm_app
//
//  Created by 酒井みな実 on 2025/09/16.
//

import Foundation

struct SamplePosts {
    static let posts: [PostInfo] = [
        PostInfo(
            id: UUID().uuidString,
            userName: "自分",
            postTime: Date(),
            imageUrl: "https://placehold.jp/300x300.png",
            goodCount: 0,
            comments: ["自分の投稿だよ！"]
        ),
        PostInfo(
            id: UUID().uuidString,
            userName: "saki.yukke",
            postTime: Calendar.current.date(byAdding: .minute, value: -10, to: Date()),
            imageUrl: "https://placehold.jp/200x200.png",
            goodCount: 3,
            comments: ["起きられた〜！"]
        ),
        PostInfo(
            id: UUID().uuidString,
            userName: "minami.chami",
            postTime: Calendar.current.date(byAdding: .minute, value: -30, to: Date()),
            imageUrl: "https://placehold.jp/200x200.png",
            goodCount: 5,
            comments: ["二度寝した"]
        ),
        PostInfo(
            id: UUID().uuidString,
            userName: "keiju.hirakke",
            postTime: Calendar.current.date(byAdding: .minute, value: -10, to: Date()),
            imageUrl: "https://placehold.jp/200x200.png",
            goodCount: 3,
            comments: ["若いから余裕"]
        ),
        PostInfo(
            id: UUID().uuidString,
            userName: "aoi.aosuke",
            postTime: Calendar.current.date(byAdding: .minute, value: -10, to: Date()),
            imageUrl: "https://placehold.jp/200x200.png",
            goodCount: 3,
            comments: ["筋トレしよう"]
        ),
        PostInfo(
            id: UUID().uuidString,
            userName: "niko.a-ru",
            postTime: Calendar.current.date(byAdding: .minute, value: -10, to: Date()),
            imageUrl: "https://placehold.jp/200x200.png",
            goodCount: 3,
            comments: ["もう一回お布団に入りたい❣️"]
        ),
        PostInfo(
            id: UUID().uuidString,
            userName: "aika.aikasu",
            postTime: Calendar.current.date(byAdding: .minute, value: -10, to: Date()),
            imageUrl: "https://placehold.jp/200x200.png",
            goodCount: 3,
            comments: ["やっぱり私朝強い"]
        ),
    ]
}
