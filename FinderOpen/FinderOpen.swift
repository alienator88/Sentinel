//
//  FinderOpen.swift
//  FinderOpen
//
//  Created by Alin Lupascu on 7/28/25.
//

import Cocoa
import FinderSync

class FinderOpen: FIFinderSync {
    
    private var directoriesToWatch: Set<URL> = []

    override init() {
        super.init()
        NSLog("FinderSync() launched from %@", Bundle.main.bundlePath as NSString)
        
        // Set up initial directory URLs including all mounted volumes
        updateWatchedDirectories()
        
        // Register for volume mount/unmount notifications
        setupVolumeMonitoring()
    }
    
    private func updateWatchedDirectories() {
        directoriesToWatch = [URL(fileURLWithPath: "/")]
        
        // Add all currently mounted volumes
        if let mountedVolumes = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: nil,
            options: [.skipHiddenVolumes]
        ) {
            for volume in mountedVolumes {
                directoriesToWatch.insert(volume)
            }
        }
        
        FIFinderSyncController.default().directoryURLs = directoriesToWatch
        NSLog("FinderSync watching directories: %@", directoriesToWatch.map { $0.path }.joined(separator: ", "))
    }
    
    private func setupVolumeMonitoring() {
        let notificationCenter = NSWorkspace.shared.notificationCenter
        
        // Monitor volume mount events
        notificationCenter.addObserver(
            forName: NSWorkspace.didMountNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            
            if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                NSLog("FinderSync: Volume mounted at %@", volumeURL.path)
                
                self.directoriesToWatch.insert(volumeURL)
                FIFinderSyncController.default().directoryURLs = self.directoriesToWatch
                
                NSLog("FinderSync: Added volume to watched directories")
            }
        }
        
        // Monitor volume unmount events
        notificationCenter.addObserver(
            forName: NSWorkspace.didUnmountNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            
            if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                NSLog("FinderSync: Volume unmounted at %@", volumeURL.path)
                
                self.directoriesToWatch.remove(volumeURL)
                FIFinderSyncController.default().directoryURLs = self.directoriesToWatch
                
                NSLog("FinderSync: Removed volume from watched directories")
            }
        }
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")

        // Ensure we are dealing with the contextual menu for items
        if menuKind == .contextualMenuForItems {
            // Get the selected items
            if let selectedItemURLs = FIFinderSyncController.default().selectedItemURLs(),
               selectedItemURLs.count == 1, selectedItemURLs.first?.pathExtension == "app" {
                // Add menu item if the selected item is a .app file
                let menuItem = NSMenuItem(title: String(localized: "Sentinel Unquarantine"), action: #selector(openInMyApp), keyEquivalent: "")
                menu.addItem(menuItem)

            }
        }

        // Return the menu (which may be empty if the conditions are not met)
        return menu

    }

    @objc func openInMyApp(_ sender: AnyObject?) {
        // Get the selected items (files/folders) in Finder
        guard let selectedItems = FIFinderSyncController.default().selectedItemURLs(), !selectedItems.isEmpty else {
            return
        }

        // Consider only the first selected item
        let firstSelectedItem = selectedItems[0]
        let path = firstSelectedItem.path
        NSWorkspace.shared.open(URL(string: "sentinel://com.alienator88.Sentinel?path=\(path)")!)
    }

}
