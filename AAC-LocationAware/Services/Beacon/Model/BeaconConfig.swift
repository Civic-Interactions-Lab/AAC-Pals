import Foundation

/// A known beacon mapped to a room. Match by peripheral name OR by iBeacon major/minor.
struct BeaconConfig {
    let peripheralName: String?
    let major: UInt16?
    let minor: UInt16?
    /// RSSI must be >= this value to count as detected (e.g. -70 means within ~5m).
    let rssiThreshold: Int
    let roomId: String

    /// Match by BLE peripheral name (for non-iBeacon hardware).
    static func withName(_ name: String, radius: DetectionRadius, roomId: String) -> BeaconConfig {
        BeaconConfig(peripheralName: name, major: nil, minor: nil, rssiThreshold: radius.rssi, roomId: roomId)
    }

    /// Match by iBeacon major/minor values.
    static func withRadius(_ radius: DetectionRadius, major: UInt16, minor: UInt16, roomId: String) -> BeaconConfig {
        BeaconConfig(peripheralName: nil, major: major, minor: minor, rssiThreshold: radius.rssi, roomId: roomId)
    }

    func matches(_ beacon: DetectedBeacon) -> Bool {
        guard beacon.rssi >= rssiThreshold else { return false }
        if let name = peripheralName, let bName = beacon.name {
            return bName.lowercased() == name.lowercased()
        }
        if let major, let minor, let bMajor = beacon.major, let bMinor = beacon.minor {
            return bMajor == major && bMinor == minor
        }
        return false
    }
}

enum DetectionRadius {
    case veryClose   // ~1m
    case close       // ~3m
    case medium      // ~5m
    case far         // ~10m
    case custom(Int) // raw RSSI threshold

    var rssi: Int {
        switch self {
        case .veryClose:      return -50
        case .close:          return -60
        case .medium:         return -70
        case .far:            return -80
        case .custom(let v):  return v
        }
    }
}
