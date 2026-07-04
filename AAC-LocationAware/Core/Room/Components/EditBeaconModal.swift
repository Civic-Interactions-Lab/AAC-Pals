import SwiftUI

struct EditBeaconModal: View {
    @Environment(AdminManager.self) private var adminManager

    let beacon: AppBeacon
    let roomId: String
    @Binding var isPresented: Bool

    @State private var label: String
    @State private var radius: Double
    @State private var isSaving = false

    init(beacon: AppBeacon, roomId: String, isPresented: Binding<Bool>) {
        self.beacon = beacon
        self.roomId = roomId
        self._isPresented = isPresented
        self._label = State(initialValue: beacon.label)
        self._radius = State(initialValue: beacon.radius)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Edit Beacon")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(Color(hex: "#1A1A2E"))
                        Text(beacon.beaconUuid)
                            .font(.system(size: 11, weight: .regular, design: .monospaced))
                            .foregroundStyle(Color(hex: "#9CA3AF"))
                            .lineLimit(1)
                    }
                    Spacer()
                    Button { isPresented = false } label: {
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

                VStack(alignment: .leading, spacing: 20) {
                    // Label
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Label")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(hex: "#9CA3AF"))
                        TextField("e.g. Main Entrance", text: $label)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .padding(12)
                            .background(Color(hex: "#F3F4F6"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

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
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)

                Divider()

                // Save
                Button {
                    let trimmed = label.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    isSaving = true
                    Task {
                        await adminManager.updateBeacon(id: beacon.id, label: trimmed, radius: radius, roomId: roomId)
                        isSaving = false
                        isPresented = false
                    }
                } label: {
                    Group {
                        if isSaving {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Save Changes")
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
                .padding(24)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(0.18), radius: 30, x: 0, y: 10)
            .frame(width: 400)
            .padding(40)
        }
    }
}
