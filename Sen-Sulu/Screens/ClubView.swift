import SwiftUI
import UIKit
import CoreImage
import CoreGraphics
import CoreImage.CIFilterBuiltins

struct ClubView: View {
    @Environment(AppState.self) private var state
    let isRoot: Bool
    @State private var showQR = false
    @State private var cardIn = false

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    if !isRoot { BackButton(boxed: false).padding(.leading, -12) }
                    VStack(alignment: .leading, spacing: 6) {
                        Caps("Сұлу Club", size: 22, weight: .medium, spacing: 0.3)
                        Text("Баллы за каждый заказ в приложении").font(.mont(11)).foregroundStyle(Color.ssMuted)
                    }
                }
                .padding(.top, 18)

                card
                    .padding(.top, 24)
                    .rotation3DEffect(.degrees(cardIn ? 0 : 12), axis: (x: 1, y: 0, z: 0))
                    .opacity(cardIn ? 1 : 0)
                    .offset(y: cardIn ? 0 : 20)

                VStack(spacing: 8) {
                    HStack {
                        Text("До уровня Platinum").font(.mont(11)).foregroundStyle(Color.ssBody2)
                        Spacer()
                        Text("62%").font(.mont(11)).foregroundStyle(Color.ssBody2)
                    }
                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color.ssLine)
                            Rectangle().fill(Color.ssInk).frame(width: g.size.width * (cardIn ? 0.62 : 0))
                        }
                    }
                    .frame(height: 3)
                }
                .padding(.top, 20)

                SSButton(title: showQR ? "Скрыть QR-код" : "Показать QR в магазине", style: .outline, height: 52) {
                    withAnimation(.spring(duration: 0.4)) { showQR.toggle() }
                }
                .padding(.top, 20)

                if showQR {
                    VStack(spacing: 10) {
                        QRImage(text: "SENSULU-CLUB-\(state.phone)")
                            .frame(width: 160, height: 160)
                        Text("Покажи в магазине-партнёре Sen Sulu").font(.mont(11)).foregroundStyle(Color.ssBody2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(Color.ssBlush)
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .top)))
                }

                SectionLabel(text: "Привилегии Gold").padding(.top, 28)
                VStack(spacing: 0) {
                    perk("01", "Баллы с каждой покупки")
                    perk("02", "Ранний доступ к новым коллекциям")
                    perk("03", "Подарок ко дню рождения")
                    perk("04", "Приглашения на съёмки Sen Sulu Talk", last: true)
                }
                .padding(.top, 6)

                VStack(alignment: .leading, spacing: 8) {
                    Caps("Вместе с Sen Sulu", size: 10, spacing: 0.3, color: .ssMuted)
                    Text("Помогаем тем, кому это нужно").font(.serif(24)).foregroundStyle(Color.ssInk)
                    Text("Каждый месяц бренд поддерживает центр помощи женщинам в Астане, дом престарелых и детский дом.")
                        .font(.mont(12)).lineSpacing(4).foregroundStyle(Color.ssBody2)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.ssBlush)
                .padding(.top, 18)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(Color.ssIvory)
        .onAppear { withAnimation(.spring(duration: 0.8, bounce: 0.25).delay(0.1)) { cardIn = true } }
        .sensoryFeedback(.impact(weight: .light), trigger: showQR)
    }

    private var card: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                SMark(size: 34, color: .ssGold, line: 1.5)
                Spacer()
                Caps("Gold", size: 10, spacing: 0.34, color: .ssGold)
            }
            Spacer()
            HStack(alignment: .center, spacing: 12) {
                BonusIcon(size: 34, shimmer: true)
                Text(groupedNumber(state.points))
                    .font(.serif(40))
                    .foregroundStyle(Color.ssIvory)
                    .contentTransition(.numericText(value: Double(state.points)))
            }
            Caps("Баллов · \(state.name) К.", size: 11, spacing: 0.16, color: .ssSand)
                .padding(.top, 4)
        }
        .padding(22)
        .frame(height: 214)
        .background(Color.ssInk)
        .overlay(Rectangle().stroke(Color.ssGold, lineWidth: 1))
        .modifier(TiltCard())
    }

    private func perk(_ n: String, _ text: String, last: Bool = false) -> some View {
        HStack(spacing: 14) {
            Text(n).font(.mont(11)).foregroundStyle(Color.ssMuted2)
            Text(text).font(.mont(13)).foregroundStyle(Color.ssInk)
            Spacer()
            if n == "01" {
                HStack(spacing: 4) {
                    Text("5%").font(.mont(11, .medium)).foregroundStyle(Color.ssInk)
                    BonusIcon(size: 16)
                }
            }
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) { if !last { Rectangle().fill(Color.ssLine).frame(height: 1) } }
    }
}

struct QRImage: View {
    let text: String

    var body: some View {
        if let img = Self.make(text) {
            Image(uiImage: img).interpolation(.none).resizable().scaledToFit()
        } else {
            Rectangle().fill(Color.ssInk)
        }
    }

    static func make(_ string: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 10, y: 10)) else { return nil }
        let ctx = CIContext()
        guard let cg = ctx.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}
