import SwiftUI

struct AboutCommand: Commands {
    let appState: AppState
    init(appState: AppState) {
        self.appState = appState
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
                loadGithubReleases(appState: appState, manual: true)
            } label: {
                Text("Check for Updates")
            }
            .keyboardShortcut("u", modifiers: .command)

        }
    }
}
