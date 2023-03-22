//
//  AppState.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/21/23.
//

import Foundation

class AppState: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var isGatekeeperEnabled: Bool = true
    @Published var status: String = "Ready"

}
