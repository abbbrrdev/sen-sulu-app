import SwiftUI

struct TalkView: View {
    @Environment(AppState.self) private var state
    @Environment(\.openURL) private var openURL
    let isRoot: Bool
    @State private var addedPulse = 0

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                header
                featured
                shopTheLook
                episodes
            }
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(Color.ssIvory)
        .ignoresSafeArea(edges: .top)
        .sensoryFeedback(.success, trigger: addedPulse)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !isRoot {
                BackButton(boxed: false, color: .ssIvory).padding(.leading, -12)
            }
            Text("sen sulu").font(.mont(11)).tracking(11 * 0.42).foregroundStyle(Color.ssIvory)
            Text("talk").font(.serif(56)).foregroundStyle(Color.ssIvory)
            Text("с Айнур Кабельдиновой · 15 выпусков").font(.mont(12)).foregroundStyle(Color(hex: 0xE6D3D4))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, isRoot ? 74 : 54)
        .padding(.bottom, 26)
        .background(Color.ssBurgundy)
    }

    private var featured: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { openURL(Talk.channel) } label: {
                ZStack {
                    Image("hero-poster").resizable().scaledToFill()
                        .frame(height: 380).frame(maxWidth: .infinity).clipped()
                    Circle().fill(Color.ssIvory).frame(width: 64, height: 64)
                        .overlay(Image(systemName: "play.fill").font(.system(size: 18)).foregroundStyle(Color.ssBurgundy).offset(x: 2))
                }
                .overlay(alignment: .topLeading) {
                    Caps("Новый выпуск", size: 9, spacing: 0.24, color: .ssIvory)
                        .padding(.horizontal, 8).padding(.vertical, 5)
                        .background(Color.ssBurgundy)
                        .padding(14)
                }
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel("Смотреть выпуск на YouTube")
            Text(Talk.featured.title).font(.mont(17, .medium)).lineSpacing(3).foregroundStyle(Color.ssInk).padding(.top, 16)
            Text(Talk.featured.date).font(.mont(11)).foregroundStyle(Color.ssMuted).padding(.top, 6)
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
    }

    private var shopTheLook: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(text: "Товары из выпуска").padding(.horizontal, 24)
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    lookItem(Catalog.stick)
                    lookItem(Catalog.mini)
                    lookItem(Catalog.fixer)
                }
                .padding(.horizontal, 24)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.top, 22)
    }

    private func lookItem(_ p: Product) -> some View {
        let added = state.isInCart(p, shade: p.shades.isEmpty ? nil : p.defaultShade)
        return HStack(spacing: 12) {
            Button { state.push(.product(p)) } label: {
                HStack(spacing: 12) {
                    ProductImage(name: p.image).frame(width: 56, height: 72)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(p.name).font(.mont(12)).foregroundStyle(Color.ssInk).lineLimit(2).multilineTextAlignment(.leading)
                        Text(tenge(p.price)).font(.mont(12, .medium)).foregroundStyle(Color.ssInk)
                    }
                }
            }
            .buttonStyle(FlatStyle())
            Spacer(minLength: 0)
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    state.add(p, shade: p.shades.isEmpty ? nil : p.defaultShade)
                }
                addedPulse += 1
            } label: {
                Image(systemName: added ? "checkmark" : "plus")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(added ? Color.ssInk : Color.ssIvory)
                    .frame(width: 44, height: 44)
                    .background(added ? Color.ssIvory : Color.ssInk)
                    .overlay(Rectangle().stroke(Color.ssInk, lineWidth: 1))
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel("Добавить в корзину")
        }
        .padding(10)
        .frame(width: 246)
        .overlay(Rectangle().stroke(Color.ssLine, lineWidth: 1))
    }

    private var episodes: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "Все выпуски")
            ForEach(Talk.episodes) { e in
                Button { openURL(Talk.channel) } label: {
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "play.circle").font(.system(size: 18, weight: .light)).foregroundStyle(Color.ssBurgundy)
                        Text(e.title).font(.mont(13)).lineSpacing(3).foregroundStyle(Color.ssInk).multilineTextAlignment(.leading)
                        Spacer()
                        Text(e.date).font(.mont(11)).foregroundStyle(Color.ssMuted)
                    }
                    .padding(.vertical, 14)
                    .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }
                    .contentShape(Rectangle())
                }
                .buttonStyle(FlatStyle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
    }
}
