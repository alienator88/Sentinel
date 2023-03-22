//
//  TerminalOutput.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import Foundation

struct TerminalOutput
{
    var standardOutput: String
    var standardError: String
}

enum StreamedTerminalOutput
{
    case standardOutput(String)
    case standardError(String)
}
