//
//  AppGroupDefaults.swift
//  Sentinel
//
//  Shared UserDefaults for app group communication
//

import Foundation

extension UserDefaults {
    static let appGroup = UserDefaults(suiteName: "group.com.alienator88.Sentinel")!

    struct Keys {
        static let enableMountedVolumesSync = "enableMountedVolumesSync"
        static let showAppIconInMenu = "showAppIconInMenu"
    }

    // Setting for enabling/disabling mounted volumes monitoring
    static var enableMountedVolumesSync: Bool {
        get {
            return appGroup.bool(forKey: Keys.enableMountedVolumesSync)
        }
        set {
            appGroup.set(newValue, forKey: Keys.enableMountedVolumesSync)
        }
    }

    // Setting for showing app icon in context menu
    static var showAppIconInMenu: Bool {
        get {
            return appGroup.bool(forKey: Keys.showAppIconInMenu)
        }
        set {
            appGroup.set(newValue, forKey: Keys.showAppIconInMenu)
        }
    }
}
