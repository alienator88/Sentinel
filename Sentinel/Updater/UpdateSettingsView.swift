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
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack {

            FrequencyView(updater: updater)
                .padding(5)
                .padding(.horizontal)

            ReleasesView(updater: updater)
                .frame(height: 400)
                .frame(maxWidth: .infinity)
                .background(.background.opacity(0.2))
//                .backgroundAF(opacity: 0.5)
                .clipShape(RoundedRectangle(cornerRadius: 8))


            HStack(alignment: .center, spacing: 20) {

                Button(""){
                    updater.checkForUpdates(showSheet: false)
                }
                .buttonStyle(SimpleButtonStyle(icon: "arrow.uturn.left.circle", label: "Refresh", help: "Refresh updater", color: .primary))


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
        .padding(20)
        .frame(width: 500, height: 520)
    }

}
