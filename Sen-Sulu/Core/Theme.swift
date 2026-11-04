import SwiftUI
import UIKit
import CoreText

// MARK: - Brand colors (taken from sen-sulu.com and the packaging)

extension Color {
    nonisolated init(hex: UInt32, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }

    static let ssInk = Color(hex: 0x111111)
    static let ssIvory = Color(hex: 0xFEFDFB)
    static let ssBlush = Color(hex: 0xFDF8F5)
    static let ssGold = Color(hex: 0xC9A962)
    static let ssRose = Color(hex: 0xE8B4B8)
    static let ssBurgundy = Color(hex: 0x5A1A1F)
    static let ssLine = Color(hex: 0xECE6E1)
    static let ssLine2 = Color(hex: 0xDCD5CF)
    static let ssTile = Color(hex: 0xF1ECE8)
    static let ssMuted = Color(hex: 0x6B6461)
    static let ssMuted2 = Color(hex: 0x8A827D)
    static let ssBody2 = Color(hex: 0x5E5753)
    static let ssBody3 = Color(hex: 0x3D3936)
    static let ssSand = Color(hex: 0xCFC7C1)
}

// MARK: - Fonts (Montserrat + Cormorant Garamond, bundled as TTF)

enum SSFonts {
    static let files = [
        "Montserrat-Light", "Montserrat-Regular", "Montserrat-Medium", "Montserrat-SemiBold",
        "CormorantGaramond-Regular", "CormorantGaramond-Italic", "CormorantGaramond-MediumItalic"
    ]

    static func register() {
        for name in files {
            let url = Bundle.main.url(forResource: name, withExtension: "ttf")
                ?? Bundle.main.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts")
                ?? Bundle.main.url(forResource: name, withExtension: "ttf", subdirectory: "Resources/Fonts")
            if let url {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }
}

enum MW {
    case light, regular, medium, semibold

    var fontName: String {
        switch self {
        case .light: return "Montserrat-Light"
        case .regular: return "Montserrat-Regular"
        case .medium: return "Montserrat-Medium"
        case .semibold: return "Montserrat-SemiBold"
        }
    }
}

extension Font {
    static func mont(_ size: CGFloat, _ weight: MW = .regular) -> Font {
        .custom(weight.fontName, fixedSize: size)
    }

    /// Cormorant Garamond italic — the brand's display voice.
    static func serif(_ size: CGFloat, medium: Bool = false) -> Font {
        .custom(medium ? "CormorantGaramond-MediumItalic" : "CormorantGaramond-Italic", fixedSize: size)
    }
}

/// Wide-tracked uppercase label, the way the site sets its navigation and section titles.
struct Caps: View {
    let text: String
    var size: CGFloat = 11
    var weight: MW = .regular
    var spacing: CGFloat = 0.24
    var color: Color = .ssInk

    init(_ text: String, size: CGFloat = 11, weight: MW = .regular, spacing: CGFloat = 0.24, color: Color = .ssInk) {
        self.text = text
        self.size = size
        self.weight = weight
        self.spacing = spacing
        self.color = color
    }

    var body: some View {
        Text(text.uppercased())
            .font(.mont(size, weight))
            .tracking(size * spacing)
            .foregroundStyle(color)
    }
}

// MARK: - Formatting

func tenge(_ value: Int) -> String {
    let digits = String(abs(value))
    var out = ""
    for (i, ch) in digits.reversed().enumerated() {
        if i > 0 && i % 3 == 0 { out.append(" ") }
        out.append(ch)
    }
    return (value < 0 ? "− " : "") + String(out.reversed()) + " ₸"
}

func groupedNumber(_ value: Int) -> String {
    tenge(value).replacingOccurrences(of: " ₸", with: "")
}
