//
//  GeneralSettingsView.swift
//  Sentinel
//
//  Created by Alin Lupascu on 4/14/25.
//
import Foundation
import SwiftUI
import AlinFoundation
import FinderSync

struct GeneralSettingsTab: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("sentinel.general.autoLaunch") private var autoLaunch = true
    @AppStorage("sentinel.general.devCerts") private var showDevCerts = false
    @AppStorage("sentinel.general.codesignIdentity") private var selectedIdentity = "None"
    @AppStorage("sentinel.general.notaryProfile") private var notaryProfile = ""

    var body: some View {
        VStack {
            GroupBox {
                HStack {
                    VStack {
                        Text("When you unquarantine an app, automatically launch it")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.trailing)
                        Text("This only executes when 1 app is dropped")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .padding(.trailing)
                    }


                    Spacer()

                    Toggle("", isOn: $autoLaunch)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
                .padding()
            }

            GroupBox {
                HStack {
                    HStack(spacing: 0) {
                        Text("Enable context menu extension for Finder")
                            .font(.callout)
                            .foregroundStyle(.primary)

                        InfoButton(text: String(localized: "Enabling this extension will allow you to right click apps in Finder to quickly unquarantine them with Sentinel\n\nSometimes macOS only enables extensions if the main app is in the Applications folder"))
                        Button {
                            FIFinderSyncController.showExtensionManagementInterface()
                        } label: {
                            Image(systemName: "gear")
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 5)
                        Spacer()
                    }




                    Spacer()

                    Toggle(isOn: $appState.finderExtensionEnabled, label: {
                    })
                    .toggleStyle(.switch)
                    .onChange(of: appState.finderExtensionEnabled) { newValue in
                        if newValue {
                            manageFinderPlugin(install: true)
                        } else {
                            manageFinderPlugin(install: false)
                        }
                    }
                }
                .padding()


            }

            GroupBox {
                VStack(spacing: 10) {
                    HStack {
                        HStack(spacing: 0) {
                            Text("Show Apple Development certificates")
                            InfoButton(text: String(localized: "You cannot notarize apps with Apple Development certificates, using these will fail as they are normally used for local development only and they do not allow notarizing.\n\nIt's recommended to select None or a Developer ID Application certificate if you have one."))
                            Spacer()
                        }

                        Spacer()

                        Toggle("", isOn: $showDevCerts)
                            .onChange(of: showDevCerts) { newValue in
                                appState.availableIdentities = loadIdentities()
                            }
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }
                    HStack() {
                        Text("Code signing identity")
                        Spacer()
                        Picker("", selection: $selectedIdentity) {
                            ForEach(appState.availableIdentities, id: \.self) { identity in
                                Text(identity).tag(identity)
                            }
                        }
                        .pickerStyle(PopUpButtonPickerStyle())
                        .labelsHidden()
                        .frame(width: 250)
                        .onAppear {
                            appState.availableIdentities = loadIdentities()
                        }

                    }

                    HStack(spacing: 0) {
                        Text("Notarization profile")
                        InfoButton(text: "If you'd like to learn how to notarize an application using a notarization profile, view the Apple documentation below.", extraView: {
                            Link(destination: URL(string: "https://developer.apple.com/documentation/security/customizing-the-notarization-workflow#Upload-your-app-to-the-notarization-service")!, label: {
                                Text("Open")
                            })
                        })


                        Spacer()
                        TextField("Keychain notarization profile name", text: $notaryProfile)
                            .textFieldStyle(.roundedBorder)
                            .focusable(false)
                            .frame(width: 250)
                    }

                }
                .padding()
            }



            Spacer()
        }
    }


}

func loadIdentities() -> [String] {
    @AppStorage("sentinel.general.devCerts") var showDevCerts = false

    let task = Process()
    task.launchPath = "/usr/bin/security"
    task.arguments = ["find-identity", "-p", "codesigning", "-v"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        let lines = output.split(separator: "\n")
        let ids = lines.compactMap { line -> String? in
            let parts = line.split(separator: "\"")
            guard parts.count >= 2 else { return nil }
            let identity = String(parts[1])
            if !showDevCerts && identity.starts(with: "Apple Development") {
                return nil
            }
            return identity
        }
        return ["None"] + ids
    }
    return ["None"]
}
