import SwiftUI

struct AdminUserFilterBar: View {
    let users: [UserProfile]
    @Binding var selectedUserId: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All Users", isActive: selectedUserId == nil) {
                    selectedUserId = nil
                }
                ForEach(users) { user in
                    FilterChip(label: user.displayName, isActive: selectedUserId == user.id) {
                        selectedUserId = user.id
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }
}

private struct FilterChip: View {
    let label: String
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                .foregroundStyle(isActive ? Color.white : Color(hex: "#1A1A2E").opacity(0.6))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isActive ? Color(hex: "#FF9F43") : Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isActive ? Color.clear : Color(hex: "#1A1A2E").opacity(0.15), lineWidth: 1))
        }
    }
}

#Preview {
    AdminUserFilterBar(users: UserProfile.mocks, selectedUserId: .constant("mock-user-1"))
        .padding(.vertical)
        .background(Color(hex: "#FFF7EE"))
}
