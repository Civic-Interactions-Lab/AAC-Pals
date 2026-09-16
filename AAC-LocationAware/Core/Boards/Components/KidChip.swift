import SwiftUI

struct KidChip: View {
    let name: String

    var body: some View {
        HStack(spacing: 11) {
            Text(name.prefix(1).uppercased())
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)
                .frame(width: 42, height: 42)
                .background(Color.categoryQuestion, in: Circle())
                .overlay(Circle().strokeBorder(Color.ink, lineWidth: 2))

            Text(name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)
        }
        .padding(.leading, 7)
        .padding(.trailing, 14)
        .padding(.vertical, 6)
        .background(Color.paper, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.ink, lineWidth: 2))
    }
}

#Preview {
    KidChip(name: "Katerina").padding().background(Color.butter)
}
