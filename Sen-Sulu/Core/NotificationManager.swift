import Foundation
import UserNotifications

/// Mock push notifications: local notifications that mirror what a real order backend would send.
/// They show as banners even while the app is open, so they appear in a screen recording.
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    /// Called when the user taps an order notification.
    var onOpenOrder: (() -> Void)?

    func setup() {
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleOrderUpdates(number: String, track: String, payment: Payment, delivery: Delivery) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: (1...5).map { "order-\($0)" })
        let messages: [(String, String)] = [
            ("Оплата прошла", "Заказ \(number) оплачен через \(payment.rawValue). Уже собираем 🤍"),
            ("Заказ собран", "Упаковали каждую баночку с любовью. Скоро передадим в доставку."),
            ("Передан в \(delivery.carrier)", "Трек-номер \(track) — статус теперь в приложении."),
            ("Заказ в пути", delivery == .cdek ? "Курьер СДЭК привезёт заказ \(delivery.days.replacingOccurrences(of: "рабочих ", with: "раб. "))." : "Посылка едет в ваше отделение Казпочты."),
            ("Ваш заказ прибыл", delivery == .cdek ? "Курьер у двери. Сен сұлусың 🤍" : "Заказ ждёт вас в отделении. Сен сұлусың 🤍")
        ]
        for (i, msg) in messages.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = msg.0
            content.body = msg.1
            content.sound = .default
            content.threadIdentifier = "order-\(number)"
            content.userInfo = ["route": "order"]
            let delay = AppState.stageDelays[i + 1]
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
            center.add(UNNotificationRequest(identifier: "order-\(i + 1)", content: content, trigger: trigger))
        }
    }

    func sendTest() {
        let content = UNMutableNotificationContent()
        content.title = "Новинка в Sen Sulu Talk"
        content.body = "Румяна Sen Sulu — тот самый важный штрих. Смотрите выпуск и покупайте образ."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "test-\(UUID().uuidString)", content: content, trigger: trigger))
    }

    // MARK: UNUserNotificationCenterDelegate

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse) async {
        let isOrder = response.notification.request.identifier.hasPrefix("order-")
        guard isOrder else { return }
        await MainActor.run {
            NotificationManager.shared.onOpenOrder?()
        }
    }
}
