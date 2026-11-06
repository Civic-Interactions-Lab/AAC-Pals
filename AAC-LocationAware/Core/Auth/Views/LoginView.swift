import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager

    private enum Mode { case signIn, signUp }
    private enum Field { case email, password, confirm }

    private static let minimumPasswordLength = 6

    @State private var mode: Mode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @FocusState private var focused: Field?

    private var trimmedEmail: String { email.trimmingCharacters(in: .whitespaces) }

    private var validationMessage: String? {
        guard mode == .signUp else { return nil }
        if !password.isEmpty, password.count < Self.minimumPasswordLength {
            return "Password needs at least \(Self.minimumPasswordLength) characters."
        }
        if !confirmPassword.isEmpty, confirmPassword != password {
            return "Passwords don't match."
        }
        return nil
    }

    private var canSubmit: Bool {
        guard !trimmedEmail.isEmpty, !password.isEmpty, !authManager.isLoading else { return false }
        if mode == .signUp {
            return password.count >= Self.minimumPasswordLength && confirmPassword == password
        }
        return true
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                card
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDismissesKeyboard(.interactively)
        }
        .background {
            ZStack {
                Color.paper
                Circle()
                    .fill(Color.butter)
                    .frame(width: 360, height: 360)
                    .position(x: 30, y: 30)
                Circle()
                    .fill(Color.signalGreen.opacity(0.75))
                    .frame(width: 400, height: 400)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .offset(x: 140, y: 160)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            authManager.clearMessages()
            focused = .email
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(mode == .signIn ? "Sign in" : "Create account")
                .font(.fredoka(40))
                .foregroundStyle(Color.ink)

            Caption(
                mode == .signIn
                    ? "Caregivers only, once per iPad. Children never see this screen."
                    : "One caregiver account holds every child's profile and usage history.",
                size: 14
            )
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
                SecureField(mode == .signUp ? "At least \(Self.minimumPasswordLength) characters" : "Password", text: $password)
                    .textContentType(mode == .signUp ? .newPassword : .password)
                    .focused($focused, equals: .password)
                    .submitLabel(mode == .signUp ? .next : .go)
                    .onSubmit {
                        if mode == .signUp { focused = .confirm } else { submit() }
                    }
            }
            .padding(.top, 12)

            if mode == .signUp {
                LabeledField(label: "Confirm password", isFocused: focused == .confirm) {
                    SecureField("Type it again", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .focused($focused, equals: .confirm)
                        .submitLabel(.go)
                        .onSubmit(submit)
                }
                .padding(.top, 12)
            }

            if let message = validationMessage ?? authManager.error {
                banner(message, fill: .categoryNegation)
            } else if let notice = authManager.notice {
                banner(notice, fill: .signalGreen)
            }

            Button { submit() } label: {
                HStack(spacing: 10) {
                    if authManager.isLoading { ProgressView().tint(.white) }
                    Text(mode == .signIn ? "Sign in" : "Create account")
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

            HStack(spacing: 6) {
                Text(mode == .signIn ? "New here?" : "Already have an account?")
                    .font(.figtree(14, .semibold))
                    .foregroundStyle(Color.ink.opacity(0.86))
                Button { switchMode() } label: {
                    Text(mode == .signIn ? "Create an account" : "Sign in")
                        .font(.figtree(14))
                        .foregroundStyle(Color.actionBlue)
                }
                .buttonStyle(.plain)
                .disabled(authManager.isLoading)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 34)
        .frame(width: 520)
        .sticker(.paper, radius: 16)
        .compositingGroup()
        .shadow(color: Color.ink.opacity(0.18), radius: 14, y: 10)
        .animation(.easeInOut(duration: 0.2), value: mode)
    }

    private func banner(_ text: String, fill: Color) -> some View {
        Text(text)
            .font(.figtree(13))
            .foregroundStyle(Color.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .sticker(fill, radius: 12)
            .padding(.top, 12)
    }

    private func switchMode() {
        mode = mode == .signIn ? .signUp : .signIn
        password = ""
        confirmPassword = ""
        authManager.clearMessages()
        focused = .email
    }

    private func submit() {
        guard canSubmit else { return }
        focused = nil
        Task {
            switch mode {
            case .signIn:
                await authManager.signIn(email: trimmedEmail, password: password)
            case .signUp:
                let created = await authManager.signUp(email: trimmedEmail, password: password)
                if created, !authManager.isSignedIn {
                    mode = .signIn
                    password = ""
                    confirmPassword = ""
                }
            }
        }
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
