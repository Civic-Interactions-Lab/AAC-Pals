import SwiftUI

struct RoomsBeaconsTab: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AdminManager.self) private var adminManager
    @Environment(BeaconManager.self) private var beaconManager

    @State private var showNewRoom = false

    var body: some View {
        // BeaconManager.scannedBeacons isn't observable, so re-read it periodically.
        TimelineView(.periodic(from: .now, by: 2)) { _ in
            let heard = beaconManager.scannedBeacons.sorted { $0.rssi > $1.rssi }

            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button { showNewRoom = true } label: {
                        Label("NEW ROOM", systemImage: "plus")
                            .font(.system(size: 13, weight: .heavy))
                            .tracking(0.6)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.actionBlue, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                }

                HStack(alignment: .top, spacing: 18) {
                    roomsColumn(heard: heard)
                    beaconsColumn(heard: heard)
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
        }
        .sheet(isPresented: $showNewRoom) {
            NewRoomSheet()
        }
        .task { await load() }
    }

    private func roomsColumn(heard: [DetectedBeacon]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("ROOMS")

            if adminManager.rooms.isEmpty {
                emptyText("No rooms yet.")
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(adminManager.rooms) { room in
                        RoomRow(
                            room: room,
                            wordCount: adminManager.words(for: room.id).count,
                            beacons: adminManager.beacons(for: room.id),
                            isInRange: heard.contains { isInRange($0) && adminManager.room(for: $0)?.id == room.id }
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func beaconsColumn(heard: [DetectedBeacon]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("HEARD RIGHT NOW")

            if heard.isEmpty {
                emptyText("Listening for beacons…")
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(heard) { beacon in
                        HeardBeaconRow(beacon: beacon, room: adminManager.room(for: beacon), isInRange: isInRange(beacon))
                    }
                }
            }

            Text("A room's Beacon ID is the pairing — it just has to match what the beacon broadcasts.")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.ink.opacity(0.86))
        }
        .frame(width: 392)
    }

    private func isInRange(_ beacon: DetectedBeacon) -> Bool {
        beacon.rssi >= DetectionRadius.medium.rssi
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .heavy))
            .tracking(1)
            .foregroundStyle(Color.ink.opacity(0.86))
    }

    private func emptyText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.ink.opacity(0.7))
    }

    private func load() async {
        let adminId = authManager.currentUser?.id ?? ""
        await adminManager.loadRooms(adminId: adminId)
        for room in adminManager.rooms {
            await adminManager.loadWords(for: room.id)
        }
        _ = await adminManager.loadAllBeacons(adminId: adminId)
        beaconManager.startScanning()
    }
}

#Preview {
    RoomsBeaconsTab()
        .background(Color.paper)
        .previewAllEnvironments()
}
