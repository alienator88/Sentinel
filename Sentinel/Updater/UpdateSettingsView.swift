//
//  UpdateSettingsView.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/26/24.
//

import SwiftUI
import Foundation

struct Release: Codable {
    let id: Int
    let tag_name: String
    let body: String
    let assets: [Asset]
}

struct Asset: Codable {
    let name: String
    let url: String
    let browser_download_url: String
}

extension Release {
    var modifiedBody: String {
        return body.replacingOccurrences(of: "- [x]", with: ">").replacingOccurrences(of: "###", with: "")
    }
}


struct UpdateSettingsTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {

            ScrollView {
                VStack() {
                    ForEach(appState.releases, id: \.id) { release in
                        VStack(alignment: .leading) {
                            LabeledDivider(label: "\(release.tag_name)")
                            Text(release.modifiedBody)
                        }

                    }
                }
                .padding()
            }
            .frame(minHeight: 0, maxHeight: .infinity)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()

            Text("Showing last 3 releases")
                .font(.callout)
                .foregroundStyle(.gray)



            HStack(alignment: .center, spacing: 20) {
                Spacer()

                Button(""){
                    loadGithubReleases(appState: appState)
                }
                .buttonStyle(SimpleButtonStyle(icon: "arrow.uturn.left.circle", help: "Reload release notes", color: Color("mode")))

                Spacer()

                Button(""){
                    loadGithubReleases(appState: appState, manual: true)
                }
                .buttonStyle(SimpleButtonStyle(icon: "arrow.down.square", help: "Check for updates", color: Color("mode")))

                Spacer()

                Button(""){
                    NSWorkspace.shared.open(URL(string: "https://github.com/alienator88/Sentinel/releases")!)
                }
                .buttonStyle(SimpleButtonStyle(icon: "link", help: "View releases on GitHub", color: Color("mode")))

                Spacer()
            }
            .padding()



        }
        .padding(20)
        .frame(width: 500, height: 520)
    }

}


func loadGithubReleases(appState: AppState, manual: Bool = false) {
    let url = URL(string: "https://api.github.com/repos/alienator88/Sentinel/releases")!
    let request = URLRequest(url: url)
    // Set the token for a private repo
    // request.setValue("token \(ghToken)", forHTTPHeaderField: "Authorization")
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let data = data {
            if let decodedResponse = try? JSONDecoder().decode([Release].self, from: data) {
                DispatchQueue.main.async {
                    let lastFewReleases = Array(decodedResponse.prefix(3)) // Get only the last 3 recent releases
                    appState.releases = lastFewReleases

                    checkForUpdate(appState: appState, manual: manual)

                }
                return
            }
        }
        printOS("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
    }.resume()
}

func checkForUpdate(appState: AppState, manual: Bool = false) {
    guard let latestRelease = appState.releases.first else { return }
    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    if latestRelease.tag_name > currentVersion ?? "" {
        NewWin.show(appState: appState, width: 500, height: 440, newWin: .update)
    } else {
        if manual {
            NewWin.show(appState: appState, width: 500, height: 300, newWin: .no_update)
        }
    }
}


func downloadUpdate(appState: AppState) {
    updateOnMain {
        appState.progressBar.0 = "Getting update file links ready"
        appState.progressBar.1 = 0.1
    }

    guard let latestRelease = appState.releases.first else { return }
    guard let asset = latestRelease.assets.first else { return }
    guard let url = URL(string: asset.url) else { return }
    var request = URLRequest(url: url)
    //    request.setValue("token \(ghToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/octet-stream", forHTTPHeaderField: "Accept")

    let downloadTask = URLSession.shared.downloadTask(with: request) { localURL, urlResponse, error in
        updateOnMain {
            appState.progressBar.0 = "Downloading update file"
            appState.progressBar.1 = 0.2
        }

        guard let localURL = localURL else { return }

        let fileManager = FileManager.default
        let destinationURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("\(Bundle.main.bundleIdentifier!)").appendingPathComponent("\(asset.name)")

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try? fileManager.removeItem(at: destinationURL)
            }
            updateOnMain {
                appState.progressBar.0 = "Moving update file to Application Support"
                appState.progressBar.1 = 0.4
            }

            try fileManager.moveItem(at: localURL, to: destinationURL)

            UnzipAndReplace(DownloadedFileURL: destinationURL.path, appState: appState)

            updateOnMain {
                appState.progressBar.0 = "Done, please restart!"
                appState.progressBar.1 = 1.0
            }


        } catch {
            printOS("Error moving downloaded file: \(error.localizedDescription)")
        }
    }

    downloadTask.resume()
}

func UnzipAndReplace(DownloadedFileURL fileURL: String, appState: AppState) {
    let appDirectory = Bundle.main.bundleURL.deletingLastPathComponent().path
    let appBundle = Bundle.main.bundleURL.path
    let fileManager = FileManager.default

    do {
        updateOnMain {
            appState.progressBar.0 = "Deleting existing application"
            appState.progressBar.1 = 0.5
        }

        // Remove the old version of your app
        try fileManager.removeItem(atPath: appBundle)

        updateOnMain {
            appState.progressBar.0 = "Unziping new update file to original Sentinel location"
            appState.progressBar.1 = 0.6
        }


        // Unzip the downloaded update file to your app's bundle path
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        process.arguments = ["-xk", fileURL, appDirectory]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        try process.run()
        process.waitUntilExit()

        updateOnMain {
            appState.progressBar.0 = "Deleting update file"
            appState.progressBar.1 = 0.8
        }

        // After unzipping, remove the update file
        try fileManager.removeItem(atPath: fileURL)


    } catch {
        printOS("Error updating the app: \(error)")
    }

}

