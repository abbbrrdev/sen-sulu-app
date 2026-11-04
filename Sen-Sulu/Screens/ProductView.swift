import SwiftUI

struct ProductView: View {
    @Environment(AppState.self) private var state
    let product: Product

    @State private var shade: Int = 0
    @State private var openSection: String? = "how"
    @State private var addedPulse = 0
    @State private var page = 0

    private var hasShades: Bool { !product.shades.isEmpty }
    private var inCart: Bool { state.isInCart(product, shade: hasShades ? shade : nil) }
    private var isFav: Bool { state.favorites.contains(product.id) }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                gallery
                titleBlock
                if hasShades { shadePicker }
                accordion
                talkLink
                completeLook
            }
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color.ssIvory)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom, spacing: 0) { addBar }
        .onAppear {
            if product.kind == .blush, let mine = state.myShade { shade = mine } else { shade = product.defaultShade }
        }
        .sensoryFeedback(.success, trigger: addedPulse)
    }

    // MARK: Gallery

    private var gallery: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $page) {
                ProductImage(name: product.imageName(for: hasShades ? shade : nil)).tag(0)
                if product.kind == .blush {
                    Color.white.overlay(Image("model").resizable().scaledToFill()).clipped().tag(1)
                    Color.white.overlay(Image("model-before").resizable().scaledToFill()).clipped().tag(2)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 520)
            .background(Color.white)
            .clipped()

            HStack(alignment: .center) {
                if hasShades {
                    HStack(spacing: 10) {
                        Circle().fill(product.shades[shade].color)
                            .frame(width: 34, height: 34)
                            .overlay(Circle().stroke(Color.ssIvory, lineWidth: 3))
                            .overlay(Circle().stroke(Color.ssLine, lineWidth: 1).padding(-1.5))
                            .animation(.easeInOut(duration: 0.25), value: shade)
                        Caps("Свотч", size: 10, spacing: 0.2, color: .ssMuted)
                    }
                }
                Spacer()
                Caps(String(format: "%02d / %02d", page + 1, product.kind == .blush ? 3 : 1), size: 10, spacing: 0.2, color: .ssMuted)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 18)
        }
        .overlay(alignment: .top) {
            HStack {
                BackButton()
                Spacer()
                Button {
                    state.toggleFavorite(product)
                } label: {
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(Color.ssInk)
                        .frame(width: 44, height: 44)
                        .background(Color.ssIvory)
                        .overlay(Rectangle().stroke(Color.ssLine, lineWidth: 1))
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(PressStyle())
                .sensoryFeedback(.impact(weight: .light), trigger: isFav)
                .accessibilityLabel("В избранное")
            }
            .padding(.horizontal, 16)
            .padding(.top, 58)
        }
    }

    // MARK: Title

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Caps(product.hit ? "\(product.category) · хит" : product.category, size: 10, spacing: 0.28, color: .ssMuted)
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                Text(product.name).font(.mont(20)).foregroundStyle(Color.ssInk)
                Spacer()
                Text(tenge(product.price)).font(.mont(18, .medium)).foregroundStyle(Color.ssInk)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    // MARK: Shades

    private var shadePicker: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Caps("Оттенок", size: 11, spacing: 0.2)
                Spacer()
                Text(product.shades[shade].title).font(.mont(12)).foregroundStyle(Color.ssMuted)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: shade)
            }
            HStack(spacing: 0) {
                ForEach(Array(product.shades.enumerated()), id: \.offset) { i, s in
                    Button {
                        withAnimation(.spring(duration: 0.3)) { shade = i }
                    } label: {
                        Circle().fill(s.color)
                            .frame(width: 36, height: 36)
                            .padding(5)
                            .overlay(Circle().stroke(i == shade ? Color.ssInk : .clear, lineWidth: 1))
                            .scaleEffect(i == shade ? 1.06 : 1)
                    }
                    .buttonStyle(FlatStyle())
                    .accessibilityLabel(s.title)
                    if i < product.shades.count - 1 { Spacer(minLength: 0) }
                }
            }
            .sensoryFeedback(.selection, trigger: shade)
            if product.kind == .blush, state.myShade == shade {
                Text("Совпадает с твоим подбором оттенка.")
                    .font(.mont(12))
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.ssBlush)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    // MARK: Accordion

    private var accordion: some View {
        VStack(spacing: 0) {
            AccordionRow(title: "Как наносить", isOpen: openSection == "how") { toggle("how") } content: {
                VStack(alignment: .leading, spacing: 10) {
                    Text(product.about.isEmpty ? "Нанесите на чистую кожу и растушуйте." : product.about)
                    if product.kind == .blush {
                        Button { state.push(.apply) } label: {
                            Caps("Смотреть до / после →", size: 11, spacing: 0.18)
                                .padding(.bottom, 3)
                                .overlay(alignment: .bottom) { Rectangle().fill(Color.ssInk).frame(height: 1) }
                        }
                        .buttonStyle(FlatStyle())
                    }
                }
            }
            AccordionRow(title: "Состав", isOpen: openSection == "inci") { toggle("inci") } content: {
                Text("Полный состав указан на упаковке. Продукция сертифицирована и соответствует требованиям ЕАЭС.")
            }
            AccordionRow(title: "Доставка и возврат", isOpen: openSection == "ship") { toggle("ship") } content: {
                Text("СДЭК до двери — 4–5 рабочих дней, от 3 500 ₸. Казпочта — 7–12 рабочих дней, 1 600 ₸.\nВозврат — 14 дней, если упаковка не вскрыта.")
            }
        }
        .overlay(alignment: .top) { Rectangle().fill(Color.ssLine).frame(height: 1) }
        .padding(.top, 22)
    }

    private func toggle(_ id: String) {
        withAnimation(.easeInOut(duration: 0.25)) { openSection = openSection == id ? nil : id }
    }

    private var talkLink: some View {
        Button { state.push(.talk) } label: {
            HStack(spacing: 14) {
                Circle().fill(Color.ssIvory).frame(width: 40, height: 40)
                    .overlay(Image(systemName: "play.fill").font(.system(size: 12)).foregroundStyle(Color.ssBurgundy))
                VStack(alignment: .leading, spacing: 4) {
                    Caps("Sen Sulu Talk", size: 9, spacing: 0.3, color: .ssRose)
                    Text(product.kind == .lips ? "Макияж губ с эффектом омбре" : "Румяна — тот самый важный штрих в макияже")
                        .font(.mont(13)).foregroundStyle(Color.ssIvory).multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .background(Color.ssBurgundy)
        }
        .buttonStyle(PressStyle())
        .padding(.horizontal, 24)
        .padding(.top, 22)
    }

    private var completeLook: some View {
        let others = Catalog.bestsellers.filter { $0.id != product.id }.prefix(2)
        return VStack(alignment: .leading, spacing: 14) {
            SectionLabel(text: "Дополни образ")
            HStack(spacing: 14) {
                ForEach(Array(others)) { p in
                    Button { state.push(.product(p)) } label: {
                        HStack(spacing: 10) {
                            ProductImage(name: p.image).frame(width: 56, height: 72)
                                .overlay(Rectangle().stroke(Color.ssTile, lineWidth: 1))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(p.name).font(.mont(11)).foregroundStyle(Color.ssInk).lineLimit(2).multilineTextAlignment(.leading)
                                Text(tenge(p.price)).font(.mont(12, .medium)).foregroundStyle(Color.ssInk)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                    .buttonStyle(PressStyle())
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
    }

    // MARK: Add bar

    private var addBar: some View {
        let label = inCart
            ? "В корзине · \(hasShades ? product.shades[shade].title : "открыть")"
            : "В корзину · \(tenge(product.price))"
        return VStack(spacing: 0) {
            Rectangle().fill(Color.ssLine).frame(height: 1)
            SSButton(title: label, style: inCart ? .outline : .filled) {
                if inCart {
                    state.push(.cart)
                } else {
                    withAnimation(.spring(duration: 0.3)) {
                        state.add(product, shade: hasShades ? shade : nil)
                    }
                    addedPulse += 1
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 14)
            .padding(.bottom, 8)
        }
        .background(Color.ssIvory)
    }
}

struct AccordionRow<Content: View>: View {
    let title: String
    let isOpen: Bool
    let onTap: () -> Void
    @ViewBuilder let content: () -> Content

    init(title: String, isOpen: Bool, onTap: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.isOpen = isOpen
        self.onTap = onTap
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Caps(title, size: 12, spacing: 0.16)
                    Spacer()
                    Text(isOpen ? "−" : "+").font(.mont(16)).foregroundStyle(Color.ssInk)
                }
                .padding(.horizontal, 24)
                .frame(height: 56)
                .contentShape(Rectangle())
            }
            .buttonStyle(FlatStyle())
            if isOpen {
                content()
                    .font(.mont(13))
                    .lineSpacing(5)
                    .foregroundStyle(Color.ssBody3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 18)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            Rectangle().fill(Color.ssLine).frame(height: 1)
        }
        .clipped()
    }
}
