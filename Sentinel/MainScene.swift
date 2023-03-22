import SwiftUI

struct VisualEffect: NSViewRepresentable {
  func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
  func updateNSView(_ nsView: NSView, context: Context) { }
}

struct MainScene: Scene {
    
    @StateObject var appState = AppState()
    @State private var isLoading = true
    
    var body: some Scene {
        
        WindowGroup {
            Dashboard()
                .frame(minWidth: 550, minHeight: 400)
//                .background(VisualEffect().ignoresSafeArea())
                .fixedSize()
                .environmentObject(appState)

                
        }
        .commands {
            AboutCommand()
            
            // Remove the "New Window" option from the File menu.
            CommandGroup(replacing: .newItem, addition: { })
        }
        .windowToolbarStyle(.automatic)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

    }
}
