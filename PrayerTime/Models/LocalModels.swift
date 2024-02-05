
import Foundation

struct PrayerTime: Equatable, Comparable {
    let name: String
    let date: Date
    
    static func <(lhs: Self, rhs: Self) -> Bool {
        lhs.date < rhs.date
    }
}

#if DEBUG
extension PrayerTime {
    static var tenMinutesFromNow: Self {
        PrayerTime(name: "TenMinutes", date: Date().addingTimeInterval(600))
    }
    static var distantPast = PrayerTime(name: "DistantPast", date: Date.distantPast)
    static var empty = PrayerTime(name: "", date: .now)
}
#endif
