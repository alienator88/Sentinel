import AppKit
import SwiftUI

class AboutWindow: NSWindowController {
    
    static func show() {
        AboutWindow().window?.makeKeyAndOrderFront(nil)
    }
    
    convenience init() {
        
        let window = Self.makeWindow()
        
        window.backgroundColor = NSColor.controlBackgroundColor
        
        self.init(window: window)
        
        // Using Visual Effect to make titlebar fully transparent
        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .underWindowBackground
        
        let contentView = makeAboutView()
        
        let hostView = NSHostingView(rootView: contentView)
        
        window.contentView = visualEffect
        
        visualEffect.addSubview(hostView)
        hostView.frame = visualEffect.frame
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.center()
        window.title = "Sentinel"
        
    }
    
    private static func makeWindow() -> NSWindow {
        let contentRect = NSRect(x: 0, y: 0, width: 500, height: 260)
        let styleMask: NSWindow.StyleMask = [
            .titled,
            .closable,
            .fullSizeContentView,
            
        ]
        return NSWindow(contentRect: contentRect,
                        styleMask: styleMask,
                        backing: .buffered,
                        defer: false)
    }
    
    private func makeAboutView() -> some View {
        AboutView(
            icon: NSApp.applicationIconImage ?? NSImage(),
            name: Bundle.main.name,
            version: Bundle.main.version,
            build: Bundle.main.buildVersion,
            developerName: "Alin Lupascu")
        .frame(width: 500, height: 260)
    }
}
