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
