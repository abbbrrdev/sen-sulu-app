import SwiftUI

struct CartView: View {
    @Environment(AppState.self) private var state
    @State private var delivery: Delivery = .cdek
    @State private var payment: Payment = .kaspiGold
    @State private var usePoints = true
    @State private var date = Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
    @State private var placing = false

    private var pointsUsed: Int { usePoints ? min(state.points, state.subtotal) : 0 }
    private var total: Int { state.subtotal - pointsUsed + delivery.price }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "Корзина")
            if state.cart.isEmpty {
                empty
            } else {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0) {
                        items
                        deliveryBlock
                        paymentBlock
                        pointsBlock
                        totals
                    }
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)
                .safeAreaInset(edge: .bottom, spacing: 0) { checkoutBar }
            }
        }
        .background(Color.ssIvory)
        .animation(.spring(duration: 0.35), value: state.cart)
        .sensoryFeedback(.selection, trigger: payment)
        .sensoryFeedback(.selection, trigger: delivery)
    }

    private var empty: some View {
        VStack(spacing: 16) {
            Spacer()
            SMark(size: 44, color: .ssMuted2, line: 1.2)
            Text("В корзине пока пусто").font(.serif(30)).foregroundStyle(Color.ssInk)
            Text("Начните с бестселлеров — румяна в стике выбирают чаще всего.")
                .font(.mont(13)).foregroundStyle(Color.ssMuted).multilineTextAlignment(.center)
            SSButton(title: "В каталог") { state.openCatalog(nil) }
                .padding(.top, 8)
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var items: some View {
        VStack(spacing: 0) {
            ForEach(state.cart) { item in
                HStack(spacing: 14) {
                    ProductImage(name: item.product.imageName(for: item.shade), fill: item.product.kind == .box)
                        .frame(width: 78, height: 104)
                        .overlay(Rectangle().stroke(Color.ssTile, lineWidth: 1))
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.product.name).font(.mont(13)).foregroundStyle(Color.ssInk)
                            Text(item.gift ? "В подарок · с открыткой" : item.product.shadeLine(item.shade))
                                .font(.mont(11)).foregroundStyle(Color.ssMuted)
                        }
                        Spacer(minLength: 8)
                        HStack {
                            HStack(spacing: 0) {
                                stepperButton("minus") { state.setQty(item, item.qty - 1) }
                                Text("\(item.qty)").font(.mont(13)).frame(width: 28)
                                    .contentTransition(.numericText(value: Double(item.qty)))
                                stepperButton("plus") { state.setQty(item, item.qty + 1) }
                            }
                            .overlay(Rectangle().stroke(Color.ssLine2, lineWidth: 1))
                            Spacer()
                            Text(tenge(item.total)).font(.mont(13, .medium))
                                .contentTransition(.numericText(value: Double(item.total)))
                        }
                    }
                }
                .padding(.vertical, 16)
                .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .padding(.horizontal, 24)
    }

    private func stepperButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3)) { action() }
        } label: {
            Image(systemName: icon).font(.system(size: 12, weight: .light)).foregroundStyle(Color.ssInk)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(FlatStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: state.cartCount)
    }

    private var deliveryBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "Доставка")
            HStack(spacing: 8) {
                ForEach(Delivery.allCases) { d in
                    optionBox(selected: delivery == d) {
                        withAnimation(.easeOut(duration: 0.15)) { delivery = d }
                    } content: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(d.title).font(.mont(13))
                            Text(d.days).font(.mont(11)).foregroundStyle(Color.ssMuted)
                            Text(d.priceLabel).font(.mont(12, .medium))
                        }
                    }
                }
            }
            HStack {
                Text("Удобная дата доставки").font(.mont(13))
                Spacer()
                DatePicker("", selection: $date, in: Date()..., displayedComponents: .date)
                    .labelsHidden()
                    .tint(Color.ssInk)
                    .environment(\.locale, Locale(identifier: "ru_RU"))
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 52)
            .overlay(Rectangle().stroke(Color.ssLine2, lineWidth: 1))
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
    }

    private var paymentBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "Оплата")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(Payment.allCases) { p in
                    optionBox(selected: payment == p) {
                        withAnimation(.easeOut(duration: 0.15)) { payment = p }
                    } content: {
                        Text(p.rawValue).font(.mont(13, payment == p ? .medium : .regular))
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
    }

    private func optionBox<C: View>(selected: Bool, action: @escaping () -> Void, @ViewBuilder content: () -> C) -> some View {
        Button(action: action) {
            content()
                .foregroundStyle(Color.ssInk)
                .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(selected ? Color.ssBlush : Color.clear)
                .overlay(Rectangle().stroke(selected ? Color.ssInk : Color.ssLine2, lineWidth: 1))
        }
        .buttonStyle(FlatStyle())
    }

    private var pointsBlock: some View {
        HStack(spacing: 12) {
            BonusIcon(size: 30, shimmer: usePoints)
            VStack(alignment: .leading, spacing: 3) {
                Caps("Сұлу Club", size: 10, spacing: 0.28, color: .ssGold)
                Text("Списать \(groupedNumber(min(state.points, state.subtotal))) баллов").font(.mont(13)).foregroundStyle(Color.ssIvory)
            }
            Spacer()
            SSToggle(isOn: $usePoints, onColor: .ssGold, offColor: Color(hex: 0x4A4542))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.ssInk)
        .padding(.horizontal, 24)
        .padding(.top, 22)
    }

    private var totals: some View {
        VStack(spacing: 10) {
            line("Товары", tenge(state.subtotal))
            line("Баллы", pointsUsed > 0 ? tenge(-pointsUsed) : "—")
            line("Доставка · \(delivery.title)", delivery.priceLabel)
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
    }

    private func line(_ l: String, _ r: String) -> some View {
        HStack {
            Text(l).font(.mont(13)).foregroundStyle(Color.ssBody2)
            Spacer()
            Text(r).font(.mont(13)).foregroundStyle(Color.ssInk)
                .contentTransition(.numericText())
        }
    }

    private var checkoutBar: some View {
        VStack(spacing: 12) {
            Rectangle().fill(Color.ssLine).frame(height: 1)
            HStack(alignment: .lastTextBaseline) {
                Caps("Итого", size: 11, spacing: 0.24)
                Spacer()
                Text((delivery == .cdek ? "от " : "") + tenge(total))
                    .font(.serif(30))
                    .contentTransition(.numericText(value: Double(total)))
                    .animation(.snappy, value: total)
            }
            .padding(.horizontal, 24)
            SSButton(title: placing ? "Оплата…" : "Оформить заказ") {
                guard !placing else { return }
                placing = true
                Task {
                    try? await Task.sleep(for: .milliseconds(900))
                    state.placeOrder(delivery: delivery, payment: payment, usePoints: usePoints)
                    placing = false
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .background(Color.ssIvory)
        .sensoryFeedback(.success, trigger: state.order?.number)
    }
}
