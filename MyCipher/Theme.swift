import SwiftUI

enum Theme {
    static let background = Color(white: 0.05)
    static let card = Color(white: 0.12)
    static let accent = Color(red: 0.62, green: 0.38, blue: 1.0)
}

/// 背景：黒＋ぼんやりした紫の光。Liquid Glass はこの上で透けて見える
struct AppBackdrop: View {
    var body: some View {
        ZStack {
            Theme.background
            Circle().fill(Theme.accent.opacity(0.35))
                .frame(width: 320, height: 320).blur(radius: 90)
                .offset(x: -120, y: -260)
            Circle().fill(Color.indigo.opacity(0.25))
                .frame(width: 280, height: 280).blur(radius: 90)
                .offset(x: 140, y: 300)
        }
        .ignoresSafeArea()
    }
}

/// カード：iOS 26 以降は Liquid Glass、それ以前は通常の濃いグレー
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        let padded = content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        if #available(iOS 26.0, *) {
            padded.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
        } else {
            padded
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

extension View {
    func card() -> some View { modifier(CardModifier()) }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let label = configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundColor(.white)
        if #available(iOS 26.0, *) {
            label.glassEffect(.regular.tint(Theme.accent).interactive(),
                              in: RoundedRectangle(cornerRadius: 16))
        } else {
            label
                .background(Theme.accent.opacity(configuration.isPressed ? 0.7 : 1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let label = configuration.label
            .font(.subheadline)
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundColor(Theme.accent)
        if #available(iOS 26.0, *) {
            label.glassEffect(.regular.interactive(),
                              in: RoundedRectangle(cornerRadius: 14))
        } else {
            label
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .opacity(configuration.isPressed ? 0.6 : 1)
        }
    }
}

struct DisclaimerView: View {
    var body: some View {
        Text("⚠️ この暗号は創作・文字変換・遊びのためのものです。本格的なセキュリティ（機密情報の保護）は保証しません。")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal, 4)
    }
}
