import SwiftUI

// MARK: - Catalog models

nonisolated struct Shade: Hashable, Identifiable {
    let code: String
    let name: String
    let hex: UInt32
    var id: String { code }
    var color: Color { Color(hex: hex) }
    var title: String { "\(code) \(name)" }
}

nonisolated enum Kind: String, Hashable, CaseIterable {
    case blush, lips, face, box
}

nonisolated struct Product: Hashable, Identifiable {
    let id: String
    let category: String
    let name: String
    let subtitle: String
    let price: Int
    let image: String?
    let kind: Kind
    var hit: Bool = false
    var shades: [Shade] = []
    var defaultShade: Int = 0
    var shadeImages: [String: String] = [:]
    var contents: [String] = []
    var about: String = ""

    func imageName(for shade: Int?) -> String? {
        if let shade, shades.indices.contains(shade), let img = shadeImages[shades[shade].code] { return img }
        return image
    }

    func shadeLine(_ index: Int?) -> String {
        if let index, shades.indices.contains(index) { return shades[index].title }
        return subtitle
    }
}

enum Catalog {
    static let blushShades: [Shade] = [
        Shade(code: "01", name: "Пудровый розовый", hex: 0xD98C93),
        Shade(code: "02", name: "Тёплый нюд", hex: 0xC98A72),
        Shade(code: "03", name: "Сливовый", hex: 0x9C4A5A),
        Shade(code: "04", name: "Ягодный красный", hex: 0xB23A48),
        Shade(code: "05", name: "Кораловый", hex: 0xE07A5F),
        Shade(code: "06", name: "Розовый", hex: 0xE58FA6)
    ]

    static let stick = Product(
        id: "stick", category: "Румяна", name: "Румяна в стике 7.5 гр", subtitle: "6 оттенков",
        price: 9900, image: "stick", kind: .blush, hit: true, shades: blushShades,
        about: "Нанеси стик на яблочки щёк и растушуй к вискам подушечками пальцев. Для лёгкого эффекта — одно касание, для яркого — наслаивай.")

    static let mini = Product(
        id: "mini", category: "Румяна", name: "Румяна мини 4.5 гр", subtitle: "6 оттенков",
        price: 6900, image: "mini", kind: .blush, shades: blushShades, defaultShade: 1,
        about: "Компактная версия румян — удобно взять с собой. Наносится пальцами или кистью, легко наслаивается.")

    static let gloss = Product(
        id: "gloss", category: "Блеск для губ", name: "Блеск для губ 4.5 гр", subtitle: "4 оттенка",
        price: 7200, image: "gloss-peach", kind: .lips,
        shades: [
            Shade(code: "01", name: "Silk Kiss", hex: 0xD4A28F),
            Shade(code: "02", name: "Peach Velvet", hex: 0xE3A48F),
            Shade(code: "03", name: "Caramel Soufflé", hex: 0xB97E58),
            Shade(code: "04", name: "Cherry Bomb", hex: 0x8E1F2C)
        ],
        defaultShade: 1,
        shadeImages: ["02": "gloss-peach", "04": "gloss-cherry"],
        about: "Нанеси от центра губ к уголкам. Для объёма — капля блеска в центр нижней губы.")

    static let concealer = Product(
        id: "concealer", category: "Консилер", name: "Консилер 4.6 мл", subtitle: "3 оттенка",
        price: 5200, image: "concealer", kind: .face,
        shades: [
            Shade(code: "01", name: "Светлый, молочный подтон", hex: 0xEFD8C2),
            Shade(code: "02", name: "Нейтральный светло-бежевый", hex: 0xE3C3A5),
            Shade(code: "03", name: "Натуральный бежевый", hex: 0xD3AC8A)
        ],
        about: "Точечно нанеси под глаза и на покраснения, растушуй лёгкими похлопываниями.")

    static let powder = Product(
        id: "powder", category: "Пудра", name: "Минеральная пудра 10 гр", subtitle: "2 оттенка",
        price: 7800, image: "powder", kind: .face,
        shades: [
            Shade(code: "01", name: "Прозрачный", hex: 0xF2E6DA),
            Shade(code: "02", name: "Более тёмный", hex: 0xD8B795)
        ],
        about: "Прозрачный оттенок универсален: фиксирует макияж и придаёт матовость.")

    static let fixer = Product(
        id: "fixer", category: "Фиксатор", name: "Фиксатор макияжа 100 мл", subtitle: "До 24 часов",
        price: 7500, image: nil, kind: .face,
        about: "Финальный шаг макияжа: держит до 24 часов, водостойкая формула, лёгкое нелипкое покрытие и естественное сияние.")

    static let petal = Product(
        id: "petal", category: "Подарочный бокс", name: "Box «Petal Heart»", subtitle: "11 средств",
        price: 70000, image: "petal", kind: .box,
        contents: ["Румяна", "Мини-блеск для губ", "Гель для бровей", "Блеск для губ", "Тушь — новинка",
                   "Карандаш для бровей", "Карандаш для губ", "Консилер", "Контур для лица", "Пудра", "Сурьма"])

    static let aurora = Product(
        id: "aurora", category: "Подарочный бокс", name: "Box «Aurora Bloom»", subtitle: "Коллекция",
        price: 73000, image: "aurora", kind: .box)

    static let all: [Product] = [stick, mini, gloss, concealer, powder, fixer, petal, aurora]
    static let bestsellers: [Product] = [stick, gloss, concealer, powder]

    static func boxTitle(_ p: Product) -> String {
        p.name.replacingOccurrences(of: "Box «", with: "").replacingOccurrences(of: "»", with: "")
    }
}

// MARK: - Cart & order

nonisolated struct CartItem: Identifiable, Hashable {
    let id = UUID()
    let product: Product
    var shade: Int?
    var qty: Int
    var gift: Bool = false

    var total: Int { product.price * qty }
}

nonisolated enum Delivery: String, CaseIterable, Identifiable {
    case cdek, post
    var id: String { rawValue }
    var title: String { self == .cdek ? "СДЭК до двери" : "Казпочта" }
    var days: String { self == .cdek ? "4–5 рабочих дней" : "7–12 рабочих дней" }
    var priceLabel: String { self == .cdek ? "от 3 500 ₸" : "1 600 ₸" }
    var price: Int { self == .cdek ? 3500 : 1600 }
    var carrier: String { self == .cdek ? "СДЭК" : "Казпочту" }
}

nonisolated enum Payment: String, CaseIterable, Identifiable {
    case kaspiGold = "Kaspi Gold"
    case kaspiRed = "Kaspi Red"
    case kaspiInstallment = "Kaspi Рассрочка"
    case halyk = "Halyk Bank"
    case bcc = "BCC"
    var id: String { rawValue }
}

struct Order: Identifiable {
    let id = UUID()
    let number: String
    let track: String
    let items: [CartItem]
    let total: Int
    let payment: Payment
    let delivery: Delivery
    let placed: Date
    var pointsUsed: Int = 0
    var pointsEarned: Int = 0
    var stage: Int = 0

    var subtotal: Int { items.reduce(0) { $0 + $1.total } }
    var receiptNumber: String { String(number.filter(\.isNumber).suffix(5)).leftPadded(to: 6) }

    var steps: [(String, String)] {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMMM, HH:mm"
        let now = f.string(from: placed)
        return [
            ("Заказ оформлен", now),
            ("Оплачен · \(payment.rawValue)", now),
            ("Собран и упакован", "Сегодня"),
            ("Передан в \(delivery.carrier)", "Трек \(track)"),
            ("В пути", delivery.days),
            ("Доставлен", delivery == .cdek ? "До двери" : "В отделение")
        ]
    }
}

// MARK: - Content

struct Episode: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let date: String
}

enum Talk {
    static let featured = Episode(title: "Румяна Sen Sulu — тот самый важный штрих в макияже", date: "29 сентября 2026")
    static let episodes: [Episode] = [
        Episode(title: "Созданы, чтобы вы сияли", date: "22 окт"),
        Episode(title: "Чёрная или коричневая?", date: "22 окт"),
        Episode(title: "Идеальные ресницы с Sen Sulu", date: "22 окт"),
        Episode(title: "Сұлулықтың сан қыры", date: "19 окт"),
        Episode(title: "Суперсила фиксатора Sen Sulu", date: "7 окт"),
        Episode(title: "Avika Gor x Sen Sulu — Beauty in the Details", date: "7 окт"),
        Episode(title: "Контур-карандаш", date: "5 окт"),
        Episode(title: "Контуринг по форме лица", date: "1 окт"),
        Episode(title: "Макияж губ с эффектом омбре", date: "29 сен")
    ]
    static let channel = URL(string: "https://www.youtube.com/@SenSulu2023")!
}

nonisolated enum HelpTab: String, CaseIterable, Hashable {
    case pay = "Оплата", delivery = "Доставка", returns = "Возврат"
}

enum FAQ {
    static let items: [HelpTab: [(String, String)]] = [
        .pay: [
            ("Какие способы оплаты доступны?", "Kaspi Gold, Kaspi Red, Kaspi Рассрочка, Halyk Bank и BCC (Банк ЦентрКредит)."),
            ("Как получить электронный чек?", "Чек появится в приложении сразу после оплаты — в разделе «Заказы»."),
            ("Можно ли изменить заказ после оформления?", "Пока заказ не передан в доставку — да, напишите нам в WhatsApp или Telegram.")
        ],
        .delivery: [
            ("Сколько занимает доставка?", "По Казахстану: СДЭК Экспресс — 4–5 рабочих дней, Казпочта — 7–12.\nМеждународная: СДЭК — 8–10, Казпочта — до 30 рабочих дней."),
            ("Сколько стоит доставка?", "Казпочта — 1 600 ₸.\nСДЭК Экспресс до двери — 3 500–4 000 ₸."),
            ("Есть ли бесплатная доставка?", "Пока нет: стоимость доставки не зависит от суммы заказа."),
            ("Можно ли выбрать дату доставки?", "Да — укажите её при оформлении, постараемся учесть."),
            ("Куда вы доставляете?", "Почти во все страны и города мира, кроме США.")
        ],
        .returns: [
            ("Сколько дней на возврат?", "Товар надлежащего качества — 14 календарных дней с момента получения, если упаковка не вскрыта и сохранён товарный вид."),
            ("А если товар с браком?", "Принимаем в течение гарантийного срока, указанного на упаковке.")
        ]
    ]
}

enum Stores {
    static let countries = ["Казахстан", "Россия", "Узбекистан", "Кыргызстан", "Таджикистан", "Армения", "Азербайджан", "Молдова", "Монголия", "Южная Корея", "Туркменистан"]
    static let cities: [(String, Int)] = [
        ("Алматы", 16), ("Астана", 12), ("Атырау", 13), ("Караганда", 11), ("Актау", 9), ("Уральск", 8),
        ("Актобе", 7), ("Усть-Каменогорск", 7), ("Экибастуз", 6), ("Шымкент", 3), ("Тараз", 5), ("Павлодар", 5)
    ]
    static let astana = ["cosmetica.kz", "beautypowerkz", "kiwano_astana", "osima_cosmetics", "blosskin_", "vanil.kz",
                         "oppamart.kz", "lumi.astana", "beautyqode.kz", "cosmetics_star_astana", "sen_sulu_beauty_shop_02", "skinnovation.astana"]
}

enum Links {
    static let instagram = URL(string: "https://www.instagram.com/sensulu.cosmeticss")!
    static let tiktok = URL(string: "https://www.tiktok.com/@sensulu.official")!
    static let youtube = URL(string: "https://www.youtube.com/@SenSulu2023")!
    static let telegram = URL(string: "https://t.me/sensulu03")!
    static let whatsapp = URL(string: "https://wa.me/message/EK3745VD47SBF1")!
    static let privacy = URL(string: "https://sen-sulu.com/privacy")!
}

// MARK: - Navigation

nonisolated enum Route: Hashable {
    case product(Product)
    case cart
    case shade
    case apply
    case box(Product)
    case talk
    case search
    case help(HelpTab)
    case stores
    case collab
    case creator(CreatorKind)
    case b2b
    case club
}

nonisolated enum CreatorKind: String, Hashable {
    case blogger, makeup
    var title: String { self == .blogger ? "Анкета креатора" : "Анкета визажиста" }
}

nonisolated enum Tab: Int, CaseIterable {
    case home, catalog, talk, club, profile

    var title: String {
        switch self {
        case .home: return "Главная"
        case .catalog: return "Каталог"
        case .talk: return "Talk"
        case .club: return "Club"
        case .profile: return "Профиль"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .catalog: return "square.grid.2x2"
        case .talk: return "play.rectangle"
        case .club: return "diamond"
        case .profile: return "person"
        }
    }
}

extension String {
    nonisolated func leftPadded(to length: Int, with ch: Character = "0") -> String {
        count >= length ? self : String(repeating: ch, count: length - count) + self
    }
}
