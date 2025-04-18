//
//  Dashboard.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import SwiftUI
import UniformTypeIdentifiers
import AlinFoundation
import Security

private let dropTypes = [UTType.fileURL]

struct Dashboard: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var updater: Updater
    @AppStorage("sentinel.general.codesignIdentity") private var selectedIdentity = "None"

    var body: some View {
        VStack(alignment: .center, spacing: 10) {

            // LOGO - TITLEBAR //////////////////////////////////////////////////////
            HStack(alignment: .center, spacing: 0) {
                Spacer()

                if updater.updateAvailable {
                    UpdateBadge(updater: updater, hideLabel: true)
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
            }
            .frame(maxWidth: .infinity)

            Spacer()

            // Drop Zones //////////////////////////////////////////////////////


            VStack(alignment: .center, spacing: 20) {

                HStack() {
                    Image(systemName: "arrow.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14)
                    Text("Drop an **app** below")
                        .font(.title2).opacity(0.8)
                    Image(systemName: "arrow.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14)
                }


                HStack(spacing: 50) {
                    // Item 1 //////////////////////////////////////////////////////////////////////////

                    VStack {

                        DropTarget(delegate: DropQuarantine(appState: appState), types: dropTypes)
                            .frame(width: 200, height: 150)
                            .overlay(dropOverlayQuarantine, alignment: .center)
                            .opacity(0.8)

                        InfoButton(text: "If you download an unsigned app outside of the app store, it will be quarantined by macOS when trying to launch it and will prevent you from opening it. Dropping an app here will remove it from quarantine manually and let you launch it. \n\nDetails:\n- Removes quarantine flag\n- Skips transparency, consent and control checks\n- Quick workaround to bypass macOS protections without touching the code signature\n-In short, this skips Gatekeeper completely")

                    }
                    //                    .frame(width: 200, height: 150 )

                    // Item 2 //////////////////////////////////////////////////////////////////////////

                    VStack {

                        DropTarget(delegate: DropSign(appState: appState), types: dropTypes)
                            .frame(width: 200, height: 150)
                            .overlay(dropOverlaySign, alignment: .center)
                            .opacity(0.8)

                        InfoButton(text: "This signs the app with a self-signed certificate or a developer identity which can be set in Settings. You can also add the name of a notarization profile and it will sign/notarize the app with your own Apple Developer certificate. This is useful to make macOS recognize it as 'signed' or avoiding 'unnotarized' warnings. \n\nDetails:\n- Adds an ad-hoc signature or identity, marking the app internally as 'valid'\n- Might be needed for certain sandboxed or permission-sensitive tasks\n- Makes the app appear 'signed' to macOS, but still not trusted/notarized unless you also use your notarization profile\n- In short, this makes Gatekeeper see the app as signed")

                    }
                    //                    .frame(width: 200, height: 150 )
                }
            }



            // GK STATUS //////////////////////////////////////////////////////

            Spacer()

            GroupBox {
                HStack(spacing: 10) {
                    Text("If you want to fully disable Gatekeeper and not have to unquarantine unsigned apps manually each time, you can disable it system-wide here. This is not generally recommended for most users, but may be useful for more advanced cases.")
                        .frame(maxWidth: .infinity)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Toggle("", isOn: $appState.isGatekeeperEnabled)
                        .toggleStyle(RedGreenShield())
                        .frame(width: 80, height: 45)
                        .onChange(of: appState.isGatekeeperEnabled) { isEnabled in
                            guard appState.hasInitializedGatekeeperState else {
                                printOS("Skipping gatekeeper state check since gatekeeper state hasn't been initialized yet")
                                return
                            }
                            setGatekeeperState(enabled: isEnabled, appState: appState)
                        }
                        .onAppear {
                            //                            updateGatekeeperUI(appState: appState)
                        }
//                    Button {
//                        updateGatekeeperUI(appState: appState)
//                    } label: {
//                        Image(systemName: "arrow.counterclockwise")
//                            .font(.body)
//                    }
//                    .buttonStyle(.borderless)
//                    .help("Refresh gatekeeper status")
                }
                .padding()

//                Text("G: \(appState.isGatekeeperEnabled), S: \(appState.isGatekeeperEnabledState), I: \(appState.hasInitializedGatekeeperState)")
            }


            Spacer()


            HStack(alignment: .center){
                if appState.isLoading {
                    ProgressView().controlSize(.small)
                }
                Text(appState.status)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(height: 20)
            }
            .padding(.top)

        }
        .padding()
        .edgesIgnoringSafeArea(.all)
        .frame(width: 650, height: 550)

    }


    @ViewBuilder private var dropOverlayQuarantine: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Allow unsigned app to launch")
                .foregroundColor(.secondary)
                .font(.callout)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder private var dropOverlaySign: some View {
        VStack(alignment: .center, spacing: 20) {
            Text(selectedIdentity == "None" ? "Sign app with: Ad-Hoc" : "Sign app with: \(selectedIdentity)")
                .foregroundColor(.secondary)
                .font(.callout)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .help(selectedIdentity)
        }
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
                updateOnMain {
                    appState.status = "Attempting to remove app from quarantine"
                    appState.isLoading = true
                }
                Task
                {
                    _ = await CmdRunDrop(cmd: "xattr -rd com.apple.quarantine", path: url.path, type: .quarantine, appState: appState)
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
                updateOnMain {
                    appState.status = "Attempting to self-sign the app"
                    appState.isLoading = true
                }
                Task {
                    let identity = UserDefaults.standard.string(forKey: "sentinel.general.codesignIdentity") ?? "None"
                    let signCmd = identity == "None"
                    ? "codesign -f -s - --deep"
                    : "codesign -f -s '\(identity)' --deep --options runtime"

                    if identity != "None" {
                        _ = await CmdRunDrop(cmd: signCmd, path: url.path, type: .signDev, sudo: true, appState: appState)
                    } else {
                        _ = await CmdRunDrop(cmd: signCmd, path: url.path, type: .signAH, appState: appState)
                    }


                }

            }
        }

        return true
    }
}
