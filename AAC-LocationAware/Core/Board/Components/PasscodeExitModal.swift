import SwiftUI

struct PasscodeModal: View {
    let correctPasscode: String
    var message: String = "Enter your 4-digit passcode"
    let onSuccess: () -> Void
    let onCancel: () -> Void

    @State private var entered = ""
    @State private var shake = false
    @State private var errorMessage = ""
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("Enter Passcode")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#1A1A2E"))
                    Text(message)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                }

                ZStack {
                    TextField("", text: $entered)
                        .keyboardType(.numberPad)
                        .frame(width: 1, height: 1)
                        .opacity(0.01)
                        .focused($focused)
                        .onChange(of: entered) { _, val in
                            let filtered = String(val.filter(\.isNumber).prefix(4))
                            entered = filtered
                            errorMessage = ""
                            if filtered.count == 4 { verify() }
                        }

                    HStack(spacing: 16) {
                        ForEach(0..<4, id: \.self) { i in
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        errorMessage.isEmpty ? Color(hex: "#E5E7EB") : Color(hex: "#FF6B6B"),
                                        lineWidth: 2
                                    )
                                    .frame(width: 56, height: 64)
                                    .background(Color(hex: "#F9FAFB"), in: RoundedRectangle(cornerRadius: 10))

                                if i < entered.count {
                                    Circle()
                                        .fill(Color(hex: "#1A1A2E"))
                                        .frame(width: 14, height: 14)
                                }
                            }
                        }
                    }
                    .offset(x: shake ? -8 : 0)
                    .animation(shake ? .default.repeatCount(4, autoreverses: true).speed(6) : .default, value: shake)
                }
                .onTapGesture { focused = true }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#FF6B6B"))
                }

                Button("Cancel") { onCancel() }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#9CA3AF"))
            }
            .padding(32)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(0.2), radius: 48, x: 0, y: 20)
            .frame(maxWidth: 340)
            .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { Task { @MainActor in focused = true } }
    }

    private func verify() {
        if entered == correctPasscode {
            onSuccess()
        } else {
            shake = true
            errorMessage = "Incorrect passcode"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shake = false
                entered = ""
            }
        }
    }
}

#Preview {
    PasscodeModal(
        correctPasscode: "1234",
        onSuccess: {},
        onCancel: {}
    )
}
