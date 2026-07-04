import SwiftUI

struct BeaconScannerModal: View {
    @Environment(AdminManager.self) private var adminManager
    @Environment(AuthManager.self) private var authManager
    @Environment(BeaconManager.self) private var beaconManager

    let room: Room
    @Binding var isPresented: Bool

    @State private var isScanning = false
    @State private var scanned: [DetectedBeacon] = []
    @State private var selected: DetectedBeacon? = nil
    @State private var label = ""
    @State private var radius = 10.0
    @State private var isSaving = false
    @State private var scanTimer: Timer? = nil

    private var linkedIdentifiers: Set<String> {
        Set(adminManager.beacons(for: room.id).map { $0.beaconUuid.lowercased() })
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
                .onTapGesture { if selected == nil { dismiss() } }

            HStack(spacing: 0) {
                scanPanel
                    .frame(width: 420)
                if let beacon = selected {
                    linkPanel(beacon: beacon)
                        .frame(width: 340)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(0.18), radius: 30, x: 0, y: 10)
            .animation(.spring(duration: 0.3), value: selected?.id)
            .padding(40)
        }
        .onDisappear { stopScan() }
    }

    // MARK: - Scan panel

    private var scanPanel: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scan for Beacons")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#1A1A2E"))
                    Text("Room: \(room.label)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                        .frame(width: 36, height: 36)
                        .background(Color(hex: "#F3F4F6"))
                        .clipShape(Circle())
                }
            }
            .padding(24)

            Divider()

            // Scan button
            Button {
                isScanning ? stopScan() : startScan()
            } label: {
                HStack(spacing: 10) {
                    if isScanning {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    Text(isScanning ? "Scanning…" : "Start Scan")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isScanning ? Color(hex: "#9CA3AF") : Color(hex: "#FF9F43"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            // Results
            if scanned.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 40))
                        .foregroundStyle(Color(hex: "#E5E7EB"))
                    Text(isScanning ? "Looking for nearby beacons…" : "Tap Start Scan to detect beacons")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(scanned) { beacon in
                            let identifier = (beacon.uuid ?? beacon.name ?? beacon.id).lowercased()
                            let alreadyLinked = linkedIdentifiers.contains(identifier)
                            ScannedBeaconRow(
                                beacon: beacon,
                                isAlreadyLinked: alreadyLinked,
                                isSelected: selected?.id == beacon.id
                            ) {
                                guard !alreadyLinked else { return }
                                withAnimation { selected = beacon }
                                label = beacon.displayName
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    // MARK: - Link panel

    private func linkPanel(beacon: DetectedBeacon) -> some View {
        VStack(spacing: 0) {
            Color(hex: "#F9FAFB")
                .frame(height: 1)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Link Beacon")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#1A1A2E"))
                    Spacer()
                    Button { withAnimation { selected = nil } } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(hex: "#9CA3AF"))
                            .frame(width: 32, height: 32)
                            .background(Color(hex: "#F3F4F6"))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)

                // Identifier display
                VStack(alignment: .leading, spacing: 4) {
                    Text(beacon.uuid != nil ? "UUID" : "Identified by name")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                    Text(beacon.uuid ?? beacon.name ?? beacon.id)
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(Color(hex: "#1A1A2E"))
                        .lineLimit(2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // Label input
                VStack(alignment: .leading, spacing: 6) {
                    Text("Label")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                    TextField("e.g. Main Entrance", text: $label)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .padding(12)
                        .background(Color(hex: "#F3F4F6"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // Radius
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Detection Radius")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: "#9CA3AF"))
                        Spacer()
                        Text("\(Int(radius)) ft")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: "#FF9F43"))
                    }
                    Slider(value: $radius, in: 3...66, step: 1)
                        .tint(Color(hex: "#FF9F43"))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                Spacer()

                // Save button
                Button {
                    let identifier = beacon.uuid ?? beacon.name ?? beacon.id
                    guard !label.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    isSaving = true
                    Task {
                        await adminManager.addBeacon(
                            beaconUuid: identifier,
                            label: label.trimmingCharacters(in: .whitespaces),
                            radius: radius,
                            roomId: room.id,
                            adminId: authManager.currentUser?.id ?? ""
                        )
                        isSaving = false
                        dismiss()
                    }
                } label: {
                    Group {
                        if isSaving {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Link to \(room.label)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(label.trimmingCharacters(in: .whitespaces).isEmpty ? Color(hex: "#E5E7EB") : Color(hex: "#FF9F43"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(label.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(Color(hex: "#F9FAFB"))
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 28, topTrailingRadius: 28))
    }

    // MARK: - Scan helpers

    private func startScan() {
        scanned = []
        isScanning = true
        beaconManager.startScanning()
        // Refresh scanned list every second from BeaconManager's service
        scanTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                scanned = beaconManager.scannedBeacons.filter { $0.rssi >= -55 }.sorted { $0.rssi > $1.rssi }
            }
        }
    }

    private func stopScan() {
        scanTimer?.invalidate()
        scanTimer = nil
        beaconManager.stopScanning()
        isScanning = false
    }

    private func dismiss() {
        stopScan()
        isPresented = false
    }
}

// MARK: - Scanned beacon row

private struct ScannedBeaconRow: View {
    let beacon: DetectedBeacon
    let isAlreadyLinked: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(signalColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(signalColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(beacon.displayName)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#1A1A2E"))
                    HStack(spacing: 6) {
                        Text(beacon.signalLabel)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(signalColor)
                        Text("·")
                            .foregroundStyle(Color(hex: "#9CA3AF"))
                        Text("\(beacon.rssi) dBm")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(Color(hex: "#9CA3AF"))
                    }
                }

                Spacer()

                if isAlreadyLinked {
                    Text("Linked")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#E5E7EB"))
                        .clipShape(Capsule())
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(hex: "#FF9F43"))
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color(hex: "#FF9F43").opacity(0.08) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? Color(hex: "#FF9F43") : Color.clear, lineWidth: 1.5)
            )
            .opacity(isAlreadyLinked ? 0.5 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isAlreadyLinked)
    }

    private var signalColor: Color {
        Color(hex: beacon.signalColor)
    }
}

