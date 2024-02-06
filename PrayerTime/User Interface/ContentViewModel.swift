
import Foundation
import Combine
import SwiftUI

@MainActor class ContentViewModel: ObservableObject {
    let store = PrayerTimeStore.shared
    
    @Published var primaryContent = ""
    @Published var secondaryContent = ""
    @Published var backgroundColor = Color.white.opacity(0.5)
    
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
            .filter { $0.name != "" }
            .map { // string to display in the primary Text
                "\($0.name) at \($0.date.formatted(date: .omitted, time: .shortened))"
            }
            .assign(to: &$primaryContent)
        
        store.$timeToNextPrayer
            .map { // string to display in the secondary Text
                "in \(self.timeFormatter.string(from: $0) ?? "spacetime")"
            }
            .assign(to: &$secondaryContent)
    }
}
