import SwiftUI

struct NewRoomSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(AdminManager.self) private var adminManager
    @Environment(BeaconManager.self) private var beaconManager

    @State private var selected: DetectedBeacon?
    @State private var roomName = ""
    @State private var isSaving = false
    @State private var failed = false
    @FocusState private var nameFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Group {
                if let selected {
                    confirmStep(selected)
                } else {
                    scanStep
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.paper)
        .presentationBackground(Color.paper)
        .interactiveDismissDisabled(isSaving)
        .onAppear { beaconManager.startScanning() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(selected == nil ? "Find the beacon" : "Name the room")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                Text(selected == nil ? "STEP 1 OF 2" : "STEP 2 OF 2")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(Color.ink.opacity(0.86))
            }

            Spacer()

            squareButton("xmark", label: "Close") { dismiss() }
                .disabled(isSaving)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(Color.butter)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.ink).frame(height: 2)
        }
    }

    // MARK: - Step 1

    private var scanStep: some View {
        TimelineView(.periodic(from: .now, by: 2)) { _ in
            let available = beaconManager.scannedBeacons
                .filter { $0.pairingId != nil && adminManager.room(for: $0) == nil }
                .sorted { $0.rssi > $1.rssi }

            VStack(alignment: .leading, spacing: 12) {
                Text("Stand next to the beacon in the room you're adding, then tap it. The closest beacon is at the top.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.ink.opacity(0.86))

                if available.isEmpty {
                    HStack(spacing: 10) {
                        ProgressView().tint(Color.ink)
                        Text("Listening for new beacons…")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.ink)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(Color.butter, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(available) { beacon in
                                Button { choose(beacon) } label: {
                                    HeardBeaconRow(beacon: beacon, room: nil, isInRange: true, actionTitle: "Use it")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Text("Beacons already paired with a room aren't shown.")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.ink.opacity(0.86))
            }
        }
    }

    // MARK: - Step 2

    private func confirmStep(_ beacon: DetectedBeacon) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                fieldLabel("ROOM NAME")
                TextField("e.g. Kitchen", text: $roomName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .onSubmit(create)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))

            VStack(alignment: .leading, spacing: 5) {
                fieldLabel("BEACON ID")
                Text(beacon.pairingId ?? "")
                    .font(.system(size: 17, weight: .heavy, design: .monospaced))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                    .truncationMode(.middle)
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.signalGreen)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().strokeBorder(Color.ink, lineWidth: 2))
                    Text("Heard now · \(beacon.rssi) dBm")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.ink.opacity(0.88))
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Color.butter, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))

            Text("When the iPad hears this beacon, the board shows this room's words.")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.ink.opacity(0.86))

            if failed {
                Text("Couldn't create the room. Try again.")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.categoryNegation, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.ink, lineWidth: 2))
            }

            Spacer(minLength: 0)

            HStack(spacing: 12) {
                Button { selected = nil; failed = false } label: {
                    Text("Back")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.paper, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
                }
                .buttonStyle(.plain)
                .disabled(isSaving)

                Button(action: create) {
                    HStack(spacing: 10) {
                        if isSaving { ProgressView().tint(.white) }
                        Text("Create room")
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.actionBlue, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
                    .shadow(color: Color.ink.opacity(0.28), radius: 0, y: 2)
                }
                .buttonStyle(.plain)
                .disabled(trimmedName.isEmpty || isSaving)
                .opacity(trimmedName.isEmpty ? 0.5 : 1)
            }
        }
    }

    // MARK: - Actions

    private var trimmedName: String {
        roomName.trimmingCharacters(in: .whitespaces)
    }

    private func choose(_ beacon: DetectedBeacon) {
        selected = beacon
        roomName = beacon.name ?? ""
        failed = false
        nameFocused = true
    }

    private func create() {
        guard let beaconId = selected?.pairingId, !trimmedName.isEmpty, !isSaving else { return }
        isSaving = true
        failed = false
        Task {
            let adminId = authManager.currentUser?.id ?? ""
            let success = await adminManager.addRoom(label: trimmedName, pairedWith: beaconId, adminId: adminId)
            isSaving = false
            if success { dismiss() } else { failed = true }
        }
    }

    // MARK: - Pieces

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .heavy))
            .tracking(1)
            .foregroundStyle(Color.ink.opacity(0.86))
    }

    private func squareButton(_ systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.ink)
                .frame(width: 48, height: 48)
                .background(Color.paper, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview {
    Color.paper
        .sheet(isPresented: .constant(true)) { NewRoomSheet() }
        .previewAllEnvironments()
}
