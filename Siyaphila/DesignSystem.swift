import SwiftUI

enum DemoTheme {
    static let background = Color(hex: "F3F6FB")
    static let surface = Color.white
    static let ink = Color(hex: "132238")
    static let secondary = Color(hex: "6C7892")
    static let blue = Color(hex: "2F6BFF")
    static let violet = Color(hex: "7A63FF")
    static let mint = Color(hex: "35C98A")
    static let amber = Color(hex: "FFB648")
    static let coral = Color(hex: "FF7A59")
}

extension Color {
    init(hex: String) {
        let cleaned = hex.replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let r, g, b, a: UInt64
        switch cleaned.count {
        case 8:
            (r, g, b, a) = ((value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)
        default:
            (r, g, b, a) = ((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF, 255)
        }

        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

extension LinearGradient {
    static let appBackground = LinearGradient(
        colors: [Color(hex: "F9FBFF"), Color(hex: "F1F5FF"), Color(hex: "F7F8FC")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct SurfaceCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(DemoTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color.black.opacity(0.07), radius: 18, x: 0, y: 14)
    }
}

extension View {
    func surfaceCard() -> some View {
        modifier(SurfaceCard())
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(DemoTheme.ink)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(DemoTheme.secondary)
            }
        }
    }
}

struct StatusChip: View {
    let title: String
    let color: Color
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
            Text(title)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

struct ProgressRing: View {
    let title: String
    let value: Int
    let tint: Color
    var suffix: String = "%"

    private var progress: CGFloat {
        min(max(CGFloat(value) / 100, 0), 1)
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(tint.opacity(0.14), lineWidth: 14)
                    .frame(width: 102, height: 102)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(colors: [tint.opacity(0.35), tint, tint.opacity(0.85)], center: .center),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 102, height: 102)

                VStack(spacing: 2) {
                    Text("\(value)\(suffix)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(DemoTheme.ink)
                    Text(title)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(DemoTheme.secondary)
                }
            }
        }
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let subtitle: String
    let tint: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DemoTheme.secondary)
                Spacer()
            }
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(DemoTheme.ink)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(DemoTheme.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct GradientHeroCard<Content: View>: View {
    let colors: [Color]
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .shadow(color: colors.first?.opacity(0.24) ?? .clear, radius: 24, x: 0, y: 16)
    }
}
