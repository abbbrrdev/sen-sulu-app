import SwiftUI

struct ShadeFinderView: View {
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss

    @State private var step = 0          // 0..2 questions, 3 = result
    @State private var tone = 1
    @State private var undertone = 0
    @State private var effect = 0

    private struct Option { let title: String; let sub: String; let dots: [UInt32] }

    private let tones: [Option] = [
        Option(title: "Светлый", sub: "Быстро краснеет на солнце", dots: [0xF1DCCB, 0xEBCFB9, 0xE5C4AA]),
        Option(title: "Средний", sub: "Загорает постепенно", dots: [0xE2BE9E, 0xD6AA86, 0xC9986F]),
        Option(title: "Смуглый", sub: "Легко загорает", dots: [0xB98563, 0xA06F4F, 0x86593E])
    ]
    private let undertones: [Option] = [
        Option(title: "Тёплый", sub: "Золотистый, персиковый оттенок", dots: [0xE7C3A4, 0xC98A72, 0xE07A5F]),
        Option(title: "Холодный", sub: "Розоватый, фарфоровый оттенок", dots: [0xEDD0CF, 0xD98C93, 0xE58FA6]),
        Option(title: "Нейтральный", sub: "Сложно отнести к одному", dots: [0xE8CDB8, 0xC99A8C, 0xB97A73])
    ]
    private let effects: [Option] = [
        Option(title: "Естественный", sub: "Как будто только с прогулки", dots: [0xD98C93, 0xC98A72, 0xE58FA6]),
        Option(title: "Выразительный", sub: "Яркий акцент на скулах", dots: [0xB23A48, 0x9C4A5A, 0xE07A5F])
    ]

    private var questions: [(String, String, [Option])] {
        [
            ("Какой у тебя тон кожи?", "Выбери ближайший — в этом нет ошибки.", tones),
            ("Какой подтон у твоей кожи?", "Посмотри на вены на запястье при дневном свете: зеленоватые — тёплый, голубые — холодный, сложно сказать — нейтральный.", undertones),
            ("Какой эффект хочешь?", "Румяна наслаиваются — начни с одного касания.", effects)
        ]
    }

    /// Simple mapping to one of the six real blush shades.
    private var resultShade: Int {
        switch (undertone, effect) {
        case (0, 0): return 1        // 02 Тёплый нюд
        case (0, 1): return 4        // 05 Кораловый
        case (1, 0): return 0        // 01 Пудровый розовый
        case (1, 1): return 3        // 04 Ягодный красный
        case (2, 0): return tone == 2 ? 2 : 5
        default: return 2            // 03 Сливовый
        }
    }

    private func binding(for q: Int) -> Binding<Int> {
        switch q {
        case 0: return $tone
        case 1: return $undertone
        default: return $effect
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Caps(step < 3 ? "Подбор оттенка · \(step + 1) / 3" : "Твой результат", size: 10, spacing: 0.3, color: .ssMuted)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.system(size: 16, weight: .light)).foregroundStyle(Color.ssInk)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Закрыть")
            }
            HStack(spacing: 6) {
                ForEach(0..<3) { i in
                    Rectangle().fill(i <= min(step, 2) ? Color.ssInk : Color.ssLine2).frame(height: 2)
                }
            }
            .animation(.easeInOut, value: step)

            if step < 3 {
                question(step)
                    .id(step)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)))
            } else {
                result.transition(.opacity)
            }

            Spacer(minLength: 0)

            if step < 3 {
                HStack(spacing: 10) {
                    SSButton(title: "Назад", style: .outline) {
                        if step == 0 { dismiss() } else { withAnimation(.snappy) { step -= 1 } }
                    }
                    .frame(width: 110)
                    SSButton(title: step == 2 ? "Показать результат" : "Дальше") {
                        withAnimation(.snappy) { step += 1 }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(Color.ssBlush.ignoresSafeArea())
        .sensoryFeedback(.selection, trigger: step)
    }

    private func question(_ q: Int) -> some View {
        let (title, hint, opts) = questions[q]
        let sel = binding(for: q)
        return VStack(alignment: .leading, spacing: 0) {
            Text(title).font(.serif(40)).foregroundStyle(Color.ssInk).padding(.top, 40)
            Text(hint).font(.mont(13)).lineSpacing(5).foregroundStyle(Color.ssBody2).padding(.top, 14)
            VStack(spacing: 10) {
                ForEach(Array(opts.enumerated()), id: \.offset) { i, o in
                    let on = sel.wrappedValue == i
                    Button { withAnimation(.easeOut(duration: 0.15)) { sel.wrappedValue = i } } label: {
                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                ForEach(o.dots, id: \.self) { d in Circle().fill(Color(hex: d)).frame(width: 16, height: 16) }
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(o.title).font(.mont(14, .medium)).foregroundStyle(Color.ssInk)
                                Text(o.sub).font(.mont(12)).foregroundStyle(Color.ssMuted)
                            }
                            Spacer()
                            Circle()
                                .strokeBorder(on ? Color.ssInk : Color(hex: 0xA39C97), lineWidth: on ? 5 : 1)
                                .frame(width: 18, height: 18)
                        }
                        .padding(.horizontal, 18)
                        .frame(minHeight: 76)
                        .background(on ? Color.ssIvory : Color.clear)
                        .overlay(Rectangle().stroke(on ? Color.ssInk : Color.ssLine2, lineWidth: 1))
                    }
                    .buttonStyle(FlatStyle())
                    .sensoryFeedback(.selection, trigger: on)
                }
            }
            .padding(.top, 28)
        }
    }

    private var result: some View {
        let s = Catalog.blushShades[resultShade]
        return VStack(alignment: .leading, spacing: 0) {
            Text("Твой оттенок").font(.serif(40)).foregroundStyle(Color.ssInk).padding(.top, 40)
            HStack(spacing: 16) {
                Circle().fill(s.color).frame(width: 64, height: 64)
                    .overlay(Circle().stroke(Color.ssIvory, lineWidth: 4))
                VStack(alignment: .leading, spacing: 4) {
                    Caps("Румяна", size: 10, spacing: 0.24, color: .ssMuted)
                    Text(s.title).font(.mont(18)).foregroundStyle(Color.ssInk)
                }
            }
            .padding(.top, 22)
            Text("Подойдёт к \(["светлому", "среднему", "смуглому"][tone]) тону кожи с \(["тёплым", "холодным", "нейтральным"][undertone]) подтоном.")
                .font(.mont(13)).lineSpacing(5).foregroundStyle(Color.ssBody2).padding(.top, 16)

            VStack(spacing: 0) {
                resultRow(Catalog.stick, shade: resultShade)
                resultRow(Catalog.concealer, shade: undertone == 1 ? 0 : (tone == 0 ? 0 : 1))
                resultRow(Catalog.powder, shade: tone == 2 ? 1 : 0)
            }
            .overlay(alignment: .top) { Rectangle().fill(Color.ssLine2).frame(height: 1) }
            .padding(.top, 24)

            SSButton(title: "Сохранить и в корзину") {
                state.myShade = resultShade
                state.add(Catalog.stick, shade: resultShade)
                state.push(.cart)
            }
            .padding(.top, 22)
            Button {
                state.myShade = resultShade
                dismiss()
            } label: {
                Text("Просто сохранить оттенок").font(.mont(12)).tracking(12 * 0.12).foregroundStyle(Color.ssInk)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        }
    }

    private func resultRow(_ p: Product, shade: Int) -> some View {
        HStack(spacing: 14) {
            ProductImage(name: p.image).frame(width: 48, height: 62)
            VStack(alignment: .leading, spacing: 3) {
                Text(p.name).font(.mont(13)).foregroundStyle(Color.ssInk)
                Text(p.shades[shade].title).font(.mont(11)).foregroundStyle(Color.ssMuted)
            }
            Spacer()
            Text(tenge(p.price)).font(.mont(12, .medium))
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine2).frame(height: 1) }
    }
}
