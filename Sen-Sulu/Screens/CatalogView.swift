import SwiftUI

struct CatalogView: View {
    @Environment(AppState.self) private var state

    private let filters: [(String, Kind?)] = [("Все", nil), ("Румяна", .blush), ("Губы", .lips), ("Лицо", .face), ("Боксы", .box)]
    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    private var items: [Product] {
        guard let f = state.catalogFilter else { return Catalog.all }
        return Catalog.all.filter { $0.kind == f }
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Caps("Каталог", size: 22, weight: .medium, spacing: 0.3)
                        Text("63 товара · доставка по Казахстану").font(.mont(11)).tracking(11 * 0.06).foregroundStyle(Color.ssMuted)
                    }
                    Spacer()
                    Button { state.push(.cart) } label: {
                        Image(systemName: "bag").font(.system(size: 19, weight: .light)).foregroundStyle(Color.ssInk)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Корзина")
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)

                HStack(spacing: 10) {
                    Button { state.push(.search) } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass").font(.system(size: 15, weight: .light)).foregroundStyle(Color.ssMuted)
                            Text("Румяна, блеск, бокс…").font(.mont(13)).foregroundStyle(Color.ssMuted2)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .overlay(Rectangle().stroke(Color.ssLine2, lineWidth: 1))
                    }
                    .buttonStyle(FlatStyle())
                    Button {} label: {
                        Image(systemName: "slider.horizontal.3").font(.system(size: 16, weight: .light)).foregroundStyle(Color.ssInk)
                            .frame(width: 46, height: 46)
                            .overlay(Rectangle().stroke(Color.ssLine2, lineWidth: 1))
                    }
                    .accessibilityLabel("Фильтры и сортировка")
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)

                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.0) { f in
                            Chip(title: f.0, selected: state.catalogFilter == f.1) {
                                withAnimation(.snappy) { state.catalogFilter = f.1 }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 1)
                }
                .scrollIndicators(.hidden)
                .padding(.top, 18)

                LazyVGrid(columns: columns, spacing: 26) {
                    ForEach(items) { p in
                        Button {
                            if p.kind == .box { state.push(.box(p)) } else { state.push(.product(p)) }
                        } label: {
                            ProductCard(product: p)
                        }
                        .buttonStyle(PressStyle())
                        .transition(.opacity.combined(with: .scale(scale: 0.97)))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)
                .padding(.bottom, 30)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.ssIvory)
    }
}
