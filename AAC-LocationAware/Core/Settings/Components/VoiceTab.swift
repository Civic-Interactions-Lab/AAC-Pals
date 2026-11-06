import SwiftUI
import AVFoundation

struct VoiceTab: View {
    let kidName: String

    @AppStorage(VoiceSettings.voiceIdentifierKey) private var voiceIdentifier = ""
    @AppStorage(VoiceSettings.rateKey) private var rate = VoiceSettings.defaultRate
    @AppStorage(VoiceSettings.pitchKey) private var pitch = VoiceSettings.defaultPitch
    @AppStorage(VoiceSettings.volumeKey) private var volume = VoiceSettings.defaultVolume
    @AppStorage(VoiceSettings.speakEachTapKey) private var speakEachTap = VoiceSettings.defaultSpeakEachTap

    private let voices = SpeechManager.shared.englishVoices
    private let sampleText = "I want juice please"

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel("Voice")

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 9) {
                        voiceRow(name: "System default", meta: "The iPad's standard voice", identifier: "")
                        ForEach(voices, id: \.identifier) { voice in
                            voiceRow(name: voice.name, meta: meta(for: voice), identifier: voice.identifier)
                        }
                    }
                    .padding(2)
                }
            }
            .frame(maxWidth: .infinity)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    tryItCard
                    sliderCard("Speaking rate", value: $rate, range: 0.5...1.5, display: String(format: "%.2f×", rate))
                    sliderCard("Pitch", value: $pitch, range: 0.5...2, display: String(format: "%.2f", pitch))
                    sliderCard("Volume", value: $volume, range: 0...1, display: "\(Int((volume * 100).rounded()))%")
                    speakEachTapCard
                }
                .padding(2)
                .padding(.bottom, 4)
            }
            .frame(width: 320)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func voiceRow(name: String, meta: String, identifier: String) -> some View {
        let inUse = voiceIdentifier == identifier

        return Button {
            voiceIdentifier = identifier
            SpeechManager.shared.speak("Hello, \(kidName)")
        } label: {
            HStack(spacing: 12) {
                Button {
                    SpeechManager.shared.speak("Hello, \(kidName)", voiceIdentifier: identifier.isEmpty ? nil : identifier)
                } label: {
                    Image(systemName: "speaker.wave.1")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.ink)
                        .frame(width: 44, height: 44)
                        .sticker(.paper, radius: 14)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Play \(name)")

                VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                        .font(.fredoka(22))
                        .foregroundStyle(Color.ink)
                        .lineLimit(1)
                    Text(meta)
                        .font(.figtree(12, .bold))
                        .foregroundStyle(Color.ink.opacity(0.86))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Text(inUse ? "IN USE" : "USE")
                    .font(.figtree(11))
                    .tracking(0.7)
                    .foregroundStyle(Color.ink)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 7)
                    .sticker(.paper, radius: 14)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 11)
            .sticker(inUse ? .butter : .paper, radius: 18)
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(inUse ? .isSelected : [])
    }

    private func meta(for voice: AVSpeechSynthesisVoice) -> String {
        let region = Locale.current.localizedString(forIdentifier: voice.language) ?? voice.language
        let quality: String = switch voice.quality {
        case .premium:  "Premium"
        case .enhanced: "Enhanced"
        default:        "Standard"
        }
        return "\(region) · \(quality)"
    }

    private var tryItCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel("Try it")

            Text(sampleText)
                .font(.fredoka(22))
                .foregroundStyle(Color.ink)
                .padding(.top, 8)

            Button { SpeechManager.shared.speak(sampleText) } label: {
                HStack(spacing: 9) {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 18, weight: .semibold))
                    Text("PLAY SAMPLE")
                        .font(.figtree(12))
                        .tracking(0.8)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .sticker(.actionBlue, radius: 16)
                .contentShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(StickerPressStyle(shadowOpacity: 0.4))
            .padding(.top, 12)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .sticker(.paper, radius: 18)
    }

    private func sliderCard(_ label: String, value: Binding<Double>, range: ClosedRange<Double>, display: String) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                SectionLabel(label)
                Spacer()
                Text(display)
                    .font(.fredoka(17))
                    .foregroundStyle(Color.ink)
            }
            Slider(value: value, in: range)
                .tint(Color.actionBlue)
                .accessibilityLabel(label)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .sticker(.paper, radius: 18)
    }

    private var speakEachTapCard: some View {
        Button { speakEachTap.toggle() } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Speak each tap")
                        .font(.fredoka(17))
                        .foregroundStyle(Color.ink)
                    Text("Says the word as it lands in the bar")
                        .font(.figtree(11, .bold))
                        .foregroundStyle(Color.ink.opacity(0.86))
                }

                Spacer(minLength: 8)

                Capsule()
                    .fill(speakEachTap ? Color.signalGreen : Color.paper)
                    .overlay(Capsule().strokeBorder(Color.ink, lineWidth: 2))
                    .frame(width: 58, height: 32)
                    .overlay(alignment: speakEachTap ? .trailing : .leading) {
                        Circle()
                            .fill(Color.paper)
                            .overlay(Circle().strokeBorder(Color.ink, lineWidth: 2))
                            .frame(width: 22, height: 22)
                            .padding(.horizontal, 5)
                    }
                    .animation(.easeInOut(duration: 0.15), value: speakEachTap)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .sticker(.paper, radius: 18)
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Speak each tap")
        .accessibilityValue(speakEachTap ? "On" : "Off")
        .accessibilityAddTraits(.isToggle)
    }
}

#Preview {
    VoiceTab(kidName: "Katerina")
        .background(Color.paper)
}
