import SwiftUI
import AlinFoundation

@main
struct SentinelApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var appState = AppState.shared
    @StateObject private var updater = Updater(owner: "alienator88", repo: "Sentinel")

    var body: some Scene {
        WindowGroup {
            Dashboard()
                .environmentObject(appState)
                .environmentObject(updater)
                .sheet(isPresented: $updater.sheet, content: {
                    /// This will show the update sheet based on the frequency check function
                    updater.getUpdateView()
                })
                .onAppear {
                    appState.availableIdentities = loadIdentities()
                }
                .handlesExternalEvents(preferring: Set(arrayLiteral: "sentinel"), allowing: Set(arrayLiteral: "*"))
                .onOpenURL(perform: { url in
                    handleDeepLinkedApps(url: url, appState: appState)
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

    // MARK: - File Opening

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        // Set multiDrop flag if more than one file
        if filenames.count > 1 {
            updateOnMain {
                AppState.shared.multiDrop = true
            }
        }

        // Process each dropped file
        for filename in filenames {
            guard FileManager.default.fileExists(atPath: filename) else {
                printOS("File dropped on Dock icon doesn't exist: \(filename)")
                continue
            }

            let fileURL = URL(fileURLWithPath: filename)

            guard fileURL.pathExtension == "app" else {
                printOS("Dropped file is not an application bundle: \(filename)")
                continue
            }

            // Process the file using existing logic
            handleDeepLinkedApps(url: fileURL, appState: AppState.shared)
        }
    }
}
