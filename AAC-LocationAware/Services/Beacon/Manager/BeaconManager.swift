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
    private(set) var currentBeacon: DetectedBeacon?
    var scannedBeacons: [DetectedBeacon] { Array(service.scannedBeacons.values) }

    var knownBeacons: [BeaconConfig] = []

    /// How long (seconds) with no matching beacon signal before falling back to common.
    var fallbackDelay: TimeInterval = 8.0

    var enterThreshold: Int = DetectionRadius.medium.rssi
    var stayThreshold: Int = DetectionRadius.far.rssi - 5
    var switchMargin: Double = 6

    private struct RoomSignal {
        var rssi: Double
        var lastSeen: Date
        var beacon: DetectedBeacon
    }

    private var signals: [String: RoomSignal] = [:]
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
        signals = [:]
        isScanning = false
        currentRoomId = kCommonRoomId
        currentBeacon = nil
    }

    func loadBeacons(_ beacons: [AppBeacon]) {
        knownBeacons = beacons.map { appBeacon in
            let looksLikeUUID = UUID(uuidString: appBeacon.beaconUuid) != nil
            return BeaconConfig(
                peripheralName: looksLikeUUID ? nil : appBeacon.beaconUuid,
                major: nil,
                minor: nil,
                rssiThreshold: enterThreshold,
                roomId: appBeacon.roomId,
                beaconUuid: looksLikeUUID ? appBeacon.beaconUuid : nil
            )
        }
    }

    private func handle(_ detected: DetectedBeacon?) {
        guard let beacon = detected, beacon.rssi < 0,
              let roomId = knownBeacons.first(where: { $0.identifies(beacon) })?.roomId
        else { return }
        let reading = Double(beacon.rssi)
        if var signal = signals[roomId] {
            signal.rssi = signal.rssi * 0.6 + reading * 0.4
            signal.lastSeen = Date()
            signal.beacon = beacon
            signals[roomId] = signal
        } else {
            signals[roomId] = RoomSignal(rssi: reading, lastSeen: Date(), beacon: beacon)
        }
        evaluate()
    }

    private func evaluate() {
        let now = Date()
        signals = signals.filter { now.timeIntervalSince($0.value.lastSeen) < fallbackDelay }

        let strongest = signals
            .filter { $0.value.rssi >= Double(enterThreshold) }
            .max { $0.value.rssi < $1.value.rssi }

        if let current = signals[currentRoomId], current.rssi >= Double(stayThreshold) {
            currentBeacon = current.beacon
            if let strongest, strongest.key != currentRoomId, strongest.value.rssi >= current.rssi + switchMargin {
                enter(strongest.key, beacon: strongest.value.beacon)
            }
            return
        }

        if let strongest {
            enter(strongest.key, beacon: strongest.value.beacon)
        } else if currentRoomId != kCommonRoomId {
            print("[BeaconManager] Lost room \(currentRoomId) — falling back to common")
            currentRoomId = kCommonRoomId
            currentBeacon = nil
        }
    }

    private func enter(_ roomId: String, beacon: DetectedBeacon) {
        currentBeacon = beacon
        guard currentRoomId != roomId else { return }
        print("[BeaconManager] Entered room: \(roomId)")
        currentRoomId = roomId
    }

    private func startWatchdog() {
        watchdogTask?.cancel()
        watchdogTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                evaluate()
            }
        }
    }
}
