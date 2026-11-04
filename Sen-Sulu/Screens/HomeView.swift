import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                header
                stories
                hero
                categories
                bestsellers
                shadeBanner
                talkCard
                clubStrip
            }
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(Color.ssIvory)
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button { state.push(.search) } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 19, weight: .light))
                    .foregroundStyle(Color.ssInk)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Поиск")
            Spacer()
            LogoLockup()
            Spacer()
            Button { state.push(.cart) } label: {
                Image(systemName: "bag")
                    .font(.system(size: 19, weight: .light))
                    .foregroundStyle(Color.ssInk)
                    .frame(width: 44, height: 44)
                    .overlay(alignment: .topTrailing) {
                        if state.cartCount > 0 {
                            Text("\(state.cartCount)")
                                .font(.mont(9, .medium))
                                .foregroundStyle(Color.ssIvory)
                                .frame(minWidth: 16, minHeight: 16)
                                .background(Circle().fill(Color.ssInk))
                                .offset(x: -2, y: 6)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
            }
            .accessibilityLabel("Корзина")
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .animation(.spring(duration: 0.35), value: state.cartCount)
    }

    // MARK: Stories

    private var stories: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 14) {
                StoryBubble(label: "Talk", image: "hero-poster") { state.tab = .talk }
                StoryBubble(label: "Новинки", image: "stick", fit: true) { state.openCatalog(nil) }
                StoryBubble(label: "Боксы", image: "petal") { state.push(.box(Catalog.petal)) }
                StoryBubble(label: "Как наносить", image: "model-before") { state.push(.apply) }
                StoryBubble(label: "Мой тон", image: nil, color: state.myShade.map { Catalog.blushShades[$0].color }, seen: true) {
                    state.push(.shade)
                }
            }
            .padding(.horizontal, 24)
        }
        .scrollIndicators(.hidden)
        .padding(.top, 22)
        .padding(.bottom, 24)
    }

    // MARK: Hero

    private var hero: some View {
        Button { state.push(.box(Catalog.aurora)) } label: {
            VStack(spacing: 0) {
                Image("aurora")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 400)
                    .frame(maxWidth: .infinity)
                    .clipped()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Caps("Коллекция · подарочные боксы", size: 9, spacing: 0.3, color: .ssGold)
                        Text("Aurora Bloom").font(.serif(30)).foregroundStyle(Color.ssIvory)
                    }
                    Spacer()
                    Text(tenge(73000)).font(.mont(13)).foregroundStyle(Color.ssIvory)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(Color.ssInk)
            }
        }
        .buttonStyle(PressStyle())
        .padding(.horizontal, 24)
    }

    // MARK: Categories

    private var categories: some View {
        let items: [(String, Kind?)] = [("Лицо", .face), ("Губы", .lips), ("Румяна", .blush), ("Боксы", .box)]
        return HStack(spacing: 22) {
            ForEach(items, id: \.0) { item in
                Button { state.openCatalog(item.1) } label: {
                    Caps(item.0, size: 11, spacing: 0.2, color: item.0 == "Лицо" ? .ssInk : .ssMuted)
                        .padding(.vertical, 12)
                        .overlay(alignment: .bottom) {
                            if item.0 == "Лицо" { Rectangle().fill(Color.ssInk).frame(height: 1.5) }
                        }
                }
                .buttonStyle(FlatStyle())
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }
        .padding(.top, 30)
    }

    // MARK: Bestsellers

    private var bestsellers: some View {
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Caps("Бестселлеры", size: 13, weight: .medium, spacing: 0.26)
                Spacer()
                Button { state.openCatalog(nil) } label: {
                    Text("Все").font(.mont(11)).tracking(11 * 0.12).foregroundStyle(Color.ssInk)
                }
            }
            .padding(.horizontal, 24)
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(Catalog.bestsellers) { p in
                        Button { state.push(.product(p)) } label: {
                            ProductCard(product: p, width: 158, height: 206)
                        }
                        .buttonStyle(PressStyle())
                    }
                }
                .padding(.horizontal, 24)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.top, 30)
    }

    // MARK: Banners

    private var shadeBanner: some View {
        Button { state.push(.shade) } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 6) {
                    ForEach(Catalog.blushShades) { s in
                        Circle().fill(s.color).frame(width: 18, height: 18)
                    }
                }
                Text(state.myShade == nil ? "Какой оттенок — твой?" : "Твой оттенок — \(Catalog.blushShades[state.myShade ?? 0].title)")
                    .font(.serif(28))
                    .foregroundStyle(Color.ssInk)
                    .multilineTextAlignment(.leading)
                Text("Три вопроса о коже — и мы соберём румяна, консилер и пудру под тебя.")
                    .font(.mont(12))
                    .lineSpacing(3)
                    .foregroundStyle(Color.ssMuted)
                    .multilineTextAlignment(.leading)
                Caps(state.myShade == nil ? "Подобрать →" : "Пройти ещё раз →", size: 11, weight: .medium, spacing: 0.22)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
            .background(Color.ssBlush)
        }
        .buttonStyle(PressStyle())
        .padding(.horizontal, 24)
        .padding(.top, 34)
    }

    private var talkCard: some View {
        Button { state.tab = .talk } label: {
            HStack(spacing: 16) {
                ZStack {
                    Image("hero-poster").resizable().scaledToFill()
                        .frame(width: 96, height: 120).clipped()
                    Circle().fill(Color.ssIvory).frame(width: 34, height: 34)
                        .overlay(Image(systemName: "play.fill").font(.system(size: 11)).foregroundStyle(Color.ssBurgundy))
                }
                .frame(width: 96, height: 120)
                VStack(alignment: .leading, spacing: 0) {
                    Caps("Sen Sulu Talk · новый выпуск", size: 9, spacing: 0.3, color: .ssRose)
                    Spacer()
                    Text(Talk.featured.title).font(.mont(14)).lineSpacing(3)
                        .foregroundStyle(Color.ssIvory).multilineTextAlignment(.leading)
                    Spacer()
                    Text("Купить образ · 2 товара").font(.mont(11)).tracking(11 * 0.08)
                        .foregroundStyle(Color(hex: 0xE6D3D4))
                }
                .padding(.vertical, 2)
                Spacer(minLength: 0)
            }
            .padding(16)
            .background(Color.ssBurgundy)
        }
        .buttonStyle(PressStyle())
        .padding(.horizontal, 24)
        .padding(.top, 14)
    }

    private var clubStrip: some View {
        Button { state.tab = .club } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Caps("Сұлу Club · Gold", size: 9, spacing: 0.3, color: .ssGold)
                    HStack(spacing: 8) {
                        BonusIcon(size: 18, shimmer: true)
                        Text("\(groupedNumber(state.points)) баллов").font(.mont(14)).foregroundStyle(Color.ssIvory)
                            .contentTransition(.numericText())
                    }
                }
                Spacer()
                Text("Карта →").font(.mont(11)).tracking(11 * 0.14).foregroundStyle(Color.ssIvory)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.ssInk)
        }
        .buttonStyle(PressStyle())
        .padding(.horizontal, 24)
        .padding(.top, 14)
    }
}

struct StoryBubble: View {
    let label: String
    let image: String?
    var fit = false
    var color: Color? = nil
    var seen = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    if let image {
                        Image(image).resizable()
                            .aspectRatio(contentMode: fit ? .fit : .fill)
                            .frame(width: 56, height: 56)
                            .background(Color.white)
                            .clipShape(Circle())
                    } else {
                        Circle().fill(color ?? Color.ssBlush).frame(width: 56, height: 56)
                            .overlay {
                                if color == nil {
                                    Text("?").font(.serif(24)).foregroundStyle(Color.ssMuted)
                                }
                            }
                    }
                }
                .padding(3)
                .overlay(Circle().stroke(seen ? Color.ssLine2 : Color.ssGold, lineWidth: 1.5))
                Text(label).font(.mont(10)).foregroundStyle(Color.ssBody3).lineLimit(1)
            }
            .frame(width: 70)
        }
        .buttonStyle(PressStyle())
    }
}
