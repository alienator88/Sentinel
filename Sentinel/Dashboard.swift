//
//  Dashboard.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import SwiftUI
import UniformTypeIdentifiers
import AlinFoundation

private let dropTypes = [UTType.fileURL]

struct Dashboard: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var updater: Updater
//    @State private var bounce = false

    var body: some View {
        VStack(alignment: .center, spacing: 30) {

            // LOGO - TITLEBAR //////////////////////////////////////////////////////
            HStack(alignment: .center, spacing: 0) {
                Spacer()

                if updater.updateAvailable {
                    UpdateBadge(updater: updater)
                        .frame(width: 250)
                } else {
                    Text("Sentinel")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                }

//                Spacer()

            }
            .frame(maxWidth: .infinity)

            // Drop Zones //////////////////////////////////////////////////////


            VStack(alignment: .center, spacing: 20) {

                HStack() {
                    Text("Drop an **app** below")
                        .font(.title2).opacity(0.8)
                    Image(systemName: "arrow.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14)
//                        .offset(y: bounce ? -2 : 2)
//                        .animation(
//                            .easeInOut(duration: 0.4)
//                            .repeatCount(7, autoreverses: true),
//                            value: bounce
//                        )
//                        .onAppear {
//                            bounce = true
//                        }
                }


                HStack(spacing: 50) {
                    // Item 1 //////////////////////////////////////////////////////////////////////////

                    ZStack {

                        DropTarget(delegate: DropQuarantine(appState: appState), types: dropTypes)
                            .frame(width: 200, height: 150)
                            .overlay(dropOverlayQuarantine, alignment: .center)
                            .opacity(0.8)

                    }
                    .frame(width: 200, height: 150 )

                    // Item 2 //////////////////////////////////////////////////////////////////////////

                    ZStack {

                        DropTarget(delegate: DropSign(appState: appState), types: dropTypes)
                            .frame(width: 200, height: 150)
                            .overlay(dropOverlaySign, alignment: .center)
                            .opacity(0.8)

                    }
                    .frame(width: 200, height: 150 )
                }
            }



            // GK STATUS //////////////////////////////////////////////////////

            Spacer()

            VStack(spacing: 15) {
                Toggle("", isOn: $appState.isGatekeeperEnabled)
                    .toggleStyle(RedGreenShield())
                    .help("Your Gatekeeper assessments are \(appState.isGatekeeperEnabled ? "enabled" : "disabled")")

                if #available(macOS 15, *) {
                    InfoButton(text: "macOS Sequoia and up does not allow gatekeeper control via command line(spctl) anymore. The only way to control this now is by adding a configuration profile.\n\nToggle the switch and double click the 'Disable Gatekeeper' profile or the 'Enable Gatekeeper' profile in the Settings pane to install", color: .primary, label: "", warning: false)
                }

            }


            HStack(alignment: .center){
                Text(appState.status)
                    .font(.system(size: 12))
                    .opacity(0.8)
                    .padding(.vertical)
            }
            .padding(.vertical)

        }
        .padding()
        .onAppear {
            Task{
                _ = await CmdRun(cmd: "spctl --status", appState: appState)
                updateOnMain {
                    appState.status = "\(appState.isGatekeeperEnabled ? "Gatekeeper is enabled" : "Gatekeeper is disabled")"
                }
            }
        }
        .onChange(of: appState.isGatekeeperEnabled) { isEnabled in
            Task {
                if #available(macOS 15, *) {
                    if isEnabled && !appState.isGatekeeperEnabledState {
                        updateOnMain() {
                            appState.status = "Installing gatekeeper enable profile, enter your admin password"
                        }
                        openFileAndSystemPreferences(filename: "enable", withExtension: "mobileconfig", disable: false, appState: appState)
                    } else if !isEnabled && appState.isGatekeeperEnabledState {
                        updateOnMain() {
                            appState.status = "Installing gatekeeper disable profile, enter your admin password"
                        }
                        openFileAndSystemPreferences(filename: "disable", withExtension: "mobileconfig", disable: true, appState: appState)
                    }
                } else {
                    if isEnabled && !appState.isGatekeeperEnabledState {
                        updateOnMain() {
                            appState.status = "Attempting to turn on gatekeeper, enter your admin password"
                        }
                        CmdRunSudo(cmd: "spctl --global-enable", type: "enable", appState: appState)
                    } else if !isEnabled && appState.isGatekeeperEnabledState {
                        updateOnMain() {
                            appState.status = "Attempting to turn off gatekeeper, enter your admin password"
                        }
                        CmdRunSudo(cmd: "spctl --global-disable", type: "disable", appState: appState)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)

    }


    @ViewBuilder private var dropOverlayQuarantine: some View {

        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "plus.square.dashed")
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
                .foregroundColor(Color("drop")).opacity(1)
            Text("Remove app from quarantine")
                .foregroundColor(Color("drop"))
                .opacity(1)
                .font(.callout)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
        }
        .help("This will unquarantine the app by changing attributes in com.apple.quarantine")

    }

    @ViewBuilder private var dropOverlaySign: some View {

        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "plus.square.dashed")
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
                .foregroundColor(Color("drop")).opacity(1)
            Text("Self-sign the app")
                .foregroundColor(Color("drop"))
                .opacity(1)
                .font(.callout)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
        }
        .help("This will replace the app signature by performing an ad-hoc signing without a certificate")

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
                }

            }
        }

        return true
    }
}
