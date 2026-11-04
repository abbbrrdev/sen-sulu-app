import SwiftUI

/// "Как наносить": before / after comparison with a draggable divider, using the brand's own product-page photos.
struct ApplyView: View {
    @Environment(AppState.self) private var state
    @State private var split: CGFloat = 0.5
    @State private var dragging = false
    @State private var hinted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GeometryReader { geo in
                let w = geo.size.width
                ZStack(alignment: .leading) {
                    Color.white
                    Image("model-before").resizable().scaledToFill()
                        .frame(width: w, height: geo.size.height).clipped()
                    Image("model").resizable().scaledToFill()
                        .frame(width: w, height: geo.size.height).clipped()
                        .mask(alignment: .leading) { Rectangle().frame(width: w * split) }

                    Rectangle().fill(Color.ssIvory).frame(width: 2)
                        .shadow(color: .black.opacity(0.12), radius: 2)
                        .offset(x: w * split - 1)
                    Circle().fill(Color.ssIvory).frame(width: dragging ? 48 : 42, height: dragging ? 48 : 42)
                        .shadow(color: .black.opacity(0.18), radius: 8, y: 3)
                        .overlay(Image(systemName: "arrow.left.and.right").font(.system(size: 13, weight: .regular)).foregroundStyle(Color.ssInk))
                        .offset(x: w * split - (dragging ? 24 : 21))
                }
                .frame(width: w, height: geo.size.height)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { v in
                            if !dragging { withAnimation(.spring(duration: 0.2)) { dragging = true } }
                            split = min(max(v.location.x / w, 0.02), 0.98)
                        }
                        .onEnded { _ in withAnimation(.spring(duration: 0.25)) { dragging = false } }
                )
                .overlay(alignment: .top) {
                    HStack {
                        Caps("После", size: 10, spacing: 0.26)
                            .padding(.horizontal, 9).padding(.vertical, 6).background(Color.ssIvory)
                        Spacer()
                        Caps("До", size: 10, spacing: 0.26, color: .ssIvory)
                            .padding(.horizontal, 9).padding(.vertical, 6).background(Color.ssInk)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 112)
                }
            }
            .frame(height: 560)
            .overlay(alignment: .topLeading) {
                BackButton().padding(.leading, 16).padding(.top, 58)
            }
            .sensoryFeedback(.selection, trigger: dragging)

            VStack(alignment: .leading, spacing: 0) {
                Caps("Румяна в стике · 01 пудровый розовый", size: 10, spacing: 0.28, color: .ssMuted)
                Text("Три касания").font(.serif(34)).foregroundStyle(Color.ssInk).padding(.top, 8)
                VStack(alignment: .leading, spacing: 12) {
                    step("01", "Поставь точки на скулы, виски, спинку носа и подбородок.")
                    step("02", "Растушуй пальцами вверх, к вискам.")
                    step("03", "Закрепи фиксатором — до 24 часов.")
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 24)
            .padding(.top, 22)

            Spacer(minLength: 0)
        }
        .background(Color.ssIvory)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Rectangle().fill(Color.ssLine).frame(height: 1)
                Text("Румяна в стике + Фиксатор макияжа 100 мл").font(.mont(11)).foregroundStyle(Color.ssBody2)
                    .padding(.horizontal, 24)
                SSButton(title: "Купить образ · \(tenge(Catalog.stick.price + Catalog.fixer.price))") {
                    state.add(Catalog.stick, shade: 0)
                    state.add(Catalog.fixer, shade: nil)
                    state.push(.cart)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
            }
            .background(Color.ssIvory)
        }
        .onAppear {
            guard !hinted else { return }
            hinted = true
            split = 0.15
            withAnimation(.easeInOut(duration: 1.2).delay(0.4)) { split = 0.62 }
        }
    }

    private func step(_ n: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(n).font(.mont(11)).foregroundStyle(Color.ssMuted2).padding(.top, 2)
            Text(text).font(.mont(13)).lineSpacing(4).foregroundStyle(Color.ssInk)
        }
    }
}
