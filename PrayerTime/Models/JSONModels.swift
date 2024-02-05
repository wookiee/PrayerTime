
import Foundation

// MARK: - JSONResponse
struct JSONResponse: Codable {
    let code: Int
    let status: String
    let data: [JSONDateInfo]
}

// MARK: - JSONDateInfo
struct JSONDateInfo: Codable {
    let timings: [String:Date]
    let date: JSONDate
}

// MARK: - JSONDate
struct JSONDate: Codable {
    let readable, timestamp: String
    let gregorian: JSONCalendar
}

// MARK: - JSONCalendar
struct JSONCalendar: Codable {
    let date, format, day: String
}
