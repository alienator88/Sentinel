import SwiftUI

@main
struct SentinelApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appState = AppState()
    @AppStorage("settings.updater.updateTimeframe") private var updateTimeframe: Int = 1

    var body: some Scene {
        WindowGroup {
            Group {
                Dashboard()
                    .environmentObject(appState)
            }
            .onAppear {
                Task {
                    ensureApplicationSupportFolderExists(appState: appState)
                    loadGithubReleases(appState: appState)
                }
            }
        }
        .commands {
            AboutCommand(appState: appState)
            CommandGroup(replacing: .newItem, addition: { })
        }
        .windowToolbarStyle(.automatic)
        .windowStyle(.hiddenTitleBar)

        Settings {
            SettingsView()
                .environmentObject(appState)
        }

    }


    
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowDelegate = WindowDelegate()

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.delegate = windowDelegate
            // Set the fixed size of the window here
            let desiredWidth: CGFloat = 550
            let desiredHeight: CGFloat = 420
            let frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: desiredWidth, height: desiredHeight)
            window.setFrame(frame, display: true)
        }
    }

    class WindowDelegate: NSObject, NSWindowDelegate {
        func windowDidBecomeMain(_ notification: Notification) {
            if let window = notification.object as? NSWindow {
                window.styleMask.remove(.resizable)

                // Maintain the current bottom-left corner position
                let currentBottomLeft = CGPoint(x: window.frame.minX, y: window.frame.maxY)

                let desiredWidth: CGFloat = 550
                let desiredHeight: CGFloat = 420

                // Calculate new frame based on desired size but keeping the bottom-left corner anchored
                let frame = CGRect(x: currentBottomLeft.x, y: currentBottomLeft.y - desiredHeight, width: desiredWidth, height: desiredHeight)
                window.setFrame(frame, display: true, animate: false)
            }
        }
    }

}


struct VisualEffect: NSViewRepresentable {
    func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
    func updateNSView(_ nsView: NSView, context: Context) { }
}
