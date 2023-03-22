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
    
    //    @EnvironmentObject var appState: AppState
    @ObservedObject var appState: AppState = AppState()
    @State private var isLoading = true
    @State private var isHovered1 = false
    @State private var isHovered2 = false
//    @State private var isHovered3 = false
//    @State private var isHovered4 = false
    
    
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
                //                .padding(.top, 10)
                
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
                
                LazyVGrid(columns: dashColumns) {
                    
                    // Item 1 //////////////////////////////////////////////////////////////////////////
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color("stroke").opacity(1), style: StrokeStyle(lineWidth: 1, dashPhase: 0))
                            .background(RoundedRectangle(cornerRadius: 8).fill(isHovered1 ? Color("bg").opacity(1) : Color("bg").opacity(0.5)))
                            .frame(width: 200, height: 150 )
                            
                        
                        
                        VStack {
                            
                            HStack {
                                Image(systemName: "lock.shield")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 26, height: 26)
                                    .padding(.leading, 10)
                                    .padding(.top, 10)
                                    .opacity(1)
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            
                            
                            HStack {
                                
                                Text("Turn ON Gatekeeper")
                                    .font(.title2)
                            }
                            .padding(.top, 25)
                            Spacer()
                            
                            
                        }
                        
                    }
                    .onHover{ isHovered1 in
                        withAnimation(.linear(duration: 0.1)) {
                            self.isHovered1 = isHovered1
                        }
                        
                    }
                    .scaleEffect(isHovered1 ? 1.02 : 1.0)
                    .frame(width: 200, height: 150 )
                    .onTapGesture {
                        Task {
                            
                            appState.status = "Attempting to turn on gatekeeper, enter your root password"

                            _ = await CmdRunSudo(cmd: "spctl --global-enable", type: "enable", appState: appState)
                            
//                            appState.status = "Gatekeeper has been enabled"

                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.trailing, 20)
                    .padding(.leading, 20)

                    
                    // Item 2 //////////////////////////////////////////////////////////////////////////
                    
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color("stroke").opacity(1), style: StrokeStyle(lineWidth: 1, dashPhase: 0))
                            .background(RoundedRectangle(cornerRadius: 8).fill(isHovered2 ? Color("bg").opacity(1) : Color("bg").opacity(0.5)))
                            .frame(width: 200, height: 150 )
                            
                        
                        
                        VStack {
                            
                            HStack {
                                Image(systemName: "shield.slash")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 26, height: 26)
                                    .padding(.leading, 10)
                                    .padding(.top, 10)
                                    .opacity(1)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            
                            
                            HStack {
                                Text("Turn OFF Gatekeeper")
                                    .font(.title2)
                                
                            }
                            .padding(.top, 25)
                            Spacer()
                            
                            
                        }
                        
                    }
                    .onHover{ isHovered2 in
                        withAnimation(.linear(duration: 0.1)) {
                            self.isHovered2 = isHovered2
                        }
                        
                    }
                    .scaleEffect(isHovered2 ? 1.02 : 1.0)
                    .frame(width: 200, height: 150 )
                    .onTapGesture {
                        Task {

                            appState.status = "Attempting to turn off gatekeeper, enter your root password"

                            _ = await CmdRunSudo(cmd: "spctl --global-disable", type: "disable", appState: appState)
                            
//                            appState.status = "Gatekeeper has been disabled"

                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.trailing, 20)
                    
                    
                    // Item 3 //////////////////////////////////////////////////////////////////////////
                    
                    
                    ZStack {
                        
                        DropTarget(delegate: DropQuarantine(appState: appState), types: dropTypes)
                            .frame(width: 200, height: 150)
                            .overlay(dropOverlayQuarantine, alignment: .center)
                            .padding()
                        
                    }
//                    .onHover{ isHovered3 in
//                        withAnimation(.linear(duration: 0.1)) {
//                            self.isHovered3 = isHovered3
//                        }
//
//                    }
//                    .scaleEffect(isHovered3 ? 1.02 : 1.0)
                    .frame(width: 200, height: 150 )
                    .padding(.trailing, 20)
                    .padding(.leading, 20)

                    
                    
                    // Item 4 //////////////////////////////////////////////////////////////////////////
                    
                    
                    
                    ZStack {
                        
                        DropTarget(delegate: DropSign(appState: appState), types: dropTypes)
                            .frame(width: 200, height: 150)
                            .overlay(dropOverlaySign, alignment: .center)
                            .padding()
                        
                    }
//                    .onHover{ isHovered4 in
//                        withAnimation(.linear(duration: 0.1)) {
//                            self.isHovered4 = isHovered4
//                        }
//
//                    }
//                    .scaleEffect(isHovered4 ? 1.02 : 1.0)
                    .frame(width: 200, height: 150 )
                    .padding(.trailing, 20)
                    
                    
                } // LazyVGrid Container
                .padding()
                
                
            }
            
            
        } // Main VStack Container
        .onAppear{
            Task(priority: .high) {
                isLoading = true
                _ = await CmdRun(cmd: "spctl --status", appState: appState)
                isLoading = false
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
