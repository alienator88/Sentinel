//
//  CmdRunner.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import Foundation

//@MainActor
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
        }
        return false
    } else if result_enabled {
        updateOnMain {
            appState.isGatekeeperEnabled = true
            appState.isGatekeeperEnabledState = true
        }
        return true
    }

    return false

}

//@MainActor
func CmdRunSudo(cmd: String, type: String,  appState: AppState) {
    let source = """
                    set the_script to "sudo \(cmd)"
                    set the_result to do shell script the_script with prompt "Sentinel requires elevated privileges" with administrator privileges
                    return the_result
                    """
    Task {
        do{
            let result = OsaScript(source: source)
            let canceled = result.standardError.contains("canceled")
            
            switch type {
            case "enable":
                if canceled {
                    updateOnMain {
                        appState.status = "Gatekeeper enablement cancelled"
                    }
                    _ = await CmdRun(cmd: "spctl --status", appState: appState)
                } else {
                    updateOnMain {
                        appState.isGatekeeperEnabled = true
                        appState.isGatekeeperEnabledState = true
                        appState.status = "Gatekeeper has been enabled successfully"
                    }
                }
            case "disable":
                if canceled {
                    updateOnMain {
                        appState.status = "Gatekeeper disablement cancelled"
                    }
                    _ = await CmdRun(cmd: "spctl --status", appState: appState)
                } else {
                    updateOnMain {
                        appState.isGatekeeperEnabled = false
                        appState.isGatekeeperEnabledState = false
                        appState.status = "Gatekeeper has been disabled successfully"
                    }
                }

            case "profile":
                if canceled {
                    updateOnMain {
                        appState.status = "Profile removal cancelled"
                    }
                } else {
                    updateOnMain {
                        appState.isGatekeeperEnabled = true
                        appState.isGatekeeperEnabledState = true
                        appState.status = "Profile has been removed successfully"
                    }
                }

            default:
                print("")
            }
            
        }
    }
    
}


//@MainActor
func CmdRunDrop(cmd: String, type: String, appState: AppState) async {
    let source = """
                    set the_script to "\(cmd)"
                    set the_result to do shell script the_script
                    return the_result
                    """
    Task {
        do{
            _ = OsaScript(source: source)

            switch type {
            case "quarantine":
                updateOnMain {
                    appState.status = "App has been removed from quarantine"
                }
            case "sign":
                updateOnMain {
                    appState.status = "App has been self-signed"
                }
            default:
                print("")
            }
            
        }
    }
    
}


func updateOnMain(after delay: Double? = nil, _ updates: @escaping () -> Void) {
    if let delay = delay {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            updates()
        }
    } else {
        DispatchQueue.main.async {
            updates()
        }
    }
}
