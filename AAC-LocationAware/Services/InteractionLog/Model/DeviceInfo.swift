import UIKit

struct DeviceInfo {
    let id: String?
    let name: String
    let model: String
    let osVersion: String
    let appVersion: String

    @MainActor
    static var current: DeviceInfo {
        let device = UIDevice.current
        let bundle = Bundle.main
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return DeviceInfo(
            id: device.identifierForVendor?.uuidString,
            name: device.name,
            model: modelIdentifier,
            osVersion: "\(device.systemName) \(device.systemVersion)",
            appVersion: "\(version) (\(build))"
        )
    }

    private static var modelIdentifier: String {
        if let simulated = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulated
        }
        var info = utsname()
        uname(&info)
        return withUnsafeBytes(of: &info.machine) { buffer in
            String(decoding: buffer.prefix { $0 != 0 }, as: UTF8.self)
        }
    }
}
