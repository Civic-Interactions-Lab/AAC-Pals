import Foundation

struct BeaconConfig {
    let peripheralName: String?
    let major: UInt16?
    let minor: UInt16?
    let rssiThreshold: Int
    let roomId: String
    let beaconUuid: String?

    static func withName(_ name: String, radius: DetectionRadius, roomId: String) -> BeaconConfig {
        BeaconConfig(peripheralName: name, major: nil, minor: nil, rssiThreshold: radius.rssi, roomId: roomId, beaconUuid: nil)
    }

    static func withRadius(_ radius: DetectionRadius, major: UInt16, minor: UInt16, roomId: String) -> BeaconConfig {
        BeaconConfig(peripheralName: nil, major: major, minor: minor, rssiThreshold: radius.rssi, roomId: roomId, beaconUuid: nil)
    }

    func matches(_ beacon: DetectedBeacon) -> Bool {
        guard beacon.rssi >= rssiThreshold else { return false }
        if let uuid = beaconUuid, let bUuid = beacon.uuid {
            return bUuid.lowercased() == uuid.lowercased()
        }
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
    case veryClose
    case close
    case medium
    case far
    case custom(Int)

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
