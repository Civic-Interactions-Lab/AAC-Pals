import Foundation

/// Simulates beacon detection on a timer — useful for simulator and mock builds.
final class MockBeaconService: BeaconService {
    var onBeaconDetected: ((DetectedBeacon?) -> Void)?

    /// The beacon to simulate. nil = always in fallback "common" room.
    var simulatedBeacon: DetectedBeacon?
    /// How often to fire a detection event.
    var interval: TimeInterval

    private var timer: Timer?

    init(
        simulatedBeacon: DetectedBeacon? = DetectedBeacon(name: "Kitchen", major: nil, minor: nil, rssi: -58),
        interval: TimeInterval = 3.0
    ) {
        self.simulatedBeacon = simulatedBeacon
        self.interval = interval
    }

    func startScanning() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.onBeaconDetected?(self?.simulatedBeacon)
        }
        // Fire immediately so the room doesn't wait for the first tick
        onBeaconDetected?(simulatedBeacon)
    }

    func stopScanning() {
        timer?.invalidate()
        timer = nil
    }
}
