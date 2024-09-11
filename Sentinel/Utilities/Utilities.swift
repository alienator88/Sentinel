//
//  Utilities.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/26/24.
//

import Foundation


func runShellCommand(_ command: String) -> String? {
    let process = Process()
    let pipe = Pipe()

    process.standardOutput = pipe
    process.standardError = pipe
    process.arguments = ["-c", command]
    process.launchPath = "/bin/bash"

    process.launch()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)

    return output
}

func openFileAndSystemPreferences(filename: String, withExtension ext: String, disable: Bool, appState: AppState) {
    if let fileURL = Bundle.main.url(forResource: filename, withExtension: ext) {
        let command = """
        open \(fileURL.path) && open x-apple.systempreferences:com.apple.Profiles-Settings.extension
        """
        if let _ = runShellCommand(command) {
            updateOnMain {
                appState.isGatekeeperEnabled = disable ? false : true
                appState.isGatekeeperEnabledState = disable ? false : true
                appState.status = disable ? "Gatekeeper disable profile has been added" : "Gatekeeper enable profile has been added"
            }
        }
    } else {
        print("File not found")
    }
}
