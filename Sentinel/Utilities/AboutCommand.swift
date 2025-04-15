import SwiftUI
import AlinFoundation

struct AboutCommand: Commands {
    @State private var windowController = WindowManager()
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
                updater.checkForUpdates(sheet: true, force: false)
            } label: {
                Text("Check for Updates")
            }
            .keyboardShortcut("u", modifiers: .command)

            Button {
                windowController.open(with: ConsoleView(), width: 600, height: 400)
            } label: {
                Text("Debug Console")
            }
            .keyboardShortcut("d", modifiers: .command)

        }
    }
}
