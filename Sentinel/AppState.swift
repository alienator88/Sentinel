//
//  AppState.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import Foundation

class AppState: ObservableObject {
    @Published var isGatekeeperEnabled: Bool = true
    @Published var isGatekeeperEnabledState: Bool = true
    @Published var status: String = ""



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
