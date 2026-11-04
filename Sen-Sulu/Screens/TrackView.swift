import SwiftUI
import UIKit

struct TrackView: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var copied = false
    @State private var copyReset: Task<Void, Never>? = nil
    @State private var showReceipt = false

    var body: some View {
        VStack(spacing: 0) {
            if let order = state.order {
                header(order)
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0) {
                        trackBox(order)
                        timeline(order)
                        HStack(spacing: 8) {
                            SSButton(title: "Электронный чек", style: .outline, height: 52) { showReceipt = true }
                            SSButton(title: "WhatsApp", height: 52) { openURL(Links.whatsapp) }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(Color.ssIvory.ignoresSafeArea())
        .sensoryFeedback(.success, trigger: state.order?.stage ?? 0)
        .sheet(isPresented: $showReceipt) {
            if let order = state.order { ReceiptView(order: order).presentationDetents([.large]) }
        }
    }

    private func header(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 17, weight: .light)).foregroundStyle(Color.ssIvory)
                    .frame(width: 44, height: 44)
            }
            .padding(.leading, -12)
            .accessibilityLabel("Закрыть")
            Caps("Заказ \(order.number)", size: 10, spacing: 0.3, color: .ssGold)
            Text("Рахмет, \(state.name).").font(.serif(40)).foregroundStyle(Color.ssIvory)
            Text("Статус доставки — здесь. Трек-номер искать в переписке больше не нужно.")
                .font(.mont(12)).lineSpacing(4).foregroundStyle(Color.ssSand)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 26)
        .background(Color.ssInk.ignoresSafeArea(edges: .top))
    }

    private func trackBox(_ order: Order) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Caps("\(order.delivery == .cdek ? "СДЭК" : "Казпочта") · трек-номер", size: 10, spacing: 0.24, color: .ssMuted)
                Text(order.track).font(.mont(15)).tracking(15 * 0.08)
            }
            Spacer()
            Button {
                UIPasteboard.general.string = order.track.replacingOccurrences(of: " ", with: "")
                withAnimation(.snappy) { copied = true }
                copyReset?.cancel()
                copyReset = Task {
                    try? await Task.sleep(for: .seconds(1.8))
                    guard !Task.isCancelled else { return }
                    withAnimation(.snappy) { copied = false }
                }
            } label: {
                HStack(spacing: 6) {
                    if copied {
                        Image(systemName: "checkmark").font(.system(size: 10, weight: .medium))
                            .transition(.scale.combined(with: .opacity))
                    }
                    Caps(copied ? "Скопировано" : "Копировать", size: 11, spacing: 0.14)
                        .contentTransition(.opacity)
                }
                    .padding(.horizontal, 14)
                    .frame(height: 40)
                    .overlay(Rectangle().stroke(Color.ssInk, lineWidth: 1))
            }
            .buttonStyle(PressStyle())
            .sensoryFeedback(.success, trigger: copied) { _, new in new }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .overlay(Rectangle().stroke(Color.ssLine2, lineWidth: 1))
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

    private func timeline(_ order: Order) -> some View {
        let steps = order.steps
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                let done = i <= order.stage
                let current = i == order.stage
                HStack(alignment: .top, spacing: 16) {
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(current ? Color.ssGold : (done ? Color.ssInk : Color.clear))
                                .frame(width: 14, height: 14)
                            Circle()
                                .strokeBorder(current ? Color.ssInk : (done ? Color.ssInk : Color(hex: 0xA39C97)), lineWidth: current ? 3 : 1)
                                .frame(width: 14, height: 14)
                        }
                        .scaleEffect(current ? 1.15 : 1)
                        if i < steps.count - 1 {
                            Rectangle().fill(i < order.stage ? Color.ssInk : Color.ssLine2).frame(width: 1).frame(minHeight: 34)
                        }
                    }
                    .frame(width: 14)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(step.0).font(.mont(13, current ? .semibold : .regular))
                            .foregroundStyle(done ? Color.ssInk : Color.ssMuted2)
                        Text(done ? step.1 : "Ожидается").font(.mont(11)).foregroundStyle(Color.ssMuted)
                    }
                    .padding(.top, -2)
                    .padding(.bottom, 18)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 26)
        .animation(.spring(duration: 0.5), value: order.stage)
    }
}

struct ReceiptView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    @State private var printed = false
    @State private var shareImage: Image? = nil

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 18) {
                ReceiptPaper(order: order)
                    .padding(.horizontal, 24)
                    .offset(y: printed ? 0 : -40)
                    .opacity(printed ? 1 : 0)
                    .mask(alignment: .top) {
                        Rectangle().frame(height: printed ? 2000 : 0)
                    }

                HStack(spacing: 8) {
                    if let shareImage {
                        ShareLink(item: shareImage, preview: SharePreview("Чек Sen Sulu № \(order.receiptNumber)", image: shareImage)) {
                            Text("СОХРАНИТЬ ЧЕК")
                                .font(.mont(12, .semibold)).tracking(12 * 0.2)
                                .frame(maxWidth: .infinity).frame(height: 52)
                                .foregroundStyle(Color.ssIvory)
                                .background(Color.ssInk)
                        }
                    }
                    SSButton(title: "Готово", style: .outline, height: 52) { dismiss() }
                        .frame(width: 120)
                }
                .padding(.horizontal, 24)
                .opacity(printed ? 1 : 0)
            }
            .padding(.top, 28)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color(hex: 0xEFE9E4).ignoresSafeArea())
        .presentationDragIndicator(.visible)
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) { printed = true }
            let renderer = ImageRenderer(content: ReceiptPaper(order: order).frame(width: 360).padding(20).background(Color(hex: 0xEFE9E4)))
            renderer.scale = 3
            if let ui = renderer.uiImage { shareImage = Image(uiImage: ui) }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: printed)
    }
}

/// The paper itself: ivory receipt tape with torn (zig-zag) edges.
struct ReceiptPaper: View {
    let order: Order

    private var dateLine: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "dd.MM.yyyy · HH:mm"
        return f.string(from: order.placed)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 10) {
                SMark(size: 30, color: .ssInk, line: 1.4)
                Text("sen sulu").font(.mont(11)).tracking(11 * 0.42).foregroundStyle(Color.ssInk)
                Text("Сен сұлусың").font(.serif(18)).foregroundStyle(Color.ssMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 30)

            dashed.padding(.top, 20)

            VStack(spacing: 6) {
                row("Чек №", order.receiptNumber, mono: true)
                row("Заказ", order.number, mono: true)
                row("Дата", dateLine, mono: true)
                row("Канал", "Мобильное приложение")
            }
            .padding(.vertical, 14)

            dashed

            VStack(alignment: .leading, spacing: 14) {
                ForEach(order.items) { item in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(item.product.name).font(.mont(13)).foregroundStyle(Color.ssInk)
                            Spacer(minLength: 12)
                            Text(tenge(item.total)).font(.mont(13).monospacedDigit()).foregroundStyle(Color.ssInk)
                        }
                        HStack {
                            Text(item.gift ? "В подарок · открытка" : item.product.shadeLine(item.shade))
                                .font(.mont(11)).foregroundStyle(Color.ssMuted).lineLimit(1)
                            Spacer()
                            Text("\(item.qty) × \(tenge(item.product.price))")
                                .font(.mont(11).monospacedDigit()).foregroundStyle(Color.ssMuted)
                        }
                    }
                }
            }
            .padding(.vertical, 16)

            dashed

            VStack(spacing: 7) {
                row("Товары", tenge(order.subtotal), mono: true)
                if order.pointsUsed > 0 {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("Баллы Сұлу Club").font(.mont(12)).foregroundStyle(Color.ssBody2)
                        BonusIcon(size: 13)
                        Spacer()
                        Text(tenge(-order.pointsUsed)).font(.mont(12).monospacedDigit()).foregroundStyle(Color.ssInk)
                    }
                }
                row("Доставка · \(order.delivery.title)", tenge(order.delivery.price), mono: true)
            }
            .padding(.vertical, 14)

            HStack(alignment: .lastTextBaseline) {
                Caps("Итого", size: 12, weight: .medium, spacing: 0.24)
                Spacer()
                Text(tenge(order.total)).font(.serif(32, medium: true))
            }
            .padding(.bottom, 4)

            row("Оплачено · \(order.payment.rawValue)", tenge(order.total), mono: true)
                .padding(.top, 6)

            if order.pointsEarned > 0 {
                HStack(spacing: 10) {
                    BonusIcon(size: 26, shimmer: true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("+\(groupedNumber(order.pointsEarned)) баллов").font(.mont(13, .medium)).foregroundStyle(Color.ssIvory)
                        Text("начислено в Сұлу Club").font(.mont(10)).tracking(10 * 0.06).foregroundStyle(Color.ssSand)
                    }
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.ssInk)
                .padding(.top, 18)
            }

            dashed.padding(.top, 18)

            HStack(alignment: .center, spacing: 14) {
                QRImage(text: "https://sen-sulu.com/receipt/\(order.number)")
                    .frame(width: 74, height: 74)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Электронный чек").font(.mont(12, .medium)).foregroundStyle(Color.ssInk)
                    Text("Отсканируйте, чтобы открыть чек и условия возврата — 14 дней.")
                        .font(.mont(10)).lineSpacing(2).foregroundStyle(Color.ssMuted)
                }
            }
            .padding(.vertical, 16)

            Text("Рахмет за покупку 🤍")
                .font(.serif(20))
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.ssInk)
                .padding(.bottom, 34)
        }
        .padding(.horizontal, 22)
        .background(
            Color(hex: 0xFFFEFB)
                .overlay(
                    // faint paper grain
                    LinearGradient(colors: [Color.black.opacity(0.015), .clear, Color.black.opacity(0.02)],
                                   startPoint: .top, endPoint: .bottom)
                )
        )
        .clipShape(ZigZagEdges(tooth: 7))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 6)
    }

    private var dashed: some View {
        Line()
            .stroke(Color.ssLine2, style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
            .frame(height: 1)
    }

    private func row(_ l: String, _ r: String, mono: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(l).font(.mont(12)).foregroundStyle(Color.ssBody2)
            Spacer(minLength: 10)
            Text(r).font(mono ? .mont(12).monospacedDigit() : .mont(12)).foregroundStyle(Color.ssInk)
        }
    }
}

nonisolated struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return p
    }
}

/// Rectangle whose top and bottom edges are torn into small triangles, like receipt tape.
nonisolated struct ZigZagEdges: Shape {
    var tooth: CGFloat = 7

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let n = max(Int(rect.width / (tooth * 2)), 1)
        let w = rect.width / CGFloat(n)
        p.move(to: CGPoint(x: rect.minX, y: rect.minY + tooth))
        for i in 0..<n {
            let x = rect.minX + CGFloat(i) * w
            p.addLine(to: CGPoint(x: x + w / 2, y: rect.minY))
            p.addLine(to: CGPoint(x: x + w, y: rect.minY + tooth))
        }
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - tooth))
        for i in 0..<n {
            let x = rect.maxX - CGFloat(i) * w
            p.addLine(to: CGPoint(x: x - w / 2, y: rect.maxY))
            p.addLine(to: CGPoint(x: x - w, y: rect.maxY - tooth))
        }
        p.closeSubpath()
        return p
    }
}
