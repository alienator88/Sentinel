//
//  DropDelegates.swift
//  Sentinel
//
//  Created by Alin Lupascu on 4/19/25.
//

import SwiftUI
import UniformTypeIdentifiers
import AlinFoundation


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
                    printOS("Error: Not a valid URL.")
                    return
                }
                let icon = NSWorkspace.shared.icon(forFile: url.path)
                let appName = url.deletingPathExtension().lastPathComponent



                updateOnMain {
                    appState.quarantineAppIcon = icon
                    appState.quarantineAppName = appName
                    appState.status = "Attempting to remove app from quarantine"
                    appState.quarantineUnlocked = false
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
                    printOS("Error: Not a valid URL.")
                    return
                }
                let icon = NSWorkspace.shared.icon(forFile: url.path)
                let appName = url.deletingPathExtension().lastPathComponent

                updateOnMain {
                    appState.signAppIcon = icon
                    appState.signAppName = appName
                    appState.status = "Attempting to self-sign the app"
                    appState.signUnlocked = false
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
