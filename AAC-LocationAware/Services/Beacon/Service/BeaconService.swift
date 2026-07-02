import Foundation

protocol BeaconService: AnyObject {
    var onBeaconDetected: ((DetectedBeacon?) -> Void)? { get set }
    func startScanning()
    func stopScanning()
}
