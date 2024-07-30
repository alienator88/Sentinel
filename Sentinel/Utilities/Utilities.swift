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

func openFileAndSystemPreferences(filename: String, withExtension ext: String, appState: AppState) {
    if let fileURL = Bundle.main.url(forResource: filename, withExtension: ext) {
        let command = """
        open \(fileURL.path) && open x-apple.systempreferences:com.apple.Profiles-Settings.extension
        """
        if let output = runShellCommand(command) {
            print(output)
            updateOnMain {
                appState.isGatekeeperEnabled = false
                appState.isGatekeeperEnabledState = false
                appState.status = "Profile has been installed successfully"
            }
        }
    } else {
        print("File not found")
    }
}
