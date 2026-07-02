import SwiftUI

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var isFocused = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(hex: "#FF9F43"))
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundStyle(Color(hex: "#1A1A2E"))
            } else {
                TextField(placeholder, text: $text)
                    .foregroundStyle(Color(hex: "#1A1A2E"))
            }
        }
        .font(.system(size: 15, weight: .medium, design: .rounded))
        .tint(Color(hex: "#FF9F43"))
        .padding(15)
        .background(Color(hex: "#FFF7EE"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    isFocused ? Color(hex: "#FF9F43") : Color(hex: "#FF9F43").opacity(0.25),
                    lineWidth: isFocused ? 2 : 1.5
                )
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        AuthTextField(icon: "envelope.fill", placeholder: "Email", text: .constant(""))
        AuthTextField(icon: "envelope.fill", placeholder: "Email", text: .constant("jaime@example.com"), isFocused: true)
        AuthTextField(icon: "lock.fill", placeholder: "Password", text: .constant("secret"), isSecure: true)
    }
    .padding(24)
    .frame(width: 360)
}
