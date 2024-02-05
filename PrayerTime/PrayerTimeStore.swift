
import Foundation
import Combine

class PrayerTimeStore: ObservableObject {
    
    @Published private(set) var prayerTimes: [PrayerTime] = []
    @Published private(set) var nextPrayerTime: PrayerTime = .empty
    @Published private(set) var timeToNextPrayer: TimeInterval = 0
    
    let everySecond = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .share()
        .eraseToAnyPublisher()
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    static let shared = PrayerTimeStore()
    
    private init() {
        configureSubscriptions()
    }
    
    func prayerTimeToDisplay(from prayerTimes: [PrayerTime]) -> PrayerTime {
        let upcomingPrayerTimes = self.prayerTimes.filter { timing in
            timing.date.timeIntervalSinceNow >= 0
        }
        return upcomingPrayerTimes.isEmpty ? self.prayerTimes.reversed()[0] : upcomingPrayerTimes[0]
    }
    
    // MARK: - Combine subs for data pub
    
    private func configureSubscriptions() {
        configurePrayerTimesUpdater()
        configureNextPrayerTimeUpdater()
        configureTimeToNextPrayerTimeUpdater()
    }
    
    private func configurePrayerTimesUpdater() {
        everySecond
            .map { timerFireDate in // Day of the current month for parsing response
                PrayerTimeStore.calendar.component(.day, from: timerFireDate)
            }
            .removeDuplicates() // only when the day has changed
            .setFailureType(to: Error.self)
            .tryAsyncMap { _ in // array of today's prayer times
                return try await self.fetchDailyPrayerTimes(for: Date())
            }
            .assertNoFailure("Failed to fetch+parse prayer times from server.")
            .assign(to: &$prayerTimes)
    }
    
    private func configureNextPrayerTimeUpdater() {
        everySecond
            .replace {
                self.prayerTimes.first { $0.date.timeIntervalSinceNow >= 0 }
            }
            .compactUnwrap()
            .removeDuplicates() // only when next timing changes
            .assign(to: &$nextPrayerTime)
    }
    
    private func configureTimeToNextPrayerTimeUpdater() {
        everySecond
            .replace { // time interval to the next prayer time
                self.nextPrayerTime.date.timeIntervalSinceNow
            }
            .assign(to: &$timeToNextPrayer)
    }
    
    // MARK: - Web service client
    
    func fetchDailyPrayerTimes(for date: Date) async throws -> [PrayerTime] {
        let url = url(for: date)
        let (data, _) = try await URLSession.shared.data(from: url)
        let sortedTimings = try timings(from: data, for: date)
        
        return sortedTimings
    }
    
    func url(for date: Date) -> URL {
        // Figure out today's date components
        let calendar = PrayerTimeStore.calendar
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        // Build the URL
        let cityItem = URLQueryItem(name: "city", value: "Riyadh")
        let countryItem = URLQueryItem(name: "country", value: "Saudi Arabia")
        let iso8601Item = URLQueryItem(name: "iso8601", value: "true")
        var url = URL(string: "http://api.aladhan.com/v1/calendarByCity/\(year)/\(month)")!
        url.append(queryItems: [cityItem, countryItem, iso8601Item])
        
        return url
    }
    
    // MARK: - Parsing web service results
    
    func timings(from data: Data, for date: Date, dayCount: Int = 1) throws -> [PrayerTime] {
        let calendar = PrayerTimeStore.calendar
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(JSONResponse.self, from: data)
        
        let monthTimings = response.data
        let todayDayNumber = calendar.component(.day, from: date)
        let todayTimings = timings(forDayNumber: todayDayNumber, fromMonthTimingInfo: monthTimings)
        let tomorrowTimings = timings(forDayNumber: todayDayNumber + 1, fromMonthTimingInfo: monthTimings)
        let relevantTimings = (todayTimings + tomorrowTimings).sorted()
        
        return relevantTimings
    }
    
    func timings(forDayNumber dayNumber: Int, fromMonthTimingInfo monthTimings: [JSONDateInfo]) -> [PrayerTime] {
        guard let dayTimingInfo = monthTimings.first(where: { timingInfo in
            let jsonDay = Int(timingInfo.date.gregorian.day)!
            return jsonDay == dayNumber
        }) else {
            fatalError()
        }
        let dayTimings = dayTimingInfo.timings.map { (key, value) in PrayerTime(name: key, date: value) }
        return dayTimings
    }
}
