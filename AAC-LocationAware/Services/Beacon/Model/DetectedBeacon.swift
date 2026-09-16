import Foundation

struct DetectedBeacon: Identifiable {
    var id: String { uuid ?? name ?? "\(major ?? 0)-\(minor ?? 0)" }
    let uuid: String?
    let name: String?
    let major: UInt16?
    let minor: UInt16?
    let rssi: Int

    /// The value a room stores to pair with this beacon: UUID, else broadcast name.
    var pairingId: String? {
        if let uuid, !uuid.isEmpty { return uuid }
        if let name, !name.isEmpty { return name }
        return nil
    }

    var displayName: String {
        if let name, !name.isEmpty { return name }
        if let uuid { return String(uuid.prefix(18)) + "…" }
        if let major, let minor { return "Major: \(major) Minor: \(minor)" }
        return "Unknown"
    }

    var signalLabel: String {
        if rssi >= -65 { return "Strong" }
        if rssi >= -80 { return "Medium" }
        return "Weak"
    }

    var signalColor: String {
        if rssi >= -65 { return "#2ECC71" }
        if rssi >= -80 { return "#FF9F43" }
        return "#FF6B6B"
    }
}
