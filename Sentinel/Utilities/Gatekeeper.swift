//
//  Gatekeeper.swift
//  Sentinel
//
//  Created by Alin Lupascu on 4/18/25.
//
import Foundation
import AlinFoundation
import AppKit

func CmdRunSudo(cmd: String, type: gkType, appState: AppState) {
    Task {
        // Perform privileged command synchronously
        let (success, output) = performPrivilegedCommands(commands: cmd)
        printOS("CmdRunSudo: privileged command returned success=\(success), output=\(output)")

        // Handle user cancelation
        if !success {
            await MainActor.run {
                appState.status = type == .enable
                ? "Gatekeeper enablement has been cancelled"
                : "Gatekeeper disablement has been cancelled"
            }
            // Re-sync UI to the actual Gatekeeper status
            updateGatekeeperUI(appState: appState)
            return
        }

        // On success, match original logic for macOS version and Settings alert
        if #available(macOS 14.0, *) {
            if type == .disable {
                // Open Privacy & Security > Security
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
                    NSWorkspace.shared.open(url)
                }
                await MainActor.run {
                    appState.status = "Please select the 'Anywhere' option in Privacy & Security > Security"
                    showCustomAlert(
                        title: "Attention",
                        message: """
                        On macOS 14.0 and up, Gatekeeper won't be fully disabled until you \
                        select 'Anywhere' in Privacy & Security > Security.\n\nThe settings \
                        window has been opened for you. Once you've made the change, click \
                        Task Completed.
                        """,
                        okText: "Task Completed",
                        style: .critical,
                        onOk: {
                            Task { updateGatekeeperUI(appState: appState) }
                        },
                        onCancel: {
                            Task { updateGatekeeperUI(appState: appState) }
                            appState.status = "Gatekeeper disablement has been cancelled"
                        }
                    )
                }
            } else {
                // Enable path
                updateGatekeeperUI(appState: appState)
            }
        } else {
            // Fallback for older macOS
            updateGatekeeperUI(appState: appState)
        }
    }
}


func updateGatekeeperUI(appState: AppState) {
    Task {
        // Get status without side effects
        let isEnabled = await getGatekeeperStatus()

        await MainActor.run {
            appState.hasInitializedGatekeeperState = false
            // Sync both the actual state and the UI toggle
            appState.isGatekeeperEnabledState = isEnabled
            appState.isGatekeeperEnabled = isEnabled
        }

        // Give SwiftUI a chance to process the toggle change before re-enabling
        try? await Task.sleep(nanoseconds: 1_000_000)

        await MainActor.run {
            appState.hasInitializedGatekeeperState = true
            appState.status = isEnabled ? "Gatekeeper is enabled" : "Gatekeeper is disabled"
        }
    }
}

func getGatekeeperStatus() async -> Bool {
    let out = runShCommand("spctl --status")
    let disabled = out.standardError.lowercased().contains("disabled")
    let enabled = out.standardOutput.lowercased().contains("enabled")
    return enabled && !disabled
}

func setGatekeeperState(enabled: Bool, appState: AppState) {
    let cmd = enabled ? "spctl --global-enable" : "spctl --global-disable"
    let type = enabled ? gkType.enable : gkType.disable

    updateOnMain {
        appState.status = "Attempting to turn \(enabled ? "on" : "off") gatekeeper, enter your admin password"
    }
    CmdRunSudo(cmd: cmd, type: type, appState: appState)
}
