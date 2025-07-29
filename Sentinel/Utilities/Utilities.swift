//
//  Utilities.swift
//  Sentinel
//
//  Created by Alin Lupascu on 7/28/25.
//

import Foundation


func manageFinderPlugin(install: Bool) {
    let task = Process()
    task.launchPath = "/usr/bin/pluginkit"

    task.arguments = ["-e", "\(install ? "use" : "ignore")", "-i", "com.alienator88.Sentinel"]

    task.launch()
    task.waitUntilExit()
}
