import SwiftUI
import UIKit

// MARK: - Brand mark

struct SMark: View {
    var size: CGFloat = 24
    var color: Color = .ssInk
    var line: CGFloat = 1.3

    var body: some View {
        Text("S")
            .font(.mont(size * 0.6, .semibold))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .overlay(Rectangle().stroke(color, lineWidth: line))
    }
}

struct LogoLockup: View {
    var color: Color = .ssInk
    var markSize: CGFloat = 24
    var vertical = false

    var body: some View {
        let word = Text("sen sulu").font(.mont(11)).tracking(11 * 0.42).foregroundStyle(color)
        if vertical {
            VStack(spacing: 8) { SMark(size: markSize, color: color, line: 1.5); word }
        } else {
            HStack(spacing: 10) { SMark(size: markSize, color: color); word }
        }
    }
}

// MARK: - Buttons

/// Replacement for `.plain`: no styling, but the full frame (including transparent padding) receives taps.
struct FlatStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct SSButton: View {
    enum Style { case filled, outline, filledLight, outlineLight }
    let title: String
    var style: Style = .filled
    var height: CGFloat = 54
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.mont(12, style == .filled || style == .filledLight ? .semibold : .regular))
                .tracking(12 * 0.2)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .foregroundStyle(fg)
                .background(bg)
                .overlay(Rectangle().stroke(stroke, lineWidth: 1))
                .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
    }

    private var fg: Color {
        switch style {
        case .filled: return .ssIvory
        case .outline: return .ssInk
        case .filledLight: return .ssInk
        case .outlineLight: return .ssIvory
        }
    }
    private var bg: Color {
        switch style {
        case .filled: return .ssInk
        case .filledLight: return .ssIvory
        default: return .clear
        }
    }
    private var stroke: Color {
        switch style {
        case .filled: return .ssInk
        case .outline: return .ssInk
        case .filledLight: return .ssIvory
        case .outlineLight: return .ssIvory
        }
    }
}

/// Subtle press feedback used across the app. The whole frame is tappable, not just the text.
struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SquareIconButton: View {
    let systemName: String
    var filled = false
    var label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(Color.ssInk)
                .frame(width: 44, height: 44)
                .background(Color.ssIvory)
                .overlay(Rectangle().stroke(Color.ssLine, lineWidth: 1))
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(label)
    }
}

/// Custom back button (system navigation bar is hidden to match the design; swipe-back still works).
struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    var boxed = true
    var color: Color = .ssInk

    var body: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(boxed ? Color.ssIvory : .clear)
                .overlay(Rectangle().stroke(boxed ? Color.ssLine : .clear, lineWidth: 1))
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel("Назад")
    }
}

struct ScreenHeader: View {
    let title: String
    var trailing: AnyView? = nil

    var body: some View {
        HStack(spacing: 8) {
            BackButton(boxed: false)
            Caps(title, size: 18, weight: .medium, spacing: 0.3)
            Spacer()
            if let trailing { trailing }
        }
        .padding(.leading, 12)
        .padding(.trailing, 16)
        .padding(.top, 8)
    }
}

// MARK: - Chips

struct Chip: View {
    let title: String
    let selected: Bool
    var height: CGFloat = 36
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.mont(11))
                .tracking(11 * 0.14)
                .padding(.horizontal, 14)
                .frame(height: height)
                .foregroundStyle(selected ? Color.ssIvory : Color.ssInk)
                .background(selected ? Color.ssInk : Color.clear)
                .overlay(Rectangle().stroke(selected ? Color.ssInk : Color.ssLine2, lineWidth: 1))
        }
        .buttonStyle(PressStyle())
        .sensoryFeedback(.selection, trigger: selected)
    }
}

struct SegmentedRow: View {
    let options: [(String, String)]
    @Binding var selection: String
    var dark = false

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.0) { opt in
                let on = selection == opt.0
                Button {
                    withAnimation(.easeOut(duration: 0.18)) { selection = opt.0 }
                } label: {
                    Text(opt.1)
                        .font(.mont(12))
                        .tracking(12 * 0.12)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .foregroundStyle(on ? Color.ssIvory : (dark ? Color.ssSand : Color.ssInk))
                        .background(on ? (dark ? Color(hex: 0x2A2725) : Color.ssInk) : Color.clear)
                }
                .buttonStyle(FlatStyle())
            }
        }
        .overlay(Rectangle().stroke(dark ? Color(hex: 0x3A3633) : Color.ssLine2, lineWidth: 1))
        .sensoryFeedback(.selection, trigger: selection)
    }
}

// MARK: - Product imagery

struct ProductImage: View {
    let name: String?
    var fill = false

    var body: some View {
        ZStack {
            Color.white
            if let name {
                if fill {
                    Image(name).resizable().scaledToFill()
                } else {
                    Image(name).resizable().scaledToFit()
                }
            } else {
                VStack(spacing: 10) {
                    SMark(size: 34, color: Color(hex: 0xB9A27A), line: 1.2)
                    Text("sen sulu").font(.mont(9)).tracking(9 * 0.4).foregroundStyle(Color(hex: 0xB9A27A))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.ssBlush)
            }
        }
        .clipped()
    }
}

struct ProductCard: View {
    let product: Product
    var width: CGFloat? = nil
    var height: CGFloat = 214

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ProductImage(name: product.image, fill: product.kind == .box)
                .frame(width: width, height: height)
                .frame(maxWidth: width == nil ? .infinity : nil)
                .overlay(Rectangle().stroke(Color.ssTile, lineWidth: 1))
                .overlay(alignment: .topLeading) {
                    if product.hit {
                        Caps("Хит", size: 9, spacing: 0.2, color: .ssIvory)
                            .padding(.horizontal, 7).padding(.vertical, 4)
                            .background(Color.ssInk)
                            .padding(10)
                    }
                }
            Caps(product.category, size: 9, spacing: 0.24, color: .ssMuted)
            Text(product.name).font(.mont(12)).foregroundStyle(Color.ssInk).lineLimit(2)
            Text(product.kind == .box ? product.subtitle : product.shadeLine(product.shades.isEmpty ? nil : product.defaultShade))
                .font(.mont(11)).foregroundStyle(Color.ssMuted).lineLimit(1)
            Text(tenge(product.price)).font(.mont(13, .medium)).foregroundStyle(Color.ssInk)
        }
        .frame(width: width, alignment: .leading)
        .contentShape(Rectangle())
    }
}

struct SectionLabel: View {
    let text: String
    var body: some View {
        Caps(text, size: 11, weight: .medium, spacing: 0.24)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RowLink: View {
    let title: String
    var subtitle: String? = nil
    var trailing: String = "→"

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.mont(13)).foregroundStyle(Color.ssInk)
                if let subtitle { Text(subtitle).font(.mont(11)).foregroundStyle(Color.ssMuted) }
            }
            Spacer()
            Text(trailing).font(.mont(12)).foregroundStyle(Color.ssInk)
        }
        .padding(.horizontal, 24)
        .frame(minHeight: 54)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }
    }
}

struct SSToggle: View {
    @Binding var isOn: Bool
    var onColor: Color = .ssInk
    var offColor: Color = .ssSand

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.25)) { isOn.toggle() }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule().fill(isOn ? onColor : offColor).frame(width: 48, height: 28)
                Circle().fill(Color.ssIvory).frame(width: 22, height: 22).padding(.horizontal, 3)
            }
        }
        .buttonStyle(FlatStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: isOn)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(isOn ? "Вкл" : "Выкл")
    }
}

// MARK: - Swipe back with hidden navigation bar

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}

// MARK: - Helpers

extension View {
    func hideNavBar() -> some View {
        self.toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Bonus mark ("Сұлу балл")

struct BonusIcon: View {
    var size: CGFloat = 18
    var shimmer = false
    @State private var phase: CGFloat = -1

    var body: some View {
        Image("bonus")
            .resizable()
            .interpolation(.high)
            .frame(width: size, height: size)
            .overlay {
                if shimmer {
                    LinearGradient(colors: [.clear, .white.opacity(0.55), .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: size * 0.45)
                        .rotationEffect(.degrees(20))
                        .offset(x: phase * size)
                        .blendMode(.plusLighter)
                        .mask(Circle())
                }
            }
            .onAppear {
                guard shimmer else { return }
                withAnimation(.easeInOut(duration: 1.6).delay(0.6).repeatForever(autoreverses: false)) { phase = 1.2 }
            }
            .accessibilityHidden(true)
    }
}

// MARK: - Interactive card: 3D tilt toward the finger, moving gloss, rubber-band pull, spring back

struct TiltCard: ViewModifier {
    @State private var tilt: CGSize = .zero        // -1...1
    @State private var pull: CGSize = .zero
    @State private var touch: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var active = false
    @State private var size: CGSize = CGSize(width: 340, height: 214)
    var maxAngle: Double = 14

    func body(content: Content) -> some View {
            content
                .onGeometryChange(for: CGSize.self) { $0.size } action: { size = $0 }
                .overlay {
                    // gloss that follows the finger
                    RadialGradient(colors: [Color.white.opacity(active ? 0.28 : 0), .clear],
                                   center: UnitPoint(x: touch.x, y: touch.y),
                                   startRadius: 0, endRadius: size.width * 0.75)
                        .blendMode(.plusLighter)
                        .allowsHitTesting(false)
                }
                .overlay {
                    // thin gold sheen sweeping with the tilt
                    LinearGradient(colors: [.clear, Color.ssGold.opacity(active ? 0.22 : 0), .clear],
                                   startPoint: UnitPoint(x: 0.2 - tilt.width * 0.4, y: 0),
                                   endPoint: UnitPoint(x: 0.8 - tilt.width * 0.4, y: 1))
                        .blendMode(.plusLighter)
                        .allowsHitTesting(false)
                }
                .rotation3DEffect(.degrees(Double(-tilt.height) * maxAngle), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
                .rotation3DEffect(.degrees(Double(tilt.width) * maxAngle), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
                .scaleEffect(active ? 1.03 : 1)
                .offset(pull)
                .shadow(color: .black.opacity(active ? 0.28 : 0.12), radius: active ? 22 : 10,
                        x: -tilt.width * 10, y: 10 + tilt.height * 6)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { v in
                            let w = max(size.width, 1), h = max(size.height, 1)
                            let x = min(max(v.location.x / w, 0), 1), y = min(max(v.location.y / h, 0), 1)
                            withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.75)) {
                                active = true
                                touch = CGPoint(x: x, y: y)
                                tilt = CGSize(width: (x - 0.5) * 2, height: (y - 0.5) * 2)
                                // rubber band: moves a little, resists more the further you pull
                                let rb: (CGFloat) -> CGFloat = { d in (d >= 0 ? 1 : -1) * 40 * (1 - exp(-abs(d) / 120)) }
                                pull = CGSize(width: rb(v.translation.width), height: rb(v.translation.height))
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.55, dampingFraction: 0.45)) {
                                active = false
                                tilt = .zero
                                pull = .zero
                                touch = CGPoint(x: 0.5, y: 0.5)
                            }
                        }
                )
                .sensoryFeedback(.impact(weight: .light), trigger: active)
    }
}
