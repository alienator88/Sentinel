//
//  Dashboard.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import SwiftUI
import UniformTypeIdentifiers

private let dropTypes = [UTType.fileURL]

struct Dashboard: View {
    
        @EnvironmentObject var appState: AppState
//    @ObservedObject var appState: AppState = AppState()
    @State private var isLoading = true
//    @State private var active = true
//    @AppStorage("active") var active: Bool = true
//    @State private var isHovered1 = false
//    @State private var isHovered2 = false

    
    
    var body: some View {
        VStack {
            
            if isLoading {
                ProgressView
                {
                    Text("Loading Gatekeeper Status")
                }
            } else {
                
                let dashColumns : [GridItem] = [
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0)
                ]
                
                // LOGO - TITLEBAR //////////////////////////////////////////////////////
                HStack(alignment: .center) {
                    HStack{
                        
                    }
                    Spacer()
                    HStack{
                        Image(nsImage: NSApp.applicationIconImage ?? NSImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                        Text("Sentinel")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .padding(.leading, 30)
                    
                    Spacer()
                    Button{
                        AboutWindow.show()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .padding()
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                
                
                // GIANT STATUS //////////////////////////////////////////////////////
                HStack {
                    
                    Image(systemName: appState.isGatekeeperEnabled ? "lock.shield" : "shield.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(appState.isGatekeeperEnabled ? .green : .red)
                    Text(appState.isGatekeeperEnabled ? "ENABLED" : "DISABLED")
                        .foregroundColor(appState.isGatekeeperEnabled ? .green : .red)
                        .font(.title)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(appState.isGatekeeperEnabled ? .green : .red, lineWidth: 2)
                )
                .help("Your Gatekeeper assessments are \(appState.isGatekeeperEnabled ? "enabled" : "disabled")")
                
                HStack(alignment: .center){
                    Text(appState.status)
                        .padding(5)
                        .padding(.horizontal, 4)
                        .textCase(.uppercase)
                        .font(.system(size: 12))
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color("bg").opacity(0.5)))
                }
                .padding(4)
                .padding(.top, 4)
                
                // GRID //////////////////////////////////////////////////////
                
                Toggle(isOn: $appState.active) {
                }
                .toggleStyle(MyToggleStyle())



                LazyVGrid(columns: dashColumns) {
                    

                    // Item 1 //////////////////////////////////////////////////////////////////////////
                    
                    ZStack {
                        
                        DropTarget(delegate: DropQuarantine(appState: appState), types: dropTypes)
                            .frame(width: 200, height: 150)
                            .overlay(dropOverlayQuarantine, alignment: .center)
                            .padding()
                        
                    }
                    .frame(width: 200, height: 150 )
                    .padding(.trailing, 20)
                    .padding(.leading, 20)

                    
                    
                    // Item 2 //////////////////////////////////////////////////////////////////////////
                    
                    ZStack {
                        
                        DropTarget(delegate: DropSign(appState: appState), types: dropTypes)
                            .frame(width: 200, height: 150)
                            .overlay(dropOverlaySign, alignment: .center)
                            .padding()
                        
                    }
                    .frame(width: 200, height: 150 )
                    .padding(.trailing, 20)
                    
                    
                }
                .padding()
                /// LazyVGrid Container
                
            }
            
            
        } /// Main VStack Container
        .onAppear{
            Task(priority: .high) {
                isLoading = true
                _ = await CmdRun(cmd: "spctl --status", appState: appState)
                isLoading = false
            }
        }
        .onChange(of: appState.active) { value in
            if value == true && appState.isGatekeeperEnabled {
                return
            } else if value == false && !appState.isGatekeeperEnabled {
                return
            } else if value == true && !appState.isGatekeeperEnabled{
                Task {
                    appState.status = "Attempting to turn on gatekeeper, enter your root password"
                    _ = await CmdRunSudo(cmd: "spctl --global-enable", type: "enable", appState: appState)
                }
            } else if value == false && appState.isGatekeeperEnabled {
                Task {
                    appState.status = "Attempting to turn off gatekeeper, enter your root password"
                    _ = await CmdRunSudo(cmd: "spctl --global-disable", type: "disable", appState: appState)
                }
            }
        }
        .edgesIgnoringSafeArea(.top) /// Allow AboutWindow button to tuck into top right corner
        
        
    }
    
    
    @ViewBuilder private var dropOverlayQuarantine: some View {
        
        VStack(alignment: .center) {
            Image(systemName: "stethoscope")
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
                .foregroundColor(Color("drop")).opacity(1)
            Text("Drop application here to remove from quarantine")
                .foregroundColor(Color("drop"))
                .opacity(1)
                .font(.title3)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
        }
        .help("This will change the app attributes in com.apple.quarantine using 'xattr'")
        
    }
    
    @ViewBuilder private var dropOverlaySign: some View {
        
        VStack(alignment: .center) {
            Image(systemName: "pencil.line")
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
                .foregroundColor(Color("drop")).opacity(1)
            Text("Drop application here to self-sign")
                .foregroundColor(Color("drop"))
                .opacity(1)
                .font(.title3)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
        }
        .help("This will replace the app signature by performing an ad-hoc signing")
        
    }
    
    
}


// Drop Delegates
struct DropQuarantine: DropDelegate {
    
    @ObservedObject var appState: AppState
    
    func performDrop(info: DropInfo) -> Bool {
        
        let itemProviders = info.itemProviders(for: [UTType.fileURL])
        
        guard itemProviders.count == 1 else {
            return false
        }
        for itemProvider in itemProviders {
            itemProvider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                guard let data = item as? Data else {
                    dump(error)
                    return
                }
                guard let url = URL(dataRepresentation: data, relativeTo: nil) else {
                    print("Error: Not a valid URL.")
                    return
                }
                Task
                {
                    appState.status = "Attempting to remove app from quarantine"
                    
                    _ = await CmdRunDrop(cmd: "xattr -rd com.apple.quarantine \(url.path)", type: "quarantine", appState: appState)
                    
//                    appState.status = "Removed app from quarantine"
                    
                }
                
            }
        }
        
        return true
    }
}


struct DropSign: DropDelegate {
    
    @ObservedObject var appState: AppState
    
    func performDrop(info: DropInfo) -> Bool {
        
        let itemProviders = info.itemProviders(for: [UTType.fileURL])
        
        guard itemProviders.count == 1 else {
            return false
        }
        for itemProvider in itemProviders {
            itemProvider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                guard let data = item as? Data else {
                    dump(error)
                    return
                }
                guard let url = URL(dataRepresentation: data, relativeTo: nil) else {
                    print("Error: Not a valid URL.")
                    return
                }
                Task
                {
                    
                    appState.status = "Attempting to self-sign the app"
                    
                    _ = await CmdRunDrop(cmd: "codesign -f -s - --deep \(url.path)", type: "sign", appState: appState)
                    
//                    appState.status = "App has been self-signed"
                    
                }
                
            }
        }
        
        return true
    }
}
