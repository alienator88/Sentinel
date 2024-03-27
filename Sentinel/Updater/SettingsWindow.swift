//
//  SettingsWindow.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/26/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {

        TabView() {
//            GeneralSettingsTab(showPopover: $showPopover, search: $search)
//                .tabItem {
//                    Label(CurrentTabView.general.title, systemImage: "gear")
//                }
//                .tag(CurrentTabView.general)

            UpdateSettingsTab()
                .tabItem {
                    Label(CurrentTabView.update.title, systemImage: "cloud")
                }
                .tag(CurrentTabView.update)

            AboutView(
                icon: NSApp.applicationIconImage ?? NSImage(),
                name: Bundle.main.name,
                version: Bundle.main.version,
                build: Bundle.main.buildVersion,
                developerName: "Alin Lupascu")
                .tabItem {
                    Label(CurrentTabView.about.title, systemImage: "info.circle")
                }
                .tag(CurrentTabView.about)

        }

    }

}
