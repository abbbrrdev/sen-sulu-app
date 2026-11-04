# Sen Sulu — iOS (SwiftUI) concept

Рабочий прототип приложения для бренда Sen Sulu по макету: 18 экранов, брендовые шрифты (Montserrat + Cormorant Garamond),
кампейн-видео на заставке, корзина с оплатой Kaspi / Halyk / BCC и моковые push-уведомления о статусе заказа.

## Запуск

1. Открыть `Sen-Sulu.xcodeproj` (Xcode 26).
2. Схема `Sen-Sulu`, симулятор **iPhone 17 Pro** → Run.
3. На главном экране разрешить уведомления.

Файлы лежат в синхронизированной папке `Sen-Sulu/` — Xcode подхватывает их сам, `project.pbxproj` трогать не нужно.

## Что внутри

| Экран | Где |
|---|---|
| Приветствие с видео, звук, язык | `Screens/SplashView.swift` |
| Главная: истории, бокс, бестселлеры, Talk, Club | `Screens/HomeView.swift` |
| Каталог с фильтрами | `Screens/CatalogView.swift` |
| Товар: галерея, оттенки, свотч, «в корзину» | `Screens/ProductView.swift` |
| Подбор оттенка (3 вопроса + результат) | `Screens/ShadeFinderView.swift` |
| До / после — перетаскиваемая шторка | `Screens/ApplyView.swift` |
| Подарочный бокс: открытка, дата | `Screens/BoxView.swift` |
| Sen Sulu Talk: выпуски, «купить образ» | `Screens/TalkView.swift` |
| Сұлу Club: карта, QR, привилегии | `Screens/ClubView.swift` |
| Корзина: СДЭК / Казпочта, Kaspi / Halyk / BCC, баллы | `Screens/CartView.swift` |
| Заказ: трек СДЭК, живые статусы, чек | `Screens/TrackView.swift` |
| Профиль, язык, валюта, уведомления | `Screens/ProfileView.swift` |
| FAQ, где купить, поиск | `Screens/InfoViews.swift` |
| Сотрудничество, анкета, B2B | `Screens/PartnerViews.swift` |

## Push-уведомления (моки)

**В приложении:** оформите заказ в корзине — статусы будут приходить баннерами и обновлять экран заказа:
оплата (4 с) → собран (12 с) → передан в СДЭК (20 с) → в пути (30 с) → **«Ваш заказ прибыл»** (42 с).
Баннеры видны и при открытом приложении. Тап по уведомлению открывает экран заказа.
Пример уведомления: Профиль → «Прислать пример уведомления».

**Из терминала** (как настоящий APNs), пока симулятор запущен:

```bash
xcrun simctl push booted abr.Sen-Sulu Push/5-arrived.apns
```

Или просто перетащите любой `.apns` из папки `Push/` на окно симулятора.

## Запись видео для ролика

```bash
# аккуратный статус-бар 9:41
xcrun simctl status_bar booted override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3

# показывать касания пальцем (перезапустить Simulator после команды)
defaults write com.apple.iphonesimulator ShowSingleTouches 1

# запись
xcrun simctl io booted recordVideo --codec=h264 --force demo.mp4
# … пройти сценарий, затем Ctrl+C
```

Сценарий для записи (~45 с): Войти → прокрутить главную → открыть «Румяна в стике» → выбрать 02 → «В корзину»
→ «Смотреть до / после» → потянуть шторку → назад → корзина → Kaspi Gold → «Оформить заказ» → дождаться пушей.
