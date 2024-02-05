
import AppKit
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow!
    var windowSizeModel = WindowSizeModel()
    private var subs = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        configureWindow()
        
        // Observe the size model for changes
        windowSizeModel.$size.sink { newSize in
            self.adjustWindowSize(for: newSize)
        }.store(in: &subs) // Assuming you have a Set<AnyCancellable> for Combine cancellables
    }
    
    private func configureWindow() {
        // Create the window
        window = NSWindow(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered, defer: false)

        // Create the SwiftUI view that provides the window contents.
        window.contentView = NSHostingView(rootView: ContentView().environmentObject(windowSizeModel))
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.masksToBounds = true
        window.contentView?.layer?.cornerRadius = 20
        window.contentView?.layer?.cornerCurve = .continuous
        window.contentView?.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.hasShadow = true
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.level = .floating
        window.center()
        window.setIsVisible(true)
        window.makeKeyAndOrderFront(nil)
    }
    
    private func adjustWindowSize(for contentSize: CGSize) {
        var frame = window.frame
        let newFrame = window.frameRect(forContentRect: CGRect(origin: frame.origin, size: contentSize))
        frame.size = newFrame.size
        window.setFrame(frame, display: true, animate: true)
    }
}
