import SwiftUI

// MARK: - Help / FAQ (answers taken from sen-sulu.com/faq)

struct HelpView: View {
    @Environment(\.openURL) private var openURL
    let initial: HelpTab
    @State private var tab: HelpTab = .delivery
    @State private var open: Int? = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenHeader(title: "Помощь")
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Ответы на частые вопросы — без ожидания в мессенджере.")
                        .font(.serif(26)).foregroundStyle(Color.ssInk)
                        .padding(.horizontal, 24).padding(.top, 14)

                    HStack(spacing: 20) {
                        ForEach(HelpTab.allCases, id: \.self) { t in
                            Button {
                                withAnimation(.snappy) { tab = t; open = 0 }
                            } label: {
                                Caps(t.rawValue, size: 11, spacing: 0.2, color: tab == t ? .ssInk : .ssMuted)
                                    .frame(height: 46)
                                    .overlay(alignment: .bottom) {
                                        Rectangle().fill(tab == t ? Color.ssInk : .clear).frame(height: 1.5)
                                    }
                            }
                            .buttonStyle(FlatStyle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }
                    .padding(.top, 22)
                    .sensoryFeedback(.selection, trigger: tab)

                    VStack(spacing: 0) {
                        ForEach(Array((FAQ.items[tab] ?? []).enumerated()), id: \.offset) { i, qa in
                            VStack(alignment: .leading, spacing: 0) {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) { open = open == i ? nil : i }
                                } label: {
                                    HStack(spacing: 16) {
                                        Text(qa.0).font(.mont(13)).foregroundStyle(Color.ssInk).multilineTextAlignment(.leading)
                                        Spacer()
                                        Text(open == i ? "−" : "+").font(.mont(16)).foregroundStyle(Color.ssInk)
                                    }
                                    .frame(minHeight: 56)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(FlatStyle())
                                if open == i {
                                    Text(qa.1).font(.mont(13)).lineSpacing(5).foregroundStyle(Color.ssBody3)
                                        .padding(.bottom, 16)
                                        .transition(.opacity)
                                }
                                Rectangle().fill(Color.ssLine).frame(height: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 12) {
                        Caps("Остались вопросы?", size: 10, spacing: 0.28, color: .ssMuted)
                        HStack(spacing: 8) {
                            SSButton(title: "Telegram", style: .outline, height: 48) { openURL(Links.telegram) }
                            SSButton(title: "WhatsApp", height: 48) { openURL(Links.whatsapp) }
                        }
                    }
                    .padding(20)
                    .background(Color.ssBlush)
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                }
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.ssIvory)
        .onAppear { tab = initial }
    }
}

// MARK: - Where to buy (store locator data from sen-sulu.com/about)

struct StoresView: View {
    @Environment(\.openURL) private var openURL
    @State private var city = "Астана"

    private var count: Int { Stores.cities.first { $0.0 == city }?.1 ?? 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenHeader(title: "Где купить")
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Sen Sulu в магазинах-партнёрах 11 стран. В Казахстане — 22 города и 130 точек.")
                        .font(.mont(12)).lineSpacing(4).foregroundStyle(Color.ssBody2)
                        .padding(.horizontal, 24).padding(.top, 10)

                    ScrollView(.horizontal) {
                        HStack(spacing: 8) {
                            ForEach(Stores.countries, id: \.self) { c in
                                Chip(title: c, selected: c == "Казахстан") {}
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 1)
                    }
                    .scrollIndicators(.hidden)
                    .padding(.top, 18)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) {
                        ForEach(Stores.cities, id: \.0) { c in
                            let on = c.0 == city
                            Button { withAnimation(.snappy) { city = c.0 } } label: {
                                HStack {
                                    Text(c.0 == "Усть-Каменогорск" ? "Усть-Кам." : c.0).font(.mont(11)).lineLimit(1)
                                    Spacer(minLength: 2)
                                    Text("\(c.1)").font(.mont(11)).opacity(0.7)
                                }
                                .padding(.horizontal, 10)
                                .frame(minHeight: 44)
                                .foregroundStyle(on ? Color.ssIvory : Color.ssInk)
                                .background(on ? Color.ssInk : Color.clear)
                                .overlay(Rectangle().stroke(on ? Color.ssInk : Color.ssLine2, lineWidth: 1))
                            }
                            .buttonStyle(FlatStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 18)
                    .sensoryFeedback(.selection, trigger: city)

                    HStack(alignment: .firstTextBaseline) {
                        Text(city).font(.serif(30))
                        Spacer()
                        Text("\(count) точек").font(.mont(11)).foregroundStyle(Color.ssMuted)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    VStack(spacing: 0) {
                        if city == "Астана" {
                            ForEach(Stores.astana, id: \.self) { h in
                                Button {
                                    if let url = URL(string: "https://www.instagram.com/\(h)") { openURL(url) }
                                } label: {
                                    HStack {
                                        Text("@\(h)").font(.mont(13)).foregroundStyle(Color.ssInk)
                                        Spacer()
                                        Caps("Instagram →", size: 10, spacing: 0.16, color: .ssMuted)
                                    }
                                    .frame(height: 46)
                                    .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(FlatStyle())
                            }
                        } else {
                            Text("Контакты партнёров в городе \(city) подгрузятся с сайта бренда.")
                                .font(.mont(12)).foregroundStyle(Color.ssMuted)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 18)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.ssIvory)
    }
}

// MARK: - Collaboration hub

struct CollabView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                Image("model2").resizable().scaledToFill()
                    .frame(height: 340).frame(maxWidth: .infinity).clipped()
                    .background(Color.white)
                    .overlay(alignment: .topLeading) { BackButton().padding(.leading, 16).padding(.top, 58) }
                VStack(alignment: .leading, spacing: 8) {
                    Caps("Сотрудничество", size: 10, spacing: 0.3, color: .ssMuted)
                    Text("Создавай красоту вместе с Sen Sulu").font(.serif(36)).foregroundStyle(Color.ssInk)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                VStack(spacing: 0) {
                    row("01", "Блогерам и UGC", "Бартер, оплачиваемые интеграции, UGC-съёмки") { state.push(.creator(.blogger)) }
                    row("02", "Визажистам", "Расскажем о вас аудитории, позовём на съёмки, скидка на косметику для работы") { state.push(.creator(.makeup)) }
                    row("03", "B2B · опт", "Маржа до 55%, маркетинговая поддержка, обучение") { state.push(.b2b) }
                }
                .overlay(alignment: .top) { Rectangle().fill(Color.ssLine).frame(height: 1) }
                .padding(.top, 20)
            }
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(Color.ssIvory)
        .ignoresSafeArea(edges: .top)
    }

    private func row(_ n: String, _ title: String, _ sub: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 16) {
                Text(n).font(.mont(11)).foregroundStyle(Color.ssMuted2).padding(.top, 2)
                VStack(alignment: .leading, spacing: 5) {
                    Caps(title, size: 13, weight: .medium, spacing: 0.14)
                    Text(sub).font(.mont(12)).lineSpacing(3).foregroundStyle(Color.ssBody2).multilineTextAlignment(.leading)
                }
                Spacer()
                Text("→").font(.mont(14))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }
            .contentShape(Rectangle())
        }
        .buttonStyle(FlatStyle())
    }
}

// MARK: - Search

struct SearchView: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @FocusState private var focused: Bool

    private var products: [Product] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return [] }
        return Catalog.all.filter { $0.name.lowercased().contains(q) || $0.category.lowercased().contains(q) }
    }
    private var episodes: [Episode] {
        let q = query.lowercased()
        guard !q.isEmpty else { return [] }
        return ([Talk.featured] + Talk.episodes).filter { $0.title.lowercased().contains(q) }
    }
    private var questions: [(HelpTab, String)] {
        let q = query.lowercased()
        guard !q.isEmpty else { return [] }
        var out: [(HelpTab, String)] = []
        for t in HelpTab.allCases {
            for qa in FAQ.items[t] ?? [] where qa.0.lowercased().contains(q) || qa.1.lowercased().contains(q) {
                out.append((t, qa.0))
            }
        }
        return out
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").font(.system(size: 16, weight: .light))
                    TextField("Товары, выпуски, вопросы…", text: $query)
                        .font(.mont(16))
                        .focused($focused)
                        .submitLabel(.search)
                        .autocorrectionDisabled()
                }
                .frame(height: 48)
                .overlay(alignment: .bottom) { Rectangle().fill(Color.ssInk).frame(height: 1) }
                Button("Отмена") { dismiss() }
                    .font(.mont(12))
                    .foregroundStyle(Color.ssInk)
                    .frame(height: 44)
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    if query.isEmpty {
                        Caps("Часто ищут", size: 10, spacing: 0.24, color: .ssMuted).padding(.top, 20)
                        FlowRow {
                            ForEach(["румяна", "блеск", "консилер", "пудра", "бокс", "фиксатор"], id: \.self) { s in
                                Button { query = s } label: {
                                    Text(s).font(.mont(12)).foregroundStyle(Color.ssInk)
                                        .padding(.horizontal, 12).frame(height: 38)
                                        .overlay(Rectangle().stroke(Color.ssLine2, lineWidth: 1))
                                }
                                .buttonStyle(PressStyle())
                            }
                        }
                        .padding(.top, 10)
                    } else {
                        if !products.isEmpty {
                            Caps("Товары · \(products.count)", size: 10, spacing: 0.24, color: .ssMuted).padding(.top, 22)
                            ForEach(products) { p in
                                Button {
                                    state.push(p.kind == .box ? .box(p) : .product(p))
                                } label: {
                                    HStack(spacing: 14) {
                                        ProductImage(name: p.image, fill: p.kind == .box).frame(width: 48, height: 64)
                                            .overlay(Rectangle().stroke(Color.ssTile, lineWidth: 1))
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(p.name).font(.mont(13)).foregroundStyle(Color.ssInk)
                                            Text(p.subtitle).font(.mont(11)).foregroundStyle(Color.ssMuted)
                                        }
                                        Spacer()
                                        Text(tenge(p.price)).font(.mont(12, .medium)).foregroundStyle(Color.ssInk)
                                    }
                                    .padding(.vertical, 10)
                                    .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(FlatStyle())
                            }
                        }
                        if !episodes.isEmpty {
                            Caps("Sen Sulu Talk", size: 10, spacing: 0.24, color: .ssMuted).padding(.top, 22)
                            ForEach(episodes) { e in
                                Button { state.push(.talk) } label: { resultLine(e.title) }.buttonStyle(FlatStyle())
                            }
                        }
                        if !questions.isEmpty {
                            Caps("Вопросы", size: 10, spacing: 0.24, color: .ssMuted).padding(.top, 22)
                            ForEach(questions, id: \.1) { q in
                                Button { state.push(.help(q.0)) } label: { resultLine(q.1) }.buttonStyle(FlatStyle())
                            }
                        }
                        if products.isEmpty && episodes.isEmpty && questions.isEmpty {
                            Text("Ничего не нашли. Попробуйте «румяна» или «бокс».")
                                .font(.mont(13)).foregroundStyle(Color.ssMuted).padding(.top, 30)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.ssIvory)
        .onAppear { focused = true }
    }

    private func resultLine(_ text: String) -> some View {
        HStack(spacing: 12) {
            Text(text).font(.mont(13)).foregroundStyle(Color.ssInk).multilineTextAlignment(.leading)
            Spacer()
            Text("→").font(.mont(13))
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }
        .contentShape(Rectangle())
    }
}
