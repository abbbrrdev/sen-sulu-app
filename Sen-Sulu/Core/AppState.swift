import SwiftUI
import Observation

@Observable
final class AppState {
    // Flow
    var entered = false
    var tab: Tab = .home
    var homePath: [Route] = []
    var catalogPath: [Route] = []
    var talkPath: [Route] = []
    var clubPath: [Route] = []
    var profilePath: [Route] = []
    var catalogFilter: Kind? = nil

    // User
    var name = "Айгерим"
    var phone = "+7 701 ••• •• 12"
    var points = 1240
    var myShade: Int? = nil          // index in Catalog.blushShades
    var favorites: Set<String> = []
    var language = "ru"
    var currency = "kzt"
    var orderNotifications = true

    // Cart & order
    var cart: [CartItem] = []
    var order: Order? = nil
    var showTrack = false
    private var orderTask: Task<Void, Never>? = nil

    var cartCount: Int { cart.reduce(0) { $0 + $1.qty } }
    var subtotal: Int { cart.reduce(0) { $0 + $1.total } }

    // MARK: Navigation helpers

    func push(_ route: Route) {
        switch tab {
        case .home: homePath.append(route)
        case .catalog: catalogPath.append(route)
        case .talk: talkPath.append(route)
        case .club: clubPath.append(route)
        case .profile: profilePath.append(route)
        }
    }

    func popToRoot() {
        switch tab {
        case .home: homePath.removeAll()
        case .catalog: catalogPath.removeAll()
        case .talk: talkPath.removeAll()
        case .club: clubPath.removeAll()
        case .profile: profilePath.removeAll()
        }
    }

    func openCatalog(_ filter: Kind?) {
        catalogFilter = filter
        catalogPath.removeAll()
        tab = .catalog
    }

    // MARK: Cart

    func add(_ product: Product, shade: Int?, qty: Int = 1, gift: Bool = false) {
        if let i = cart.firstIndex(where: { $0.product.id == product.id && $0.shade == shade && $0.gift == gift }) {
            cart[i].qty += qty
        } else {
            cart.append(CartItem(product: product, shade: shade, qty: qty, gift: gift))
        }
    }

    func isInCart(_ product: Product, shade: Int?) -> Bool {
        cart.contains { $0.product.id == product.id && $0.shade == shade }
    }

    func setQty(_ item: CartItem, _ qty: Int) {
        guard let i = cart.firstIndex(where: { $0.id == item.id }) else { return }
        if qty <= 0 { cart.remove(at: i) } else { cart[i].qty = qty }
    }

    func toggleFavorite(_ product: Product) {
        if favorites.contains(product.id) { favorites.remove(product.id) } else { favorites.insert(product.id) }
    }

    // MARK: Order (mock backend: statuses advance and push notifications arrive)

    /// Seconds after checkout when each status arrives — kept short so the whole flow fits a demo recording.
    static let stageDelays: [Double] = [0, 4, 12, 20, 30, 42]

    func placeOrder(delivery: Delivery, payment: Payment, usePoints: Bool) {
        let items = cart
        let pointsUsed = usePoints ? min(points, subtotal) : 0
        let total = subtotal - pointsUsed + delivery.price
        let number = "SS-\(Int.random(in: 10400...10999))"
        let track = "1094 5532 81"
        let earned = Int(Double(subtotal - pointsUsed) * 0.05)
        order = Order(number: number, track: track, items: items, total: total,
                      payment: payment, delivery: delivery, placed: Date(),
                      pointsUsed: pointsUsed, pointsEarned: earned)
        points = points - pointsUsed + earned
        cart.removeAll()
        homePath.removeAll()
        catalogPath.removeAll()
        profilePath.removeAll()
        clubPath.removeAll()
        talkPath.removeAll()
        showTrack = true

        if orderNotifications {
            NotificationManager.shared.scheduleOrderUpdates(number: number, track: track, payment: payment, delivery: delivery)
        }

        orderTask?.cancel()
        orderTask = Task { [weak self] in
            for stage in 1..<AppState.stageDelays.count {
                let wait = AppState.stageDelays[stage] - AppState.stageDelays[stage - 1]
                try? await Task.sleep(for: .seconds(wait))
                if Task.isCancelled { return }
                withAnimation(.spring(duration: 0.5)) {
                    self?.order?.stage = stage
                }
            }
        }
    }
}
