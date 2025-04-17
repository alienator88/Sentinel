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

func CmdRun(cmd: String, appState: AppState) async -> Bool {
    let source = """
                    set the_script to "\(cmd)"
                    set the_result to do shell script the_script
                    return the_result
                    """
    let out = OsaScript(source: source)

    /// spctl --status returns gatekeeper assessments enabled status in the standard output, while the disabled status is returned in the standard error
    let result_disabled = out.standardError.contains("disabled")
    let result_enabled = out.standardOutput.contains("enabled")

    if result_disabled {
        updateOnMain {
            appState.isGatekeeperEnabled = false
            appState.isGatekeeperEnabledState = false
            appState.status = "Gatekeeper is disabled"
        }
        return false
    } else if result_enabled {
        updateOnMain {
            appState.isGatekeeperEnabled = true
            appState.isGatekeeperEnabledState = true
            appState.status = "Gatekeeper is enabled"
        }
        return true
    }

    return false

}

func CmdRunSudo(cmd: String, type: String,  appState: AppState) {
    let source = """
                    set the_script to "sudo \(cmd)"
                    set the_result to do shell script the_script with prompt "Sentinel requires elevated privileges" with administrator privileges
                    return the_result
                    """
    Task {
        do {
            let result = OsaScript(source: source)
            let canceled = result.standardError.contains("canceled")

            if canceled {
                updateOnMain {
                    appState.status = type == "enable" ? "Gatekeeper enablement has been cancelled" : "Gatekeeper disablement has been cancelled"
                }
            }

            // Refresh status manually on Sequoia
            if type == "disable" {
                if #available(macOS 13.0, *) {
                    if !canceled {
                        updateOnMain {
                            showCustomAlert(title: "Attention", message: "On macOS 14.0 and up, Gatekeeper won't be fully disabled until you choose 'Anywhere' option in the Privacy & Security settings page under Security section. Click Okay to open the settings page now.", style: .critical, onOk: {
                                // Open the Privacy & Security settings page
                                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
                                    NSWorkspace.shared.open(url)
                                }
                                appState.isGatekeeperEnabled = false
                                appState.isGatekeeperEnabledState = false
                                appState.status = "Please select the 'Anywhere' option in the Privacy & Security > Security settings"
                            })
                        }
                    }
                } else {
                    // Refresh status via CLI on anything below Sequoia
                    getGatekeeperState(appState: appState)
                }
            } else {
                // Refresh status via CLI if enable command
                getGatekeeperState(appState: appState)
            }

        }
    }

}


func getGatekeeperState(appState: AppState) {
    Task{
        _ = await CmdRun(cmd: "spctl --status", appState: appState)
    }
}

func CmdRunDrop(cmd: String, path: String, type: cmdType, sudo: Bool = false, appState: AppState) async {
    @AppStorage("sentinel.general.autoLaunch") var autoLaunch = true
    @AppStorage("sentinel.general.notaryProfile") var notaryProfile = ""

    let fullCMD: String
    if type == .signDev {
        fullCMD = "xattr -cr '\(path)' && \(cmd) '\(path)'"
    } else {
        fullCMD = "\(cmd) '\(path)'"
    }
    let source = """
                    set the_script to "\(fullCMD)"
                    set the_result to do shell script the_script
                    return the_result
                    """
    let sourceSudo: String
    if type == .signDev {
        // Run xattr with sudo, then codesign without
        let sourceXattr = "xattr -cr '\(path)'"
        let sourceSign = "\(cmd) '\(path)'"
        sourceSudo = """
        set the_script to "\(sourceXattr)"
        set the_result to do shell script the_script with prompt "Sentinel requires elevated privileges" with administrator privileges
        set the_script2 to "\(sourceSign)"
        set the_result2 to do shell script the_script2
        return the_result2
        """
    } else {
        sourceSudo = """
        set the_script to "\(fullCMD)"
        set the_result to do shell script the_script with prompt "Sentinel requires elevated privileges" with administrator privileges
        return the_result
        """
    }

    Task {
        do{
            let out = OsaScript(source: sudo ? sourceSudo : source)

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
                    //                    updateOnMain {
                    //                        appState.status = "App has been successfully signed with development identity"
                    //                    }
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
    // Adjust command to check for quarantine attribute, e.g., `xattr`
    let checkCmd = "xattr -p com.apple.quarantine '\(path)'"
    let source = """
                    set the_script to "\(checkCmd)"
                    set the_result to do shell script the_script
                    return the_result
                    """
    let out = OsaScript(source: source)
    return !out.standardOutput.contains("com.apple.quarantine")
}

func checkAppSigned(path: String) async -> Bool {
    // Adjust the command to extract the path from the original command if necessary
    //    let path = extractPathFromCmd(cmd)
    //    print(path)
    let checkCmd = "codesign -v '\(path)'"
    let source = """
                    set the_script to "\(checkCmd)"
                    set the_result to do shell script the_script
                    return the_result
                    """
    let out = OsaScript(source: source)
    return out.standardError.isEmpty // If there's no error, the app is correctly signed
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



func runShCommand(_ command: String) -> TerminalOutput {
    let process = Process()
    let stdout = Pipe()
    let sterr = Pipe()

    process.standardOutput = stdout
    process.standardError = sterr
    process.arguments = ["-c", command]
    process.launchPath = "/bin/zsh"

    process.launch()
    process.waitUntilExit()

    let dataOut = stdout.fileHandleForReading.readDataToEndOfFile()
    let dataErr = sterr.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: dataOut, encoding: .utf8) ?? ""
    let error = String(data: dataErr, encoding: .utf8) ?? ""

    return TerminalOutput(standardOutput: output, standardError: error)
}
