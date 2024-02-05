
import SwiftUI
import AppKit

@main
struct PrayerTimeApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {} // just because the body can't be empty
    }
}
