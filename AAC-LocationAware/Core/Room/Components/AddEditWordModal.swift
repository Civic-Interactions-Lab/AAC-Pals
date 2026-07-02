import SwiftUI

enum WordModalMode { case add, edit }

struct AddEditWordModal: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AdminManager.self) private var adminManager

    let mode: WordModalMode
    let word: RoomWord?
    let roomId: String
    @Binding var isPresented: Bool

    @State private var label = ""
    @State private var category = "verbs"
    @State private var isSaving = false
    @FocusState private var focused: Bool

    private let categories = ["verbs", "nouns", "descriptors", "social", "questions", "other"]

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
                    Text(mode == .add ? "💬 Add Word" : "✏️ Edit Word")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#1A1A2E"))
                    Text("Add a word to this room")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                }

                AuthTextField(icon: "text.bubble.fill", placeholder: "e.g. eat", text: $label, isFocused: focused)
                    .focused($focused)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                    .onSubmit { save() }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.6))

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button {
                                category = cat
                            } label: {
                                Text(cat)
                                    .font(.system(size: 12, weight: category == cat ? .bold : .medium, design: .rounded))
                                    .foregroundStyle(category == cat ? Color.white : Color(hex: "#1A1A2E").opacity(0.6))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .frame(maxWidth: .infinity)
                                    .background(category == cat ? fitzgeraldColor(for: cat) : Color(hex: "#F3F4F6"))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
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
            .frame(maxWidth: 440)
            .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if mode == .edit {
                label = word?.label ?? ""
                category = word?.category ?? "verbs"
            }
            Task { @MainActor in focused = true }
        }
    }

    private func save() {
        let trimmed = label.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmed.isEmpty, let adminId = authManager.currentUser?.id else { return }
        isSaving = true
        if mode == .add {
            Task {
                await adminManager.addWord(label: trimmed, category: category, roomId: roomId, adminId: adminId)
                isPresented = false
            }
        } else if let id = word?.id {
            Task {
                await adminManager.updateWord(id: id, label: trimmed, category: category, roomId: roomId)
                isPresented = false
            }
        }
    }
}

private struct AddEditWordModalPreview: View {
    let mode: WordModalMode
    @State private var isPresented = true
    var body: some View {
        AddEditWordModal(mode: mode, word: mode == .edit ? RoomWord.mocks(for: "room-1")[0] : nil, roomId: "room-1", isPresented: $isPresented)
            .previewAllEnvironments()
    }
}

#Preview("Add") { AddEditWordModalPreview(mode: .add) }
#Preview("Edit") { AddEditWordModalPreview(mode: .edit) }
