//
//  Dashboardv2.swift
//  Sentinel
//
//  Created by Alin Lupascu on 4/19/25.
//

import SwiftUI
import UniformTypeIdentifiers
import AlinFoundation

private let dropTypes = [UTType.fileURL]

struct Dashboardv2: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var updater: Updater
    @AppStorage("sentinel.general.codesignIdentity") private var selectedIdentity = "None"

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            // LOGO - TITLEBAR //////////////////////////////////////////////////////
            HStack(alignment: .center, spacing: 0) {

                if updater.updateAvailable {
                    UpdateBadge(updater: updater, hideLabel: true)
                } else {
                    Text("Sentinel")
                        .font(.title)
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
            //Main content container
            VStack(alignment: .center, spacing: 20) {

                HStack {
                    ZStack {
                        GridTemplateView(delegate: DropQuarantine(appState: appState), types: dropTypes, quarantine: true)

                        VStack {
                            Spacer()
                            Text(appState.quarantineAppName ?? "")
                                .font(.caption)
                                .lineLimit(1)
                                .offset(y: 16) // adjust this value as needed
                        }
                        .frame(width: 80)
                    }
                    .padding(.trailing, 32)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Remove an app from quarantine and allow the unsigned app to launch.")
                            .font(.system(size: 17))
                            .foregroundStyle(.secondary)
                            .bold()
                            .fixedSize(horizontal: false, vertical: true)

                        let quarantineText = """
                                    When trying to launch an unsigned app you downloaded outside of the App Store, it will be quarantined by macOS, preventing you from opening it. Drop the app here to remove it from quarantine to allow it to launch.  This is a quick way to bypass macOS protections without dealing with the code signatures.  
                                    """
                        LearnMorePopover(text: quarantineText, prominentText: "Removes quarantine flag. Skips transparency, consent, and control checks.")

                    }
                    Spacer()
                }
                .padding(32)
                .background(DropBG())

                HStack {
                    ZStack {
                        GridTemplateView(delegate: DropSign(appState: appState), types: dropTypes, quarantine: false)

                        VStack {
                            Spacer()
                            Text(appState.signAppName ?? "")
                                .font(.caption)
                                .lineLimit(1)
                                .offset(y: 16) // adjust this value as needed
                        }
                        .frame(width: 80)
                    }
                    .padding(.trailing, 32)

                    VStack(alignment: .leading) {
                        Text("Sign app with ad-hoc or developer identity\nto avoid notarization warnings.")
                            .font(.system(size: 17))
                            .foregroundStyle(.secondary)
                            .bold()
                            .fixedSize(horizontal: false, vertical: true)

                        HStack {
                            Button("Select Signing Identity"){
                                openAppSettings()
                            }
                            Text(selectedIdentity == "None" ? "Ad-Hoc" : "\(selectedIdentity)")
                                .foregroundStyle(.primary.opacity(0.8))
                                .font(.caption)
                        }

                        let signText = """
                                    Useful for certain sandboxed or permission-sensitive tasks. Makes macOS recognise app as 'signed', avoiding 'Not Notarized' warnings. App will be signed with a self-signed certificate or a developer identity of choice. You can also add the name of a notarization profile in Settings, and it will sign/notarize the app with your own Apple Developer certificate.  
                                    """
                        LearnMorePopover(text: signText, prominentText: "Makes Gatekeeper see the app as signed.")

                    }
                    Spacer()
                }
                .padding(32)
                .background(DropBG())


                // GK STATUS //////////////////////////////////////////////////////

                HStack(spacing: 10  ) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Danger Zone").textCase(.uppercase)
                            .foregroundStyle(Color(red: 255/255, green: 59/255, blue: 48/255, opacity: 0.76))
                            .font(.system(size: 15))
                            .bold()

                        Text("Disable system-wide Gatekeeper protection")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16))
                            .bold()

                        Text("Use this as a last resort if the above options are not helping or you want to avoid un-quarantining apps every time.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.primary)
                    }

                    Spacer()

                    VStack(spacing: 8) {
                        Text("Gatekeeper \(appState.isGatekeeperEnabled ? "Enabled" : "Disabled")").textCase(.uppercase)
                            .foregroundStyle(appState.isGatekeeperEnabled ? Color.secondary.opacity(0.8) : Color(red: 255/255, green: 65/255, blue: 105/255, opacity: 1))
                            .font(.system(size: 10))
                            .bold()
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
                        Text("\(appState.isGatekeeperEnabled ? "Secure" : "Insecure")").textCase(.uppercase)
                            .foregroundStyle(appState.isGatekeeperEnabled ? Color(red: 1/255, green: 99/255, blue: 16/255, opacity: 1) : Color(red: 255/255, green: 59/255, blue: 48/255, opacity: 1))
                            .font(.system(size: 12))
                            .bold()
                    }


                }
                .padding(32)
                .frame(height: 150)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(appState.isGatekeeperEnabled ? Color(nsColor: .textBackgroundColor).opacity(0.8) : Color(red: 255/255, green: 69/255, blue: 58/255, opacity: 0.06))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(appState.isGatekeeperEnabled ? Color.secondary.opacity(0.5) : Color(red: 255/255, green: 69/255, blue: 58/255, opacity: 1), style: StrokeStyle(lineWidth: 1.5, dash: [8, 4], dashPhase: 0))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                )

            }

            Spacer()

            // Status Bar
            HStack(alignment: .center, spacing: 4) {
                Spacer()
                if appState.isLoading  {
                    ProgressView()
                        .controlSize(.small)
                        .scaleEffect(0.7)
                }
                Text(appState.status)
                    .font(.system(size: 12))
                Spacer()
            }
            .padding(.vertical, 5)
            .foregroundStyle(.secondary)
            .font(.footnote)
            .frame(height: 24)
            .frame(maxWidth: .infinity, idealHeight: 32)

        }
        .padding()
        .edgesIgnoringSafeArea(.all)
        .frame(width: 700, height: 630)
    }
}

#Preview {
    Dashboardv2()
        .environmentObject(AppState())
        .environmentObject(Updater(owner: "alienator88", repo: "Sentinel"))
        .frame(width: 700, height: 650)
}
