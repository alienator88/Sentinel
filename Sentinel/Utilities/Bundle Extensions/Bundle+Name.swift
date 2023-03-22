import Foundation

extension Bundle {
    
    var name: String {
        func string(for key: String) -> String? {
            object(forInfoDictionaryKey: key) as? String
        }
        return string(for: "CFBundleDisplayName")
            ?? string(for: "CFBundleName")
            ?? "N/A"
    }
}
