import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager

    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    @FocusState private var focusedField: LoginField?

    enum LoginField { case email, password }

    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
            VStack(spacing: 32) {
                Spacer(minLength: 48)
                    // Hero
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 110, height: 110)
                                .shadow(color: Color(hex: "#FF9F43").opacity(0.35), radius: 20, x: 0, y: 8)
                            Image(systemName: "person.wave.2.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.white)
                        }

                        Text("AAC Board")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(Color(hex: "#1A1A2E"))

                        Text("Location-Aware Communication")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "#9CA3AF"))
                    }

                    // Form card
                    VStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("Hey there! 👋")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundStyle(Color(hex: "#1A1A2E"))
                            Text("Sign in to manage your board")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(hex: "#9CA3AF"))
                        }

                        if let error = authManager.error {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(Color(hex: "#D63031"))
                                Text(error)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color(hex: "#D63031"))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "#FF7675").opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        VStack(spacing: 12) {
                            AuthTextField(
                                icon: "envelope.fill",
                                placeholder: "Email",
                                text: $email,
                                isFocused: focusedField == .email
                            )
                            .focused($focusedField, equals: .email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }

                            AuthTextField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $password,
                                isSecure: true,
                                isFocused: focusedField == .password
                            )
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit {
                                if !email.isEmpty && !password.isEmpty {
                                    Task { await authManager.signIn(email: email, password: password) }
                                }
                            }
                        }

                        Button {
                            Task { await authManager.signIn(email: email, password: password) }
                        } label: {
                            Group {
                                if authManager.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Let's Go!")
                                        .font(.system(size: 17, weight: .black, design: .rounded))
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color(hex: "#FF9F43").opacity(0.35), radius: 12, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)

                        Button {
                            showRegister = true
                        } label: {
                            Text("Don't have an account? **Create one**")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(Color(hex: "#FF9F43"))
                        }
                    }
                    .padding(28)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .black.opacity(0.08), radius: 32, x: 0, y: 12)
                    .frame(maxWidth: 440)
                    .id("form")

                    Spacer(minLength: 48)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
                .onChange(of: focusedField) { _, value in
                    if value != nil {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { proxy.scrollTo("form", anchor: .center) }
                    }
                }
            }
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AuthBackground())
            .overlay(alignment: .bottomTrailing) {
                AuthFloatingShapes()
                    .frame(width: 120, height: 110)
                    .padding(.trailing, 32)
                    .padding(.bottom, 32)
                    .allowsHitTesting(false)
            }
            .fullScreenCover(isPresented: $showRegister) {
                RegisterView()
            }
    }
}

// MARK: - Previews

#Preview("Empty") {
    LoginView()
        .previewAllEnvironments(isSignedIn: false)
}

#Preview("Error") {
    LoginView()
        .previewAllEnvironments(isSignedIn: false, authError: "Invalid email or password.")
}
