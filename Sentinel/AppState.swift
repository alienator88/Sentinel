//
//  AppState.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var isGatekeeperEnabled: Bool = true
    @Published var isGatekeeperEnabledState: Bool = true
    @Published var hasInitializedGatekeeperState = false
    @Published var status: String = ""
    @Published var isLoading: Bool = false

    @Published var quarantineAppName: String? = nil
    @Published var quarantineAppIcon: NSImage? = nil
    @Published var quarantineUnlocked: Bool = false

    @Published var signAppName: String? = nil
    @Published var signAppIcon: NSImage? = nil
    @Published var signUnlocked: Bool = false

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
