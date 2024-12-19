//
//  CmdRunner.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import Foundation
import AlinFoundation
import AppKit

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
                if #available(macOS 15.0, *) {
                    updateOnMain {
                        showCustomAlert(title: "Attention", message: "On macOS Sequoia or higher, Gatekeeper won't be fully disabled until you choose the 'Anywhere' option in the Privacy & Security settings page under Security section. Click Okay to open the settings page now.", style: .critical, onOk: {
                            // Open the Privacy & Security settings page
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
                                NSWorkspace.shared.open(url)
                            }
                            appState.isGatekeeperEnabled = false
                            appState.isGatekeeperEnabledState = false
                            appState.status = "Please select the 'Anywhere' option in the Privacy & Security > Security settings"
                        })
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

func CmdRunDrop(cmd: String, type: String, sudo: Bool = false, appState: AppState) async {
    let source = """
                    set the_script to "\(cmd)"
                    set the_result to do shell script the_script
                    return the_result
                    """
    let sourceSudo = """
                    set the_script to "\(cmd)"
                    set the_result to do shell script the_script with prompt "Sentinel requires elevated privileges" with administrator privileges
                    return the_result
                    """
    Task {
        do{
            let out = OsaScript(source: sudo ? sourceSudo : source)

            switch type {
            case "quarantine":
                // Check if the quarantine attribute is removed
                let removed = await checkQuarantineRemoved(cmd: cmd)
                if removed {
                    updateOnMain {
                        appState.status = "App has been removed from quarantine"
                    }
                } else if !sudo { // Retry with sudo
                    printOS(out.standardError)
                    updateOnMain {
                        appState.status = "Retrying with elevated privileges"
                    }
                    _ = await CmdRunDrop(cmd: cmd, type: "quarantine", sudo: true, appState: appState)
                } else {
                    printOS(out.standardError)
                    updateOnMain {
                        appState.status = "Failed to remove app from quarantine"
                    }
                }

            case "sign":
                // Check if the app was self-signed successfully
                let signed = await checkAppSigned(cmd: cmd)
                if signed {
                    updateOnMain {
                        appState.status = "App has been successfully self-signed"
                    }
                } else if !sudo { // Retry with sudo
                    printOS(out.standardError)
                    updateOnMain {
                        appState.status = "Retrying with elevated privileges"
                    }
                    _ = await CmdRunDrop(cmd: cmd, type: "sign", sudo: true, appState: appState)
                } else {
                    printOS(out.standardError)
                    updateOnMain {
                        appState.status = "Failed to self-sign the app"
                    }
                }

            default:
                print("")
            }
            
        }
    }
    
}


func checkQuarantineRemoved(cmd: String) async -> Bool {
    // Adjust command to check for quarantine attribute, e.g., `xattr`
    let checkCmd = "xattr -p com.apple.quarantine \(cmd)"
    let source = """
                    set the_script to "\(checkCmd)"
                    set the_result to do shell script the_script
                    return the_result
                    """
    let out = OsaScript(source: source)
    return !out.standardOutput.contains("com.apple.quarantine")
}

func checkAppSigned(cmd: String) async -> Bool {
    // Adjust the command to extract the path from the original command if necessary
    let path = extractPathFromCmd(cmd)
    let checkCmd = "codesign -v \(path)"
    let source = """
                    set the_script to "\(checkCmd)"
                    set the_result to do shell script the_script
                    return the_result
                    """
    let out = OsaScript(source: source)
    return out.standardError.isEmpty // If there's no error, the app is correctly signed
}

func extractPathFromCmd(_ cmd: String) -> String {
    // Extract the path from the provided command (assumes path is the last argument)
    return cmd.components(separatedBy: " ").last ?? ""
}


func runShellCommand(_ command: String) -> TerminalOutput {
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
