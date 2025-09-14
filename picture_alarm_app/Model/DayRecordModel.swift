//
//  DayRecordModel.swift
//  picture_alarm_app
//
//  Created by A S on 2025/09/14.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct DayRecord: Identifiable {
    
    var id: String
    
    var postDate: Timestamp
    
    var wakeUpTime: Date?
    var leaveTime: Date?
    
//    var wakeUpPicture: NSData?
//    var leavePicture: NSData?
    
    var goodNumbers: Int?
    var comments: String?
}

