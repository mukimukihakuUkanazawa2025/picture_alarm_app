//
//  Item.swift
//  picture_alarm_app
//
//  Created by tanaka niko on 2025/09/12.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
