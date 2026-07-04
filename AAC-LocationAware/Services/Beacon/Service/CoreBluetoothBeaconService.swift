import Foundation
import CoreBluetooth

final class CoreBluetoothBeaconService: NSObject, BeaconService {
    var onBeaconDetected: ((DetectedBeacon?) -> Void)?
    private(set) var scannedBeacons: [String: DetectedBeacon] = [:]

    private var central: CBCentralManager?

    override init() {
        super.init()
    }

    func startScanning() {
        scannedBeacons = [:]
        central = CBCentralManager(delegate: self, queue: .main)
    }

    func stopScanning() {
        central?.stopScan()
        central = nil
    }
}

// MARK: - CBCentralManagerDelegate

extension CoreBluetoothBeaconService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }
        central.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let name = peripheral.name
        let rssi = RSSI.intValue

        if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
           let beacon = parseIBeacon(from: data, rssi: rssi, name: name) {
            scannedBeacons[beacon.id] = beacon
            onBeaconDetected?(beacon)
            return
        }

        guard let name, !name.isEmpty else { return }
        let beacon = DetectedBeacon(uuid: nil, name: name, major: nil, minor: nil, rssi: rssi)
        scannedBeacons[beacon.id] = beacon
        onBeaconDetected?(beacon)
    }
}

// MARK: - iBeacon parsing

private extension CoreBluetoothBeaconService {
    func parseIBeacon(from data: Data, rssi: Int, name: String?) -> DetectedBeacon? {
        guard data.count >= 25 else { return nil }
        guard data[0] == 0x4C, data[1] == 0x00 else { return nil }
        guard data[2] == 0x02, data[3] == 0x15 else { return nil }

        let uuidBytes = data[4..<20]
        let hex = uuidBytes.map { String(format: "%02X", $0) }.joined()
        let p1 = String(hex.prefix(8))
        let p2 = String(hex.dropFirst(8).prefix(4))
        let p3 = String(hex.dropFirst(12).prefix(4))
        let p4 = String(hex.dropFirst(16).prefix(4))
        let p5 = String(hex.dropFirst(20))
        let formatted = "\(p1)-\(p2)-\(p3)-\(p4)-\(p5)"

        let major = UInt16(data[20]) << 8 | UInt16(data[21])
        let minor = UInt16(data[22]) << 8 | UInt16(data[23])

        return DetectedBeacon(uuid: formatted, name: name, major: major, minor: minor, rssi: rssi)
    }
}
