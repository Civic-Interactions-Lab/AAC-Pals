import Foundation
import CoreBluetooth

final class CoreBluetoothBeaconService: NSObject, BeaconService {
    var onBeaconDetected: ((DetectedBeacon?) -> Void)?

    private var central: CBCentralManager?

    override init() {
        super.init()
    }

    func startScanning() {
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
        print("[Beacon] BT state: \(central.state.rawValue)")
        guard central.state == .poweredOn else {
            print("[Beacon] Not powered on — cannot scan")
            return
        }
        print("[Beacon] Starting scan...")
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

        // Try iBeacon manufacturer data first
        if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
           let beacon = parseIBeacon(from: data, rssi: rssi, name: name) {
            print("[Beacon] iBeacon — name: \(name ?? "?") major: \(beacon.major!) minor: \(beacon.minor!) rssi: \(rssi)")
            onBeaconDetected?(beacon)
            return
        }

        // Fall back to name-based detection for non-iBeacon BLE peripherals
        guard let name, !name.isEmpty else { return }
        print("[Beacon] Named peripheral: \(name) rssi: \(rssi)")
        onBeaconDetected?(DetectedBeacon(name: name, major: nil, minor: nil, rssi: rssi))
    }
}

// MARK: - iBeacon parsing

private extension CoreBluetoothBeaconService {
    /// Parses Apple iBeacon manufacturer data.
    /// Format: [0x4C, 0x00, 0x02, 0x15, <16-byte UUID>, <2-byte major>, <2-byte minor>, <1-byte RSSI@1m>]
    func parseIBeacon(from data: Data, rssi: Int, name: String?) -> DetectedBeacon? {
        guard data.count >= 25 else { return nil }
        guard data[0] == 0x4C, data[1] == 0x00 else { return nil }
        guard data[2] == 0x02, data[3] == 0x15 else { return nil }

        let major = UInt16(data[20]) << 8 | UInt16(data[21])
        let minor = UInt16(data[22]) << 8 | UInt16(data[23])

        return DetectedBeacon(name: name, major: major, minor: minor, rssi: rssi)
    }
}
