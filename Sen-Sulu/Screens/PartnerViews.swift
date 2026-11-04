import SwiftUI
import UIKit

// MARK: - Creator / makeup-artist application (fields mirror the forms on sen-sulu.com/collaboration)

struct CreatorFormView: View {
    @Environment(\.dismiss) private var dismiss
    let kind: CreatorKind

    @State private var step = 1
    @State private var sent = false
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var city = "Астана"
    @State private var category = "Мода и красота"
    @State private var types: Set<String> = ["Бьюти / макияж"]
    @State private var about = ""
    @State private var instagram = ""
    @State private var tiktok = ""
    @State private var youtube = ""
    @State private var portfolio = ""
    @State private var age = "18-24"
    @State private var size = "10-50k"
    @State private var consent = true

    private let categories = ["Мода и красота", "Здоровье и велнес", "Студенчество", "Семья", "Отдых и путешествия", "Свадьбы", "Другое"]
    private let makeupFocus = ["Свадебный макияж", "Вечерний и праздничный", "Дневной макияж и уход", "Съёмки и фотосессии", "Обучение и мастер-классы"]
    private let contentTypes = ["Бьюти / макияж", "Лайфстайл", "Мода", "Еда", "Обзоры", "Тревел"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if sent {
                success
            } else {
                HStack {
                    Caps("\(kind.title) · \(step) / 5", size: 10, spacing: 0.3, color: .ssMuted)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 16, weight: .light)).foregroundStyle(Color.ssInk)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Закрыть")
                }
                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { i in
                        Rectangle().fill(i <= step ? Color.ssInk : Color.ssLine2).frame(height: 2)
                    }
                }
                .animation(.easeInOut, value: step)
                Text("Черновик сохраняется — можно закончить позже.").font(.mont(11)).foregroundStyle(Color.ssMuted).padding(.top, 14)

                ScrollView(.vertical) {
                    Group {
                        switch step {
                        case 1: stepAbout
                        case 2: stepContent
                        case 3: stepSocial
                        case 4: stepAudience
                        default: stepMaterials
                        }
                    }
                    .id(step)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                    .padding(.top, 22)
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)

                HStack(spacing: 10) {
                    SSButton(title: "Назад", style: .outline) {
                        if step == 1 { dismiss() } else { withAnimation(.snappy) { step -= 1 } }
                    }
                    .frame(width: 110)
                    SSButton(title: step == 5 ? "Отправить заявку" : "Дальше") {
                        if step == 5 { withAnimation(.spring) { sent = true } } else { withAnimation(.snappy) { step += 1 } }
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .background(Color.ssIvory)
        .sensoryFeedback(.selection, trigger: step)
        .sensoryFeedback(.success, trigger: sent)
    }

    private func title(_ t: String) -> some View {
        Text(t).font(.serif(38)).foregroundStyle(Color.ssInk).padding(.bottom, 4)
    }

    private var stepAbout: some View {
        VStack(alignment: .leading, spacing: 18) {
            title(kind == .blogger ? "Расскажите о себе" : "Контактная информация")
            SSField(label: "Имя и фамилия *", text: $name, placeholder: "Айгерим Касымова")
            SSField(label: "Email *", text: $email, placeholder: "name@mail.kz", keyboard: .emailAddress)
            SSField(label: "Телефон / WhatsApp *", text: $phone, placeholder: "+7 7__ ___ __ __", keyboard: .phonePad)
            SSField(label: "Город *", text: $city, placeholder: "Астана")
        }
    }

    private var stepContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            title(kind == .blogger ? "О чём ваш контент?" : "О вашей работе")
            VStack(alignment: .leading, spacing: 8) {
                Caps(kind == .blogger ? "Категория *" : "Чем занимаетесь чаще всего *", size: 10, spacing: 0.22)
                Menu {
                    ForEach(kind == .blogger ? categories : makeupFocus, id: \.self) { c in
                        Button(c) { category = c }
                    }
                } label: {
                    HStack {
                        Text(category).font(.mont(13)).foregroundStyle(Color.ssInk)
                        Spacer()
                        Image(systemName: "chevron.down").font(.system(size: 12, weight: .light)).foregroundStyle(Color.ssInk)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 50)
                    .overlay(Rectangle().stroke(Color.ssLine2, lineWidth: 1))
                }
            }
            if kind == .blogger {
                VStack(alignment: .leading, spacing: 10) {
                    Caps("Что снимаете чаще всего *", size: 10, spacing: 0.22)
                    FlowRow {
                        ForEach(contentTypes, id: \.self) { t in
                            let on = types.contains(t)
                            Button {
                                if on { types.remove(t) } else { types.insert(t) }
                            } label: {
                                Text(t).font(.mont(11)).tracking(11 * 0.08)
                                    .padding(.horizontal, 12).frame(height: 40)
                                    .foregroundStyle(on ? Color.ssIvory : Color.ssInk)
                                    .background(on ? Color.ssInk : Color.clear)
                                    .overlay(Rectangle().stroke(on ? Color.ssInk : Color.ssLine2, lineWidth: 1))
                            }
                            .buttonStyle(FlatStyle())
                            .sensoryFeedback(.selection, trigger: on)
                        }
                    }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Caps(kind == .blogger ? "Расскажите о себе *" : "Опыт работы", size: 10, spacing: 0.22)
                TextField("Пара строк о вас и вашей аудитории", text: $about, axis: .vertical)
                    .font(.mont(13))
                    .lineLimit(4...7)
                    .padding(12)
                    .overlay(Rectangle().stroke(Color.ssLine2, lineWidth: 1))
            }
        }
    }

    private var stepSocial: some View {
        VStack(alignment: .leading, spacing: 18) {
            title("Где вас смотреть?")
            SSField(label: "Instagram *", text: $instagram, placeholder: "@username")
            SSField(label: "TikTok", text: $tiktok, placeholder: "@username")
            if kind == .blogger { SSField(label: "YouTube", text: $youtube, placeholder: "Ссылка на канал") }
            SSField(label: kind == .blogger ? "Портфолио или пример" : "Сайт или портфолио", text: $portfolio,
                    placeholder: kind == .blogger ? "Пост, рилс или медиакит" : "Сайт, папка с работами или Pinterest")
        }
    }

    private var stepAudience: some View {
        VStack(alignment: .leading, spacing: 22) {
            title(kind == .blogger ? "Ваша аудитория" : "Ваш уровень")
            pickRow(kind == .blogger ? "Возраст аудитории *" : "Опыт, лет", options: kind == .blogger ? ["13-17", "18-24", "25-34", "35-44", "45+"] : ["<1", "1-3", "3-5", "5-10", "10+"], selection: $age)
            pickRow(kind == .blogger ? "Размер аудитории *" : "Клиентов в месяц", options: kind == .blogger ? ["<1k", "1-10k", "10-50k", "50-100k", "100k+"] : ["<10", "10-30", "30-60", "60-100", "100+"], selection: $size)
        }
    }

    private var stepMaterials: some View {
        VStack(alignment: .leading, spacing: 18) {
            title("Материалы")
            Text(kind == .blogger ? "Добавьте медиакит, статистику или примеры работ (необязательно)." : "Приложите то, что показывает ваш уровень — так мы быстрее рассмотрим заявку.")
                .font(.mont(13)).lineSpacing(4).foregroundStyle(Color.ssBody2)
            HStack(spacing: 10) {
                Image(systemName: "plus").font(.system(size: 16, weight: .light))
                Text("Добавить файлы").font(.mont(13))
                Spacer()
            }
            .foregroundStyle(Color.ssInk)
            .padding(.horizontal, 14)
            .frame(height: 64)
            .overlay(Rectangle().strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4])).foregroundStyle(Color.ssLine2))
            HStack(alignment: .top, spacing: 12) {
                SSToggle(isOn: $consent)
                Text("Я согласен(а) на обработку персональных данных и с политикой конфиденциальности.")
                    .font(.mont(12)).lineSpacing(3).foregroundStyle(Color.ssBody2)
            }
        }
    }

    private func pickRow(_ label: String, options: [String], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Caps(label, size: 10, spacing: 0.22)
            HStack(spacing: 6) {
                ForEach(options, id: \.self) { o in
                    let on = selection.wrappedValue == o
                    Button { selection.wrappedValue = o } label: {
                        Text(o).font(.mont(11))
                            .frame(maxWidth: .infinity, minHeight: 42)
                            .foregroundStyle(on ? Color.ssIvory : Color.ssInk)
                            .background(on ? Color.ssInk : Color.clear)
                            .overlay(Rectangle().stroke(on ? Color.ssInk : Color.ssLine2, lineWidth: 1))
                    }
                    .buttonStyle(FlatStyle())
                }
            }
            .sensoryFeedback(.selection, trigger: selection.wrappedValue)
        }
    }

    private var success: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            SMark(size: 44, color: .ssGold, line: 1.4)
            Text("Заявка отправлена").font(.serif(42)).foregroundStyle(Color.ssInk)
            Text("Команда Sen Sulu изучит профиль и свяжется с вами — в WhatsApp или по email.")
                .font(.mont(13)).lineSpacing(4).foregroundStyle(Color.ssBody2)
            Spacer()
            SSButton(title: "Готово") { dismiss() }.padding(.bottom, 8)
        }
    }
}

struct SSField: View {
    let label: String
    @Binding var text: String
    var placeholder = ""
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Caps(label, size: 10, spacing: 0.22)
            TextField(placeholder, text: $text)
                .font(.mont(13))
                .keyboardType(keyboard)
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .sentences)
                .padding(.horizontal, 12)
                .frame(height: 50)
                .overlay(Rectangle().stroke(Color.ssLine2, lineWidth: 1))
        }
    }
}

// MARK: - B2B / wholesale (terms from sen-sulu.com/b2b)

struct B2BView: View {
    @Environment(\.openURL) private var openURL
    @State private var showForm = false

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    BackButton(boxed: false, color: .ssIvory).padding(.leading, -12)
                    Caps("B2B · партнёрам", size: 10, spacing: 0.3, color: .ssGold)
                    Text("Бьюти-бизнес вместе с Sen Sulu").font(.serif(40)).foregroundStyle(Color.ssIvory)
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("55%").font(.custom("CormorantGaramond-Regular", fixedSize: 64)).foregroundStyle(Color.ssGold)
                        Text("маржа партнёра —\nдо 55% с заказа").font(.mont(12)).lineSpacing(3).foregroundStyle(Color.ssSand)
                    }
                    .padding(.top, 6)
                }
                .padding(.horizontal, 24)
                .padding(.top, 54)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.ssInk)

                HStack(spacing: 0) {
                    fact("от 300 000 ₸", "минимальный заказ")
                    Rectangle().fill(Color.ssLine).frame(width: 1)
                    fact("от 3 дней", "отгрузка заказа").padding(.leading, 16)
                }
                .padding(.horizontal, 24)
                .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }

                SectionLabel(text: "Почему остаются с нами").padding(.horizontal, 24).padding(.top, 26)
                VStack(spacing: 0) {
                    perk("Собственное производство", "Контроль качества на каждом этапе")
                    perk("Сертификаты ЕАЭС", "Декларации, штрих-коды, EAC, инфолисты")
                    perk("Контент для продаж", "Профессиональные фото и видео для сайта и соцсетей")
                    perk("Маркетинг и обучение", "Инструменты роста и тренинги для ваших сотрудников")
                    perk("Россия и СНГ", "Экспортные документы берём на себя")
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 14) {
                    SectionLabel(text: "Как начать")
                    stepRow("01", "Оставьте заявку — консультант расскажет об условиях")
                    stepRow("02", "Договор и доступ к кабинету с партнёрской скидкой")
                    stepRow("03", "Первый заказ — с менеджером или сами, с тестерами")
                    stepRow("04", "Отгрузка от 3 дней")
                }
                .padding(20)
                .background(Color.ssBlush)
                .padding(.horizontal, 24)
                .padding(.top, 18)

                VStack(spacing: 0) {
                    contact("Опт · Казахстан", "+7 708 594 89 00", "tel:+77085948900")
                    contact("Опт · СНГ", "+7 708 277 30 50", "tel:+77082773050")
                    contact("Email", "b2b@sen-sulu.com", "mailto:b2b@sen-sulu.com")
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
            }
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color.ssIvory)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Rectangle().fill(Color.ssLine).frame(height: 1)
                SSButton(title: "Стать партнёром") { showForm = true }
                    .padding(.horizontal, 24).padding(.top, 14).padding(.bottom, 8)
            }
            .background(Color.ssIvory)
        }
        .sheet(isPresented: $showForm) { B2BFormSheet() }
    }

    private func fact(_ big: String, _ small: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(big).font(.mont(18))
            Text(small).font(.mont(11)).foregroundStyle(Color.ssMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 20)
    }

    private func perk(_ t: String, _ s: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(t).font(.mont(13, .medium))
            Text(s).font(.mont(12)).foregroundStyle(Color.ssBody2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }
    }

    private func stepRow(_ n: String, _ t: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(n).font(.mont(11)).foregroundStyle(Color.ssMuted2)
            Text(t).font(.mont(13)).lineSpacing(3)
        }
    }

    private func contact(_ label: String, _ value: String, _ url: String) -> some View {
        Button {
            if let u = URL(string: url) { openURL(u) }
        } label: {
            HStack {
                Caps(label, size: 10, spacing: 0.2, color: .ssMuted)
                Spacer()
                Text(value).font(.mont(13)).foregroundStyle(Color.ssInk)
            }
            .frame(height: 54)
            .overlay(alignment: .bottom) { Rectangle().fill(Color.ssLine).frame(height: 1) }
            .contentShape(Rectangle())
        }
        .buttonStyle(FlatStyle())
    }
}

struct B2BFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var company = ""
    @State private var phone = ""
    @State private var city = ""
    @State private var sent = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if sent {
                Spacer()
                SMark(size: 44, color: .ssGold, line: 1.4)
                Text("Заявка у менеджера").font(.serif(40))
                Text("Свяжемся в ближайшее время и расскажем об условиях партнёрства.")
                    .font(.mont(13)).lineSpacing(4).foregroundStyle(Color.ssBody2)
                Spacer()
                SSButton(title: "Готово") { dismiss() }
            } else {
                Caps("Заявка · давайте знакомиться", size: 10, spacing: 0.28, color: .ssMuted).padding(.top, 24)
                SSField(label: "Имя и фамилия *", text: $name, placeholder: "Имя")
                SSField(label: "Название компании *", text: $company, placeholder: "ТОО «…»")
                SSField(label: "Телефон / WhatsApp *", text: $phone, placeholder: "+7 7__ ___ __ __", keyboard: .phonePad)
                SSField(label: "Город *", text: $city, placeholder: "Алматы")
                Spacer()
                SSButton(title: "Отправить заявку") { withAnimation(.spring) { sent = true } }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
        .foregroundStyle(Color.ssInk)
        .background(Color.ssIvory.ignoresSafeArea())
        .presentationDetents([.large])
        .sensoryFeedback(.success, trigger: sent)
    }
}
