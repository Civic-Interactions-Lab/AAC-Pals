import SwiftUI

struct RoomsBeaconsTab: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AdminManager.self) private var adminManager
    @Environment(BeaconManager.self) private var beaconManager

    let onEdit: (Room) -> Void
    let onUseBeacon: (DetectedBeacon) -> Void

    var body: some View {
        // BeaconManager.scannedBeacons isn't observable, so re-read it periodically.
        TimelineView(.periodic(from: .now, by: 2)) { _ in
            let heard = beaconManager.scannedBeacons.sorted { $0.rssi > $1.rssi }

            HStack(alignment: .top, spacing: 18) {
                roomsColumn(heard: heard)
                beaconsColumn(heard: heard)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .task { await load() }
    }

    private func roomsColumn(heard: [DetectedBeacon]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("Rooms")

            if adminManager.rooms.isEmpty {
                Caption("No rooms yet. Tap + NEW ROOM to add one.", size: 14)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(adminManager.rooms) { room in
                        RoomRow(
                            room: room,
                            wordCount: adminManager.words(for: room.id).count,
                            beacons: adminManager.beacons(for: room.id),
                            isInRange: heard.contains { isInRange($0) && adminManager.room(for: $0)?.id == room.id },
                            onEdit: { onEdit(room) }
                        )
                    }
                }
                .padding(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func beaconsColumn(heard: [DetectedBeacon]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("Heard right now")

            if heard.isEmpty {
                Caption("Listening for beacons…", size: 14)
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(heard) { beacon in
                        let room = adminManager.room(for: beacon)
                        HeardBeaconRow(
                            beacon: beacon,
                            room: room,
                            isInRange: isInRange(beacon),
                            onUse: room == nil && beacon.pairingId != nil ? { onUseBeacon(beacon) } : nil
                        )
                    }
                }
                .padding(2)

                Caption("A room's Beacon ID is the pairing — it just has to match what the beacon broadcasts.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
            }
        }
        .frame(width: 392)
    }

    private func isInRange(_ beacon: DetectedBeacon) -> Bool {
        beacon.rssi >= DetectionRadius.medium.rssi
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
    RoomsBeaconsTab(onEdit: { _ in }, onUseBeacon: { _ in })
        .background(Color.paper)
        .previewAllEnvironments()
}
