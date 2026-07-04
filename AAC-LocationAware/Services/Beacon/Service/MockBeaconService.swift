import Foundation

/// Simulates beacon detection on a timer — useful for simulator and mock builds.
final class MockBeaconService: BeaconService {
    var onBeaconDetected: ((DetectedBeacon?) -> Void)?
    private(set) var scannedBeacons: [String: DetectedBeacon] = [:]

    var simulatedBeacon: DetectedBeacon?
    var interval: TimeInterval

    private var timer: Timer?

    init(
        simulatedBeacon: DetectedBeacon? = DetectedBeacon(uuid: nil, name: "Kitchen", major: nil, minor: nil, rssi: -58),
        interval: TimeInterval = 3.0
    ) {
        self.simulatedBeacon = simulatedBeacon
        self.interval = interval
    }

    func startScanning() {
        scannedBeacons = [:]
        if let b = simulatedBeacon { scannedBeacons[b.id] = b }
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
