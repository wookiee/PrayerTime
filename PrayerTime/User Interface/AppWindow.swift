
import AppKit
import Combine
import SwiftUI

class AppWindowSizeModel: ObservableObject {
    @Published var size: CGSize = .zero
}

class AppWindow: NSWindow {
    
    var updater = CADisplayLink()
    
    override init(contentRect: NSRect,
                  styleMask style: NSWindow.StyleMask,
                  backing backingStoreType: NSWindow.BackingStoreType,
                  defer flag: Bool) {

        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        configureWindow()
        configureContentView()
        configureResizing()
        
        // Stale shadow keeps uncleared pixels (an AppKit/SwiftUI bug). Workaround:
        self.updater = displayLink(target: self, selector: #selector(invalidateShadow))
        self.updater.add(to: .main, forMode: .common)
    }
    
    // MARK: - Configuration
    
    func configureWindow() {
        isMovableByWindowBackground = true
        backgroundColor = .clear
        isOpaque = true
        hasShadow = true
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        level = .floating
        center()
        setIsVisible(true)
    }
    
    func configureContentView() {
        contentView = NSHostingView(rootView: ContentView().environmentObject(windowSizeModel))
        contentView!.wantsLayer = true
        contentView!.layer!.masksToBounds = true
        contentView!.layer!.cornerRadius = 20
        contentView!.layer!.cornerCurve = .continuous
        contentView!.layer!.backgroundColor = .clear
        contentView!.layer!.isOpaque = true
        contentView!.layer!.needsDisplayOnBoundsChange = true
    }
    
    // MARK: - Resizing on content change
    
    var windowSizeModel = AppWindowSizeModel()
    private var subs = Set<AnyCancellable>()
    
    func configureResizing() {
        windowSizeModel.$size
            .sink { [unowned self] in self.adjustWindowSize(for: $0) }
            .store(in: &subs)
    }
    
    private func adjustWindowSize(for contentSize: CGSize) {
        let rectForNewSize = frameRect(forContentRect: CGRect(origin: frame.origin, size: contentSize))
        let newFrame = NSRect(origin: frame.origin, size: rectForNewSize.size)
        setFrame(newFrame, display: true, animate: true)
        invalidateShadow()
    }
    
    // MARK: - NSWindow Overrides
    
    override var canBecomeKey: Bool {
        return true
    }
}
