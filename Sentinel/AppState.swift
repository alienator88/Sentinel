//
//  AppState.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import Foundation
import SwiftUI
import FinderSync

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var isGatekeeperEnabled: Bool = true
    @Published var isGatekeeperEnabledState: Bool = true
    @Published var hasInitializedGatekeeperState = false
    @Published var status: String = ""
    @Published var isLoading: Bool = false
    @Published var multiDrop: Bool = false
    @Published var availableIdentities: [String] = []
    @Published var finderExtensionEnabled: Bool = false
    @Published var doneQuarantine: Bool = false
    @Published var doneSign: Bool = false


    init() {
        updateExtensionStatus()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateExtensionStatus),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc func updateExtensionStatus() {
        let extensionStatus = FIFinderSyncController.isExtensionEnabled
        DispatchQueue.main.async {
            self.finderExtensionEnabled = extensionStatus
        }
    }


}


enum CurrentTabView:Int
{
    case general
    case update
    case about

    var title: String {
        switch self {
        case .general: return "General"
        case .update: return "Update"
        case .about: return "About"
        }
    }
}

enum cmdType {
    case quarantine
    case signAH
    case signDev
}

enum gkType {
    case enable
    case disable
}
