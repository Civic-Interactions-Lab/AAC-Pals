import Foundation
import Observation

public let kCommonRoomId = "common"

@MainActor
@Observable
final class BeaconManager {
    private let service: BeaconService

    /// The room id currently detected. Defaults to "common" (fallback).
    private(set) var currentRoomId: String = kCommonRoomId
    private(set) var isScanning = false

    /// Known beacons to match against. Add more as you get new hardware.
    var knownBeacons: [BeaconConfig] = [
        .withName("Kitchen", radius: .medium, roomId: "kitchen")
    ]

    /// How long (seconds) with no matching beacon signal before falling back to common.
    var fallbackDelay: TimeInterval = 8.0

    private var lastMatchedDate: Date?
    private var watchdogTask: Task<Void, Never>?

    init(service: BeaconService) {
        self.service = service
    }

    func startScanning() {
        guard !isScanning else { return }
        isScanning = true

        service.onBeaconDetected = { [weak self] detected in
            Task { @MainActor [weak self] in
                self?.handle(detected)
            }
        }
        service.startScanning()
        startWatchdog()
    }

    func stopScanning() {
        service.stopScanning()
        watchdogTask?.cancel()
        watchdogTask = nil
        lastMatchedDate = nil
        isScanning = false
        currentRoomId = kCommonRoomId
    }

    private func handle(_ detected: DetectedBeacon?) {
        guard let beacon = detected else { return }

        if let match = knownBeacons.first(where: { $0.matches(beacon) }) {
            lastMatchedDate = Date()
            if currentRoomId != match.roomId {
                print("[BeaconManager] Entered room: \(match.roomId)")
                currentRoomId = match.roomId
            }
        }
        // Non-matching peripherals are ignored — watchdog handles the fallback
    }

    /// Polls every 3 seconds. If no matching beacon seen within fallbackDelay, revert to common.
    private func startWatchdog() {
        watchdogTask?.cancel()
        watchdogTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { return }
                await checkFallback()
            }
        }
    }

    private func checkFallback() {
        guard currentRoomId != kCommonRoomId else { return }
        let elapsed = lastMatchedDate.map { Date().timeIntervalSince($0) } ?? fallbackDelay
        if elapsed >= fallbackDelay {
            print("[BeaconManager] No beacon for \(Int(elapsed))s — falling back to common")
            currentRoomId = kCommonRoomId
            lastMatchedDate = nil
        }
    }
}
