
import AppKit
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        window = AppWindow(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered, defer: false)
    }
}
