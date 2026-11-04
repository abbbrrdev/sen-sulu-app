import SwiftUI

struct BoxView: View {
    @Environment(AppState.self) private var state
    let box: Product

    @State private var card = true
    @State private var wantsDate = false
    @State private var date = Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
    @State private var zoom = 1.12

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Color(hex: 0xEFEAEA)
                    if let img = box.image {
                        Image(img).resizable().scaledToFill()
                            .scaleEffect(zoom)
                    }
                }
                .frame(height: 540)
                .clipped()
                .overlay(alignment: .topLeading) { BackButton().padding(.leading, 16).padding(.top, 58) }

                VStack(alignment: .leading, spacing: 8) {
                    Caps("Подарочный бокс", size: 10, spacing: 0.3, color: .ssMuted)
                    HStack(alignment: .lastTextBaseline) {
                        Text(Catalog.boxTitle(box)).font(.serif(46)).foregroundStyle(Color.ssInk)
                        Spacer()
                        Text(tenge(box.price)).font(.mont(18, .medium))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 26)

                if !box.contents.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(text: "Внутри — \(box.contents.count) средств")
                        LazyVGrid(columns: [GridItem(.flexible(), alignment: .topLeading), GridItem(.flexible(), alignment: .topLeading)], alignment: .leading, spacing: 10) {
                            ForEach(Array(box.contents.enumerated()), id: \.offset) { i, item in
                                HStack(alignment: .top, spacing: 8) {
                                    Text(String(format: "%02d", i + 1)).font(.mont(12)).foregroundStyle(Color.ssMuted2)
                                    Text(item).font(.mont(12)).foregroundStyle(Color.ssInk)
                                    Spacer(minLength: 0)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 26)
                } else {
                    Text("Коллекционный бокс Sen Sulu — продукты бренда в праздничной упаковке с цветочной иллюстрацией. Идеальный подарок.")
                        .font(.mont(13)).lineSpacing(5).foregroundStyle(Color.ssBody3)
                        .padding(.horizontal, 24).padding(.top, 18)
                }

                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Открытка с пожеланием").font(.mont(13))
                            Text("Напишем от руки, бесплатно").font(.mont(11)).foregroundStyle(Color.ssMuted)
                        }
                        Spacer()
                        SSToggle(isOn: $card)
                    }
                    .padding(.horizontal, 24)
                    .frame(height: 64)
                    .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }

                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Доставить к дате").font(.mont(13))
                            Text("Укажите дату — постараемся учесть").font(.mont(11)).foregroundStyle(Color.ssMuted)
                        }
                        Spacer()
                        DatePicker("", selection: $date, in: Date()..., displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .tint(Color.ssInk)
                            .environment(\.locale, Locale(identifier: "ru_RU"))
                    }
                    .padding(.horizontal, 24)
                    .frame(height: 64)
                    .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }
                }
                .overlay(alignment: .top) { Rectangle().fill(Color.ssLine).frame(height: 1) }
                .padding(.top, 26)
            }
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color.ssIvory)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Rectangle().fill(Color.ssLine).frame(height: 1)
                HStack(spacing: 10) {
                    SSButton(title: "Себе", style: .outline) {
                        state.add(box, shade: nil)
                        state.push(.cart)
                    }
                    .frame(width: 110)
                    SSButton(title: "Подарить") {
                        state.add(box, shade: nil, gift: true)
                        state.push(.cart)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 8)
            }
            .background(Color.ssIvory)
        }
        .onAppear { withAnimation(.easeOut(duration: 6)) { zoom = 1.0 } }
    }
}
