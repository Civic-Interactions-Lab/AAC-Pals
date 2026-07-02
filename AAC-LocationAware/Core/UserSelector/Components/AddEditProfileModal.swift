import SwiftUI

enum ProfileNameMode { case add, edit }

struct AddEditProfileModal: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager

    let mode: ProfileNameMode
    let profile: UserProfile?
    @Binding var isPresented: Bool

    @State private var name = ""
    @State private var isSaving = false
    @FocusState private var focused: Bool

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode == .add ? "👤 Add User" : "✏️ Edit Name")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#1A1A2E"))

                    Text("What should we call this user?")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                }

                AuthTextField(
                    icon: "person.fill",
                    placeholder: mode == .add ? "e.g. Alex" : "New name",
                    text: $name,
                    isFocused: focused
                )
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .focused($focused)
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
            .frame(maxWidth: 400)
            .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard)
        .onAppear {
            if mode == .edit { name = profile?.displayName ?? "" }
            Task { @MainActor in focused = true }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let adminId = authManager.currentUser?.id else { return }
        isSaving = true
        if mode == .add {
            Task { await userManager.addProfile(displayName: trimmed, adminId: adminId) }
        } else if let id = profile?.id {
            Task { await userManager.renameProfile(id: id, displayName: trimmed, adminId: adminId) }
        }
        isPresented = false
    }
}

private struct AddEditProfileModalPreview: View {
    let mode: ProfileNameMode
    @State private var isPresented = true

    var body: some View {
        AddEditProfileModal(mode: mode, profile: mode == .edit ? UserProfile.mocks[0] : nil, isPresented: $isPresented)
            .previewAllEnvironments()
    }
}

#Preview("Add") {
    AddEditProfileModalPreview(mode: .add)
}

#Preview("Edit") {
    AddEditProfileModalPreview(mode: .edit)
}
