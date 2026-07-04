import SwiftUI

enum RoomModalMode { case add, edit }

struct AddEditRoomModal: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AdminManager.self) private var adminManager

    let mode: RoomModalMode
    let room: Room?
    @Binding var isPresented: Bool

    @State private var label = ""
    @State private var isSaving = false
    @FocusState private var focused: Bool

    private var isValid: Bool {
        !label.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode == .add ? "Add Room" : "Edit Room")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#1A1A2E"))
                    Text("Give this room a name")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                }

                AuthTextField(icon: "mappin.circle.fill", placeholder: "Room name (e.g. Kitchen)", text: $label, isFocused: focused)
                    .focused($focused)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .onSubmit { save() }

                HStack(spacing: 12) {
                    Button("Cancel") { isPresented = false }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#FF9F43"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#FF9F43").opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .buttonStyle(.plain)

                    Button(action: save) {
                        Group {
                            if isSaving {
                                ProgressView().tint(.white)
                            } else {
                                Text(mode == .add ? "Add" : "Save")
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: isValid
                                    ? [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")]
                                    : [Color(hex: "#E5E7EB"), Color(hex: "#E5E7EB")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .disabled(!isValid || isSaving)
                }
            }
            .padding(28)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(0.18), radius: 48, x: 0, y: 20)
            .frame(maxWidth: 440)
            .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if mode == .edit { label = room?.label ?? "" }
            Task { @MainActor in focused = true }
        }
    }

    private func save() {
        let trimmed = label.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let adminId = authManager.currentUser?.id else { return }
        isSaving = true
        if mode == .add {
            Task {
                await adminManager.addRoom(label: trimmed, adminId: adminId)
                isPresented = false
            }
        } else if let id = room?.id {
            Task {
                await adminManager.updateRoom(id: id, label: trimmed)
                isPresented = false
            }
        }
    }
}

private struct AddEditRoomModalPreview: View {
    let mode: RoomModalMode
    @State private var isPresented = true
    var body: some View {
        AddEditRoomModal(mode: mode, room: mode == .edit ? Room.mocks[0] : nil, isPresented: $isPresented)
            .previewAllEnvironments()
    }
}

#Preview("Add") { AddEditRoomModalPreview(mode: .add) }
#Preview("Edit") { AddEditRoomModalPreview(mode: .edit) }
