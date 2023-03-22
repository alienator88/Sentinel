import SwiftUI

struct AboutCommand: Commands {
    
    var body: some Commands {
        // Replace the About window menu option.
        CommandGroup(replacing: .appInfo) {
            Button {
                AboutWindow.show()
            } label: {
                Text("About \(Bundle.main.name)")
            }
        }
    }
}
