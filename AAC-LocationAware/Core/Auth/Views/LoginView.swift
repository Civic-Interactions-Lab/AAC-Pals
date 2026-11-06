import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager

    @State private var email = ""
    @State private var password = ""
    @FocusState private var focused: Field?

    private enum Field { case email, password }

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty && !authManager.isLoading
    }

    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()

            Circle()
                .fill(Color.butter)
                .frame(width: 360, height: 360)
                .position(x: 30, y: 30)
            Circle()
                .fill(Color.signalGreen.opacity(0.75))
                .frame(width: 400, height: 400)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .offset(x: 140, y: 160)

            card
        }
        .ignoresSafeArea()
        .onAppear { focused = .email }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Sign in")
                .font(.fredoka(40))
                .foregroundStyle(Color.ink)

            Caption("Caregivers only, once per iPad. Children never see this screen.", size: 14)
                .padding(.top, 8)

            LabeledField(label: "Email", isFocused: focused == .email) {
                TextField("you@home.com", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focused = .password }
            }
            .padding(.top, 22)

            LabeledField(label: "Password", isFocused: focused == .password) {
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .focused($focused, equals: .password)
                    .submitLabel(.go)
                    .onSubmit(signIn)
            }
            .padding(.top, 12)

            if let error = authManager.error {
                Text(error)
                    .font(.figtree(13))
                    .foregroundStyle(Color.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .sticker(.categoryNegation, radius: 12)
                    .padding(.top, 12)
            }

            Button(action: signIn) {
                HStack(spacing: 10) {
                    if authManager.isLoading { ProgressView().tint(.white) }
                    Text("Sign in")
                }
                .font(.fredoka(22))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .sticker(.actionBlue, radius: 16)
                .contentShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(StickerPressStyle())
            .disabled(!canSubmit)
            .opacity(canSubmit || authManager.isLoading ? 1 : 0.6)
            .padding(.top, 20)
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 34)
        .frame(width: 520)
        .sticker(.paper, radius: 16)
        .compositingGroup()
        .shadow(color: Color.ink.opacity(0.18), radius: 14, y: 10)
    }

    private func signIn() {
        guard canSubmit else { return }
        focused = nil
        Task { await authManager.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password) }
    }
}

private struct LabeledField<Content: View>: View {
    let label: String
    let isFocused: Bool
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(.figtree(10))
                .tracking(1)
                .foregroundStyle(Color.ink.opacity(0.86))
            content
                .font(.figtree(19, .bold))
                .foregroundStyle(Color.ink)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sticker(.paper, radius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.actionBlue, lineWidth: 2)
                .padding(-4)
                .opacity(isFocused ? 1 : 0)
        )
    }
}

#Preview {
    LoginView().previewAllEnvironments(isSignedIn: false)
}
