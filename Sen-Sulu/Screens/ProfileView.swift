import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var state
    @Environment(\.openURL) private var openURL
    @State private var testSent = 0

    var body: some View {
        @Bindable var state = state
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 16) {
                    Text(String(state.name.prefix(1)))
                        .font(.serif(26))
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(Color.ssBlush))
                        .overlay(Circle().stroke(Color.ssLine, lineWidth: 1))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(state.name) К.").font(.mont(17))
                        Text("\(state.phone) · Gold").font(.mont(11)).foregroundStyle(Color.ssMuted)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)

                HStack(spacing: 0) {
                    shortcut("Заказы", system: "shippingbox") {
                        if state.order != nil { state.showTrack = true } else { state.push(.cart) }
                    }
                    divider
                    shortcut("Избранное", system: "heart") { state.openCatalog(nil) }
                    divider
                    Button { state.push(.shade) } label: {
                        VStack(spacing: 6) {
                            Circle().fill(state.myShade.map { Catalog.blushShades[$0].color } ?? Color.ssLine2).frame(width: 20, height: 20)
                            Text("Мой тон").font(.mont(10)).tracking(10 * 0.06)
                        }
                        .foregroundStyle(Color.ssInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(FlatStyle())
                    divider
                    shortcut("Club", system: "diamond") { state.tab = .club }
                }
                .overlay(Rectangle().stroke(Color.ssLine, lineWidth: 1))
                .padding(.horizontal, 24)
                .padding(.top, 22)

                VStack(alignment: .leading, spacing: 10) {
                    Caps("Язык", size: 10, weight: .medium, spacing: 0.24, color: .ssMuted)
                    SegmentedRow(options: [("kk", "ҚАЗ"), ("ru", "РУС"), ("en", "ENG"), ("uz", "O‘ZB")], selection: $state.language)
                    Caps("Валюта", size: 10, weight: .medium, spacing: 0.24, color: .ssMuted).padding(.top, 10)
                    SegmentedRow(options: [("kzt", "₸ KZT"), ("usd", "$ USD"), ("rub", "₽ RUB")], selection: $state.currency)
                }
                .padding(.horizontal, 24)
                .padding(.top, 26)

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Уведомления о заказе").font(.mont(13))
                            Text("Оплата, сборка, СДЭК, доставка").font(.mont(11)).foregroundStyle(Color.ssMuted)
                        }
                        Spacer()
                        SSToggle(isOn: $state.orderNotifications)
                    }
                    .padding(.horizontal, 24)
                    .frame(minHeight: 64)
                    .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }
                    Button {
                        NotificationManager.shared.sendTest()
                        testSent += 1
                    } label: {
                        RowLink(title: "Прислать пример уведомления", subtitle: "Придёт через 2 секунды", trailing: "↗")
                    }
                    .buttonStyle(FlatStyle())
                    .sensoryFeedback(.success, trigger: testSent)
                }
                .overlay(alignment: .top) { Rectangle().fill(Color.ssLine).frame(height: 1) }
                .padding(.top, 26)

                VStack(spacing: 0) {
                    Button { state.push(.stores) } label: { RowLink(title: "Где купить офлайн") }.buttonStyle(FlatStyle())
                    Button { state.push(.collab) } label: { RowLink(title: "Сотрудничество") }.buttonStyle(FlatStyle())
                    Button { state.push(.help(.delivery)) } label: { RowLink(title: "Помощь и частые вопросы") }.buttonStyle(FlatStyle())
                    Button { state.push(.help(.returns)) } label: { RowLink(title: "Условия возврата") }.buttonStyle(FlatStyle())
                    Button { openURL(Links.privacy) } label: { RowLink(title: "Политика конфиденциальности", trailing: "↗") }.buttonStyle(FlatStyle())
                }
                .padding(.top, 18)

                VStack(alignment: .leading, spacing: 12) {
                    Caps("Sen Sulu в соцсетях", size: 10, weight: .medium, spacing: 0.24, color: .ssMuted)
                    FlowRow {
                        social("Instagram", Links.instagram)
                        social("TikTok", Links.tiktok)
                        social("YouTube", Links.youtube)
                        social("Telegram", Links.telegram)
                        social("WhatsApp", Links.whatsapp)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                Button {
                    state.entered = false
                } label: {
                    Text("Выйти").font(.mont(12)).tracking(12 * 0.14).foregroundStyle(Color.ssMuted)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .padding(.top, 20)
            }
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color.ssIvory)
    }

    private var divider: some View { Rectangle().fill(Color.ssLine).frame(width: 1) }

    private func shortcut(_ title: String, system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: system).font(.system(size: 18, weight: .light)).frame(height: 20)
                Text(title).font(.mont(10)).tracking(10 * 0.06)
            }
            .foregroundStyle(Color.ssInk)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(FlatStyle())
    }

    private func social(_ title: String, _ url: URL) -> some View {
        Button { openURL(url) } label: {
            Text(title).font(.mont(11)).tracking(11 * 0.08).foregroundStyle(Color.ssInk)
                .padding(.horizontal, 12).frame(height: 40)
                .overlay(Rectangle().stroke(Color.ssLine2, lineWidth: 1))
        }
        .buttonStyle(PressStyle())
    }
}

/// Simple wrapping row for chips.
nonisolated struct FlowRow: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxW = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0, width: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x > 0 && x + s.width > maxW { x = 0; y += rowH + spacing; rowH = 0 }
            x += s.width + spacing
            rowH = max(rowH, s.height)
            width = max(width, x - spacing)
        }
        return CGSize(width: proposal.width ?? width, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x > bounds.minX && x + s.width > bounds.maxX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            v.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
    }
}
