import Foundation

protocol BeaconService: AnyObject {
    var onBeaconDetected: ((DetectedBeacon?) -> Void)? { get set }
    var scannedBeacons: [String: DetectedBeacon] { get }
    func startScanning()
    func stopScanning()
}
