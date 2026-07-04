import SwiftUI

enum ProfileNameMode { case add, edit }

struct AddEditProfileModal: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager

    let mode: ProfileNameMode
    let profile: UserProfile?
    @Binding var isPresented: Bool

    @State private var name = ""
    @State private var passcode = ""
    @State private var passcodeError = ""
    @State private var isSaving = false
    @FocusState private var focusedField: Field?

    enum Field { case name, passcode }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && passcode.count == 4 && !isPasscodeTaken
    }

    private var isPasscodeTaken: Bool {
        userManager.profiles.contains { p in
            p.passcode == passcode && p.id != (profile?.id ?? "")
        }
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
                    Text("Set a name and 4-digit passcode")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                }

                AuthTextField(
                    icon: "person.fill",
                    placeholder: mode == .add ? "e.g. Alex" : "New name",
                    text: $name,
                    isFocused: focusedField == .name
                )
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .focused($focusedField, equals: .name)
                .onSubmit { focusedField = .passcode }

                VStack(alignment: .leading, spacing: 4) {
                    AuthTextField(
                        icon: "lock.fill",
                        placeholder: "4-digit passcode",
                        text: $passcode,
                        isFocused: focusedField == .passcode
                    )
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .passcode)
                    .onChange(of: passcode) { _, val in
                        let filtered = String(val.filter(\.isNumber).prefix(4))
                        if filtered != val { passcode = filtered }
                        passcodeError = (filtered.count == 4 && isPasscodeTaken) ? "Passcode already used by another user" : ""
                    }

                    if !passcodeError.isEmpty {
                        Text(passcodeError)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "#FF6B6B"))
                            .padding(.leading, 4)
                    }
                }

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
            .frame(maxWidth: 420)
            .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if mode == .edit {
                name = profile?.displayName ?? ""
                passcode = profile?.passcode ?? ""
            }
            Task { @MainActor in focusedField = .name }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let adminId = authManager.currentUser?.id else { return }
        guard !isPasscodeTaken else { passcodeError = "Passcode already used by another user"; return }
        isSaving = true
        if mode == .add {
            Task { await userManager.addProfile(displayName: trimmed, passcode: passcode, adminId: adminId) }
        } else if let id = profile?.id {
            Task { await userManager.updateProfile(id: id, displayName: trimmed, passcode: passcode, adminId: adminId) }
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

#Preview("Add") { AddEditProfileModalPreview(mode: .add) }
#Preview("Edit") { AddEditProfileModalPreview(mode: .edit) }
