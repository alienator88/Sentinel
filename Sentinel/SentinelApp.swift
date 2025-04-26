import SwiftUI
import AlinFoundation

@main
struct SentinelApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var appState = AppState.shared
    @StateObject private var updater = Updater(owner: "alienator88", repo: "Sentinel")

    var body: some Scene {
        WindowGroup {
            Dashboardv2()
                .environmentObject(appState)
                .environmentObject(updater)
                .sheet(isPresented: $updater.sheet, content: {
                    /// This will show the update sheet based on the frequency check function
                    updater.getUpdateView()
                })
        }
        .commands {
            AboutCommand(appState: appState, updater: updater)
            CommandGroup(replacing: .newItem, addition: { })
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environmentObject(appState)
                .environmentObject(updater)
                .toolbarBackground(.clear)
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Get GK status on application focus
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Only update Gatekeeper UI if the app is not in a loading/notarizing state
            guard !AppState.shared.isLoading else { return }
            updateGatekeeperUI(appState: AppState.shared)
        }
        
            // Add window close notification observer
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: nil,
            queue: .main
        ) { _ in
            if NSApp.windows.isEmpty {
                NSApp.terminate(nil)
            }
        }
    }
}
