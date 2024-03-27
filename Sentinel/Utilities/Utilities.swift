//
//  Utilities.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/26/24.
//

import Foundation
import AppKit
import OSLog

func printOS(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let message = items.map { "\($0)" }.joined(separator: separator)
    let log = OSLog(subsystem: "com.alienator88.sentinel", category: "Application")
    os_log("%@", log: log, type: .default, message)

}

// Check app directory based on user permission
func checkAppDirectoryAndUserRole(completion: @escaping ((isInCorrectDirectory: Bool, isAdmin: Bool)) -> Void) {
    isCurrentUserAdmin { isAdmin in
        let bundlePath = Bundle.main.bundlePath as NSString
        let applicationsDir = "/Applications"
        let userApplicationsDir = "\(NSHomeDirectory())/Applications"

        var isInCorrectDirectory = false

        if isAdmin {
            // Admins can have the app in either /Applications or ~/Applications
            isInCorrectDirectory = bundlePath.deletingLastPathComponent == applicationsDir ||
            bundlePath.deletingLastPathComponent == userApplicationsDir
        } else {
            // Standard users should only have the app in ~/Applications
            isInCorrectDirectory = bundlePath.deletingLastPathComponent == userApplicationsDir
        }

        // Return both conditions: if the app is in the correct directory and if the user is an admin
        completion((isInCorrectDirectory, isAdmin))
    }
}


// Check if user is admin or standard user
func isCurrentUserAdmin(completion: @escaping (Bool) -> Void) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/zsh") // Using zsh, macOS default shell
    process.arguments = ["-c", "groups $(whoami) | grep -q ' admin '"]

    process.terminationHandler = { process in
        // On macOS, a process's exit status of 0 indicates success (admin group found in this context)
        completion(process.terminationStatus == 0)
    }

    do {
        try process.run()
    } catch {
        print("Failed to execute command: \(error)")
        completion(false)
    }
}

// Relaunch app
func relaunchApp(afterDelay seconds: TimeInterval = 0.5) -> Never {
    let task = Process()
    task.launchPath = "/bin/sh"
    task.arguments = ["-c", "sleep \(seconds); open \"\(Bundle.main.bundlePath)\""]
    task.launch()

    NSApp.terminate(nil)
    exit(0)
}

func ensureApplicationSupportFolderExists(appState: AppState) {
    let fileManager = FileManager.default
    let supportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("\(Bundle.main.bundleIdentifier!)")

    // Check to make sure Application Support/Pearcleaner folder exists
    if !fileManager.fileExists(atPath: supportURL.path) {
        try! fileManager.createDirectory(at: supportURL, withIntermediateDirectories: true)
        printOS("Created Application Support/\(Bundle.main.bundleIdentifier!) folder")
    }
}

extension Int {
    var daysToSeconds: Double {
        return Double(self) * 24 * 60 * 60
    }
}
