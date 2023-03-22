//
//  ScriptCmd.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import Foundation

enum ScriptError: Error
{
    case errorsThrownInStandardOutput
}

func OsaScript(source: String) async throws -> TerminalOutput
{
    
    async let commandResult = await shell("/usr/bin/osascript", ["-e", source])
    return await commandResult
    
}
