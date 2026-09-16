import SwiftUI

struct BoardHeader: View {
    let kidName: String
    let room: Room?
    let roomWordCount: Int
    let isPanelOpen: Bool
    let sentence: [Word]
    let onOpenPanel: () -> Void
    let onSpeak: () -> Void
    let onDeleteLast: () -> Void
    let onSettings: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            KidChip(name: kidName)

            Button(action: onSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.ink)
                    .frame(width: 48, height: 48)
                    .background(Color.paper, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.ink, lineWidth: 2))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")

            if let room {
                RoomChip(room: room, wordCount: roomWordCount, isPanelOpen: isPanelOpen, onOpen: onOpenPanel)
            }

            Spacer(minLength: 14)
            SentenceStrip(sentence: sentence, onSpeak: onSpeak, onDeleteLast: onDeleteLast)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .background(Color.butter)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.ink).frame(height: 2)
        }
    }
}

#Preview {
    BoardHeader(kidName: "Katerina", room: Room.mocks[0], roomWordCount: 13, isPanelOpen: true, sentence: AACVocabulary.defaultBoardWords, onOpenPanel: {}, onSpeak: {}, onDeleteLast: {}, onSettings: {})
}
