import Foundation
import SwiftData


//アラームデータ構造

@Model
final class AlarmData: Identifiable {
    var id: String
    var date: Date
    var wakeUpTime: Date
    var leaveTime: Date
    var isOn: Bool = false
    var isWakeup : Bool = false
    var isLeave : Bool = false
    
    init(date: Date, wakeUpTime: Date, leaveTime: Date) {
        self.id = UUID().uuidString
        self.date = date
        self.wakeUpTime = wakeUpTime
        self.leaveTime = leaveTime
    }
}



enum alarmStatus {
    case setted
    case unsetted
    case error
}
