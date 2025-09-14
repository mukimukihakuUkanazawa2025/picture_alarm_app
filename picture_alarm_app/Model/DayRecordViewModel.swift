//
//  DayrecordViewModel.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/14.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

// 投稿において必要な情報をまとめたクラス
class DayRecordViewModel: ObservableObject {
    
    private var db = Firestore.firestore()
    
    @Published var dayrecords: [DayRecord] = []
    
    // 投稿情報を作成する関数
    func saveDayrecord(wakeUpTime: Date?, leaveTime: Date?, completion: @escaping (Error?) -> Void) {
        
        let docRef = db.collection("dayRecord").document()
        
        let dayRecord = DayRecord(
            id: docRef.documentID,
            postDate: Timestamp(),
            wakeUpTime: wakeUpTime,
            leaveTime: leaveTime,
            goodNumbers: 0,
            comments: "テストコメントだよーん"
        )
        
        docRef.setData([
            "id": dayRecord.id,
            "postDate": dayRecord.postDate,
            "wakeUpTime": wakeUpTime != nil ? Timestamp(date: wakeUpTime!) : nil,
            "leaveTime": leaveTime != nil ? Timestamp(date: leaveTime!) : nil,
            "goodNumbers": dayRecord.goodNumbers ?? 0,
            "comments": dayRecord.comments ?? ""
        ]) { error in
            completion(error)
        }
    }
    
    //　投稿情報を取得する関数
    
    // 投稿情報を更新する関数
}

extension Date {
    /// 24時間表記 (HH:mm) の文字列に変換
    func toTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}
