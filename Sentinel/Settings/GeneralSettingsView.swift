//
//  GeneralSettingsView.swift
//  Sentinel
//
//  Created by Alin Lupascu on 4/14/25.
//
import Foundation
import SwiftUI

struct GeneralSettingsTab: View {
    @AppStorage("sentinel.general.autoLaunch") private var autoLaunch = true
    @AppStorage("sentinel.general.codesignIdentity") private var selectedIdentity = "None"
    @AppStorage("sentinel.general.notaryProfile") private var notaryProfile = ""

    @State private var availableIdentities: [String] = ["None"]

    var body: some View {
        VStack {
            GroupBox {
                HStack {
                    Text("When you unquarantine an app, automatically launch it")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing)

                    Spacer()

                    Toggle("", isOn: $autoLaunch)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
                .padding()
            }

            GroupBox {
                VStack {
                    HStack() {
                        Text("Code Signing Identity")

                        Picker("", selection: $selectedIdentity) {
                            ForEach(availableIdentities, id: \.self) { identity in
                                Text(identity).tag(identity)
                            }
                        }
                        .pickerStyle(PopUpButtonPickerStyle())
                        .labelsHidden()

                    }
                    HStack {
                        TextField("Keychain notarization profile name", text: $notaryProfile)
                            .textFieldStyle(.roundedBorder)
                            .focusable(false)
                        Link("Docs",
                             destination: URL(string: "https://developer.apple.com/documentation/security/customizing-the-notarization-workflow#Upload-your-app-to-the-notarization-service")!)
                    }

                }

                .padding()
                .onAppear {
                    loadIdentities()
                }
            }

            Spacer()
        }
    }

    private func loadIdentities() {
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
                return String(parts[1])
            }
            DispatchQueue.main.async {
                availableIdentities = ["None"] + ids
            }
        }
    }
}
