//
//  CmdRunner.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import Foundation

@MainActor
func CmdRun(cmd: String, appState: AppState) async {
    let source = """
                    set the_script to "\(cmd)"
                    set the_result to do shell script the_script
                    return the_result
                    """
    Task {
        do{
            let out = try await OsaScript(source: source)
            
            /// spctl --status returns gatekeeper assessments enabled status in the standard output, while the disabled status is returned in the standard error
            let result_disabled = out.standardError.contains("disabled")
            let result_enabled = out.standardOutput.contains("enabled")
            
            if result_disabled {
                    appState.isGatekeeperEnabled = false
                } else if result_enabled {
                    appState.isGatekeeperEnabled = true
                }

        } catch let Error as NSError {
            print(Error)
        }
    }
    
}

@MainActor
func CmdRunSudo(cmd: String, type: String,  appState: AppState) async {
    let source = """
                    set the_script to "sudo \(cmd)"
                    set the_result to do shell script the_script with prompt "Sentinel requires elevated privileges" with administrator privileges
                    return the_result
                    """
    Task {
        do{
            let result = try await OsaScript(source: source)
            let canceled = result.standardError.contains("canceled")
            
            switch type {
            case "enable":
                if canceled {
                    appState.status = "Process cancelled"
                    _ = await CmdRun(cmd: "spctl --status", appState: appState)
                } else {
                    appState.isGatekeeperEnabled = true
                    appState.status = "Gatekeeper has been enabled successfully"
                    print("Gatekeeper Enabled")
                }
            case "disable":
                if canceled {
                    appState.status = "Process cancelled"
                    _ = await CmdRun(cmd: "spctl --status", appState: appState)
                } else {
                    appState.isGatekeeperEnabled = false
                    appState.status = "Gatekeeper has been disabled successfully"
                    print("Gatekeeper Disabled")
                }
                
            default:
                print("")
            }
            
        } catch let Error as NSError {
            print(Error)
        }
    }
    
}


@MainActor
func CmdRunDrop(cmd: String, type: String, appState: AppState) async {
    let source = """
                    set the_script to "sudo \(cmd)"
                    set the_result to do shell script the_script with prompt "Sentinel requires elevated privileges" with administrator privileges
                    return the_result
                    """
    Task {
        do{
            _ = try await OsaScript(source: source)
            
            switch type {
            case "quarantine":
                appState.status = "Removed app from quarantine"
                print("Removed app from quarantine")
            case "sign":
                appState.status = "App has been self-signed"
                print("Self-Signed the app")
            default:
                print("")
            }
            
        } catch let Error as NSError {
            print(Error)
        }
    }
    
}
