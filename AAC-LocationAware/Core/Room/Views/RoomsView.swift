import SwiftUI

struct RoomsView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AdminManager.self) private var adminManager

    @State private var showAddRoom = false
    @State private var editRoom: Room? = nil
    @State private var deleteRoom: Room? = nil
    @State private var selectedRoom: Room? = nil

    var body: some View {
        ZStack {
            DecorativeBackground()

            ScrollView {
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Rooms")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(Color(hex: "#1A1A2E"))
                            Text("Manage your AAC rooms and words")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(hex: "#9CA3AF"))
                        }
                        .padding(.leading, 32)
                        Spacer()
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 28)

                    if adminManager.isLoading {
                        ProgressView()
                            .tint(Color(hex: "#FF9F43"))
                            .scaleEffect(1.4)
                            .padding(.top, 80)
                    } else if adminManager.rooms.isEmpty {
                        VStack(spacing: 28) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#FF9F43").opacity(0.1))
                                    .frame(width: 120, height: 120)
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            VStack(spacing: 8) {
                                Text("No rooms yet")
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundStyle(Color(hex: "#1A1A2E"))
                                Text("Add your first room to get started")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color(hex: "#9CA3AF"))
                                    .multilineTextAlignment(.center)
                            }
                            Button { showAddRoom = true } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill").font(.system(size: 17))
                                    Text("Create Room").font(.system(size: 17, weight: .black, design: .rounded))
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: Color(hex: "#FF9F43").opacity(0.4), radius: 16, x: 0, y: 8)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 40)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200, maximum: 240), spacing: 28)], spacing: 28) {
                            ForEach(adminManager.rooms) { room in
                                RoomCard(
                                    room: room,
                                    wordCount: adminManager.words(for: room.id).count,
                                    onTap: { selectedRoom = room },
                                    onEdit: { editRoom = room },
                                    onDelete: { deleteRoom = room }
                                )
                            }
                            AddRoomCard(onTap: { showAddRoom = true })
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 48)
                    }
                }
            }

            if showAddRoom {
                AddEditRoomModal(mode: .add, room: nil, isPresented: $showAddRoom)
                    .transition(.opacity)
            }

            if let room = editRoom {
                AddEditRoomModal(
                    mode: .edit,
                    room: room,
                    isPresented: Binding(get: { editRoom != nil }, set: { if !$0 { editRoom = nil } })
                )
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.18), value: showAddRoom)
        .animation(.easeOut(duration: 0.18), value: editRoom?.id)
        .fullScreenCover(item: $selectedRoom) { room in
            RoomDetailView(room: room)
        }
        .confirmationDialog(
            "Delete \(deleteRoom?.label ?? "room")?",
            isPresented: Binding(get: { deleteRoom != nil }, set: { if !$0 { deleteRoom = nil } }),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let id = deleteRoom?.id {
                    Task { await adminManager.deleteRoom(id: id) }
                }
                deleteRoom = nil
            }
            Button("Cancel", role: .cancel) { deleteRoom = nil }
        } message: {
            Text("All words in this room will also be deleted.")
        }
        .task(id: authManager.currentUser?.id) {
            guard let adminId = authManager.currentUser?.id else { return }
            await adminManager.loadRooms(adminId: adminId)
            for room in adminManager.rooms {
                await adminManager.loadWords(for: room.id)
            }
        }
    }
}

#Preview("Empty") {
    RoomsView().previewAllEnvironments()
}

#Preview("With Rooms") {
    RoomsView().previewAllEnvironments(adminService: MockAdminService(rooms: Room.mocks), preloadRooms: true)
}
