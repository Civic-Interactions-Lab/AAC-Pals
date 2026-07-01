import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager

    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#FF6B6B"), Color(hex: "#FF9F43"), Color(hex: "#FFEAA7")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Spacer(minLength: 40)

                    // Icon + title
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 110, height: 110)
                            Image(systemName: "person.wave.2.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                        }

                        Text("AAC Board")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        Text("Location-Aware Communication")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }

                    // Form card
                    VStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("Hey there!")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(Color(hex: "#2D3436"))
                            Text("Sign in to manage your board")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#636E72"))
                        }

                        if let error = authManager.error {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Color(hex: "#D63031"))
                                Text(error)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#D63031"))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "#FF7675").opacity(0.15))
                            .cornerRadius(14)
                        }

                        VStack(spacing: 12) {
                            FunTextField(icon: "envelope.fill", placeholder: "Email or username", text: $email)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)

                            FunTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
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
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#FF6B6B"), Color(hex: "#FF9F43")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(18)
                            .shadow(color: Color(hex: "#FF6B6B").opacity(0.4), radius: 10, x: 0, y: 4)
                        }
                        .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)

                        Button {
                            showRegister = true
                        } label: {
                            Text("Don't have an account? **Create one**")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color(hex: "#FF6B6B"))
                        }
                    }
                    .padding(28)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: .black.opacity(0.08), radius: 24, x: 0, y: 8)
                    .frame(maxWidth: 440)

                    Spacer(minLength: 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView()
        }
    }
}

private struct FunTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "#FF9F43"))
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(.system(size: 15, weight: .medium, design: .rounded))
        .padding(15)
        .background(Color(hex: "#F5F6FA"))
        .cornerRadius(14)
    }
}

#Preview("Empty") {
    LoginView()
        .previewAllEnvironments(isSignedIn: false)
}

#Preview("Error") {
    LoginView()
        .previewAllEnvironments(isSignedIn: false, authError: "Invalid email or password.")
}
