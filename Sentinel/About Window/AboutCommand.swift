import SwiftUI
import AlinFoundation

struct AboutCommand: Commands {
    let appState: AppState
    let updater: Updater
    init(appState: AppState, updater: Updater) {
        self.appState = appState
        self.updater = updater
    }

    var body: some Commands {
        // Replace the About window menu option.
        CommandGroup(replacing: .appInfo) {
            Button {
                AboutWindow.show()
            } label: {
                Text("About \(Bundle.main.name)")
            }

            Button {
                updater.checkForUpdates(sheet: true, force: false)
            } label: {
                Text("Check for Updates")
            }
            .keyboardShortcut("u", modifiers: .command)

        }
    }
}
