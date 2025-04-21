//
//  CmdRunner.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import Foundation
import AlinFoundation
import AppKit
import SwiftUI


// DROP ZONES =================================================================================================

func CmdRunDrop(cmd: String, path: String, type: cmdType, sudo: Bool = false, appState: AppState) async {
    @AppStorage("sentinel.general.autoLaunch") var autoLaunch = true
    @AppStorage("sentinel.general.notaryProfile") var notaryProfile = ""
    
    let fullCMD: String
    if type == .signDev {
        fullCMD = "xattr -cr '\(path)' && \(cmd) '\(path)'"
    } else {
        fullCMD = "\(cmd) '\(path)'"
    }
    
    Task {
        do {
            // Execute the command, using privileges if needed
            let out: TerminalOutput
            if sudo {
                let (success, output) = performPrivilegedCommands(commands: fullCMD)
                out = TerminalOutput(
                    standardOutput: success ? output : "",
                    standardError: success ? "" : output
                )
            } else {
                out = runShCommand(fullCMD)
            }
            
            switch type {
            case .quarantine:
                // Check if the quarantine attribute is removed
                let removed = await checkQuarantineRemoved(path: path)
                if removed {
                    updateOnMain {
                        appState.status = "App has been removed from quarantine"
                    }
                    if autoLaunch {
                        NSWorkspace.shared.open(URL(fileURLWithPath: path))
                    }
                } else if !sudo { // Retry with sudo
                    printOS(out.standardError)
                    updateOnMain {
                        appState.status = "Retrying with elevated privileges"
                    }
                    _ = await CmdRunDrop(cmd: cmd, path: path, type: .quarantine, sudo: true, appState: appState)
                } else {
                    printOS(out.standardError)
                    updateOnMain {
                        appState.status = "Failed to remove app from quarantine"
                    }
                }
                
            case .signAH:
                // Check if the app was self-signed successfully
                let signed = await checkAppSigned(path: path)
                
                if signed {
                    updateOnMain {
                        appState.status = "App has been successfully self-signed"
                    }
                } else if !sudo { // Retry with sudo
                    printOS(out.standardError)
                    updateOnMain {
                        appState.status = "Retrying with elevated privileges"
                    }
                    _ = await CmdRunDrop(cmd: cmd, path: path, type: .signAH, sudo: true, appState: appState)
                } else {
                    printOS(out.standardError)
                    updateOnMain {
                        appState.status = "Failed to self-sign the app"
                    }
                }
                
            case .signDev:
                // Check if the app was signed with dev identity successfully
                let signed = await checkAppSigned(path: path)
                
                if signed {
                    if !notaryProfile.isEmpty {
                        updateOnMain {
                            appState.status = "App is being notarized.."
                        }
                        notarizeApp(path: path, profile: notaryProfile, appState: appState)
                    } else {
                        updateOnMain {
                            appState.status = "App has been successfully signed with development identity"
                        }
                    }
                } else if !sudo { // Retry with sudo
                    printOS(out.standardError)
                    updateOnMain {
                        appState.status = "Retrying with elevated privileges"
                    }
                    _ = await CmdRunDrop(cmd: cmd, path: path, type: .signDev, sudo: true, appState: appState)
                } else {
                    printOS(out.standardError)
                    updateOnMain {
                        appState.status = "Failed to sign the app with development identity"
                    }
                }
            }
            
            updateOnMain {
                appState.isLoading = false
            }
        }
    }
    
}


func checkQuarantineRemoved(path: String) async -> Bool {
    let out = runShCommand("xattr -p com.apple.quarantine '\(path)'")
    return out.standardOutput.isEmpty
}

func checkAppSigned(path: String) async -> Bool {
    let out = runShCommand("codesign -v '\(path)'")
    return out.standardError.isEmpty
}


func notarizeApp(path: String, profile: String, appState: AppState) {
    let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let zipDir = appSupport.appendingPathComponent(Bundle.main.name)
    let zipPath = zipDir.appendingPathComponent((path as NSString).lastPathComponent + ".zip").path
    
    // Step 1: Zip the app
    let zipCmd = "ditto -c -k --keepParent '\(path)' '\(zipPath)'"
    let zipResult = runShCommand(zipCmd)
    printOS(zipResult.standardOutput)
    printOS(zipResult.standardError)
    if !zipResult.standardError.isEmpty {
        updateOnMain {
            appState.status = "Notarization zipping failed, check Debug console for more info (CMD+D)"
        }
    }
    
    // Step 2: Submit to notarytool
    let notaryCmd = "xcrun notarytool submit '\(zipPath)' --keychain-profile \"\(profile)\" --wait"
    let notaryResult = runShCommand(notaryCmd)
    printOS(notaryResult.standardOutput)
    printOS(notaryResult.standardError)
    if !notaryResult.standardError.isEmpty {
        updateOnMain {
            appState.status = "Notarization failed, check Debug console for more info (CMD+D)"
        }
    }
    
    
    // Step 3: Staple the ticket
    let stapleCmd = "xcrun stapler staple '\(path)'"
    let stapleResult = runShCommand(stapleCmd)
    printOS(stapleResult.standardOutput)
    printOS(stapleResult.standardError)
    if !stapleResult.standardError.isEmpty {
        updateOnMain {
            appState.status = "Notarization staple failed, check Debug console for more info (CMD+D)"
        }
    }
    
    // Step 4: Remove zip
    do {
        if FileManager.default.fileExists(atPath: zipPath) {
            try FileManager.default.removeItem(atPath: zipPath)
        }
    } catch {
        printOS("Failed to remove zip file at path \(zipPath): \(error)")
    }
    
    updateOnMain {
        appState.status = "App has been signed and notarized successfully"
    }
}
