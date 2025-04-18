//
//  Shell.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import Foundation

func OsaScript(source: String) -> TerminalOutput
{

    var errorDict: NSDictionary? = nil
    let script = NSAppleScript(source: source)

    if let scriptOutput = script?.executeAndReturnError(&errorDict) {
        let output = scriptOutput.stringValue ?? ""
        return TerminalOutput(standardOutput: output, standardError: "")
    } else {
        let errorDescription = errorDict?.description ?? "Unknown error"
        return TerminalOutput(standardOutput: "", standardError: errorDescription)
    }

}


struct TerminalOutput
{
    var standardOutput: String
    var standardError: String
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
