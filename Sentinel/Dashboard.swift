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
                                colors: [.pink, .purple, .blue],
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

                        //                        InfoButton(text: "If you download an unsigned app outside of the app store, it will be quarantined by macOS when trying to launch it and will prevent you from opening it. Dropping an app here will remove it from quarantine manually and let you launch it. \n\nDetails:\n- Removes quarantine flag\n- Skips transparency, consent and control checks\n- Quick workaround to bypass macOS protections without touching the code signature\n-In short, this skips Gatekeeper completely for the dropped app")

                    }

                    // Item 2 //////////////////////////////////////////////////////////////////////////

                    VStack {

                        DropTarget(delegate: DropSign(appState: appState), types: dropTypes)
                            .frame(width: 200, height: 150)
                            .overlay(dropOverlaySign, alignment: .center)
                            .opacity(0.8)

                        //                        InfoButton(text: "This signs the app with a self-signed certificate or a developer identity which can be set in Settings. You can also add the name of a notarization profile and it will sign/notarize the app with your own Apple Developer certificate. This is useful to make macOS recognize it as 'signed' or avoiding 'unnotarized' warnings. \n\nDetails:\n- Adds an ad-hoc signature or identity, marking the app internally as 'valid'\n- Might be needed for certain sandboxed or permission-sensitive tasks\n- Makes the app appear 'signed' to macOS, but still not trusted/notarized unless you also use your notarization profile\n- In short, this makes Gatekeeper see the app as signed")


                    }
                }
            }



            // GK STATUS //////////////////////////////////////////////////////

            Spacer()

            GroupBox {
                HStack(spacing: 10) {
                    Text("If you prefer to fully disable Gatekeeper and not have to unquarantine unsigned apps manually each time, you can disable it system-wide here. This is not generally recommended for most users, but may be useful for more advanced cases.")
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
                }
                .padding()
            }
            .padding(.horizontal, 30)


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
        .frame(width: 550, height: 550)

    }


    @ViewBuilder private var dropOverlayQuarantine: some View {
        ZStack() {
            if appState.doneQuarantine {
                Image(systemName: "checkmark")
                    .foregroundStyle(.green)
                    .font(.system(size: 40))
            } else {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        InfoButton(text: "If you download an unsigned app outside of the app store, it will be quarantined by macOS when trying to launch it and will prevent you from opening it. Dropping an app here will remove it from quarantine manually and let you launch it. \n\nDetails:\n- Removes quarantine flag\n- Skips transparency, consent and control checks\n- Quick workaround to bypass macOS protections without touching the code signature\n-In short, this skips Gatekeeper completely for the dropped app").opacity(0.5)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.top, 6)
                .padding(.leading, 2)
                Text("Allow unsigned app to launch")
                    .foregroundColor(.primary)
                    .font(.callout)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
        }
    }

    @ViewBuilder private var dropOverlaySign: some View {
        ZStack() {
            if appState.doneSign {
                Image(systemName: "checkmark")
                    .foregroundStyle(.green)
                    .font(.system(size: 40))
            } else {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Spacer()
                        InfoButton(text: "This signs the app with a self-signed certificate or a developer identity which can be set in Settings. You can also add the name of a notarization profile and it will sign/notarize the app with your own Apple Developer certificate. This is useful to make macOS recognize it as 'signed' or avoiding 'unnotarized' warnings. \n\nDetails:\n- Adds an ad-hoc signature or identity, marking the app internally as 'valid'\n- Might be needed for certain sandboxed or permission-sensitive tasks\n- Makes the app appear 'signed' to macOS, but still not trusted/notarized unless you also use your notarization profile\n- In short, this makes Gatekeeper see the app as signed").opacity(0.5)
                    }
                    Spacer()
                }
                .padding(.top, 6)
                .padding(.trailing, 2)
                HStack(spacing: 0) {
                    Text(selectedIdentity == "None" ? "Sign app with: None" : "Sign app with: \(selectedIdentity)")
                        .foregroundColor(.primary)
                        .font(.callout)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .help(selectedIdentity)
                    Menu {
                        Text("Select a new signing identity")
                            .foregroundStyle(.secondary)
                            .disabled(true)
                        ForEach(AppState.shared.availableIdentities, id: \.self) { identity in
                            Button {
                                selectedIdentity = identity
                            } label: {
                                Text(identity)
                            }
                        }
                    } label: {

                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 10, height: 10)
                }
            }

        }
    }
}
