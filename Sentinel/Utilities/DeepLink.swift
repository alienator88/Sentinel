//
//  DeepLink.swift
//  Sentinel
//
//  Created by Alin Lupascu on 7/28/25.
//

import Foundation
import AlinFoundation

func handleDeepLinkedApps(url: URL, appState: AppState) {
    // Case 1: Direct file URL (from Dock drop)
    if url.isFileURL {
        guard FileManager.default.fileExists(atPath: url.path) else {
            printOS("DLM: Direct file URL doesn't exist: \(url.path)")
            return
        }

        updateOnMain {
            appState.status = "Attempting to remove app from quarantine"
            appState.isLoading = true
        }
        Task {
            _ = await CmdRunDrop(cmd: "xattr -rd com.apple.quarantine", path: url.path, type: .quarantine, appState: appState)
        }
        return
    }

    // Case 2: URL scheme with query parameters (from deep link)
    if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
       let queryItems = components.queryItems {

        // Check for "path" query item first
        if let path = queryItems.first(where: { $0.name == "path" })?.value {
            let pathURL = URL(fileURLWithPath: path)
            guard FileManager.default.fileExists(atPath: pathURL.path) else {
                printOS("DLM: sent path doesn't exist: \(pathURL.path)")
                return
            }

            updateOnMain {
                appState.status = "Attempting to remove app from quarantine"
                appState.isLoading = true
            }
            Task
            {
                _ = await CmdRunDrop(cmd: "xattr -rd com.apple.quarantine", path: pathURL.path, type: .quarantine, appState: appState)
            }

        } else {
            printOS("DLM: No valid query items for 'path' found in the URL.")
        }
    } else {
        printOS("DLM: URL does not match expected format")
    }
}
