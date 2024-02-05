
import Foundation
import Combine

@MainActor class ContentViewModel: ObservableObject {
    let store = PrayerTimeStore.shared
    
    @Published var primaryContent: String = ""
    @Published var secondaryContent: String = ""
    
    private var subs = Set<AnyCancellable>()
    
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.calendar = .current
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    init() {
        configureSubscriptions()
    }
    
    private func configureSubscriptions() {
        store.$nextPrayerTime
            .map { "\($0.name) at \($0.date.formatted(date: .omitted, time: .shortened))" }
            .print()
            .assign(to: &$primaryContent)
        
        store.$timeToNextPrayer
            .map { "in \(self.timeFormatter.string(from: $0) ?? "spacetime")" }
            .assign(to: &$secondaryContent)
    }
}
