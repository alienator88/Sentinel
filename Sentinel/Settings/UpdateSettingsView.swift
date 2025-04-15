//
//  UpdateSettingsView.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/26/24.
//

import SwiftUI
import Foundation
import AlinFoundation

struct UpdateSettingsTab: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var updater: Updater

    var body: some View {
        VStack {

            FrequencyView(updater: updater)
                .padding(5)
                .padding(.horizontal)

            Divider()

            RecentReleasesView(updater: updater)
                .frame(height: 400)
                .frame(maxWidth: .infinity)
                .background(.background.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))


            HStack(alignment: .center, spacing: 20) {

                Button(""){
                    updater.checkForUpdates(sheet: false, force: false)
                }
                .buttonStyle(SimpleButtonStyle(icon: "list.bullet.rectangle.portrait", label: "Refresh", help: "Refresh updater", color: .primary))

                Button(""){
                    updater.checkForUpdates(sheet: true, force: true)
                }
                .buttonStyle(SimpleButtonStyle(icon: "arrow.counterclockwise", label: "Force Update", help: "Force update even if version is the same", color: .primary))


//                Button(""){
//                    updater.resetAnnouncementAlert()
//                }
//                .buttonStyle(SimpleButtonStyle(icon: "star", label: "Announcement", help: "Show announcements badge again", color: .primary))


                Button(""){
                    NSWorkspace.shared.open(URL(string: "https://github.com/alienator88/Sentinel/releases")!)
                }
                .buttonStyle(SimpleButtonStyle(icon: "link", label: "Releases", help: "View releases on GitHub", color: .primary))

            }
            .padding(.top, 5)

            Spacer()



        }
    }

}
