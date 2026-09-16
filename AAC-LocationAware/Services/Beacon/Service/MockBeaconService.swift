import Foundation

/// Simulates beacon detection on a timer — useful for simulator and mock builds.
final class MockBeaconService: BeaconService {
    var onBeaconDetected: ((DetectedBeacon?) -> Void)?
    private(set) var scannedBeacons: [String: DetectedBeacon] = [:]

    var simulatedBeacon: DetectedBeacon?
    var nearbyBeacons: [DetectedBeacon]
    var interval: TimeInterval

    private var timer: Timer?

    init(
        simulatedBeacon: DetectedBeacon? = DetectedBeacon(uuid: nil, name: "Kitchen", major: nil, minor: nil, rssi: -58),
        nearbyBeacons: [DetectedBeacon] = [
            DetectedBeacon(uuid: nil, name: "Playroom", major: nil, minor: nil, rssi: -66),
            DetectedBeacon(uuid: "B9407F30-F5F8-466E-AFF9-25556B57FE6D", name: nil, major: 1, minor: 7, rssi: -79),
            DetectedBeacon(uuid: nil, name: "Hallway", major: nil, minor: nil, rssi: -93),
        ],
        interval: TimeInterval = 3.0
    ) {
        self.simulatedBeacon = simulatedBeacon
        self.nearbyBeacons = nearbyBeacons
        self.interval = interval
    }

    func startScanning() {
        scannedBeacons = [:]
        if let b = simulatedBeacon { scannedBeacons[b.id] = b }
        for b in nearbyBeacons { scannedBeacons[b.id] = b }
        onBeaconDetected?(simulatedBeacon)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.onBeaconDetected?(self?.simulatedBeacon)
        }
    }

    func stopScanning() {
        timer?.invalidate()
        timer = nil
    }
}
