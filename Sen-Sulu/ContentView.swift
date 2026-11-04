//
//  ContentView.swift
//  Sen-Sulu
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        ZStack {
            if state.entered {
                MainView()
                    .transition(.opacity)
            } else {
                SplashView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: state.entered)
        .buttonStyle(FlatStyle())
    }
}

struct MainView: View {
    @Environment(AppState.self) private var state

    var body: some View {
        @Bindable var state = state
        ZStack {
            switch state.tab {
            case .home:
                NavigationStack(path: $state.homePath) {
                    HomeView().withTabBar().routes()
                }
            case .catalog:
                NavigationStack(path: $state.catalogPath) {
                    CatalogView().withTabBar().routes()
                }
            case .talk:
                NavigationStack(path: $state.talkPath) {
                    TalkView(isRoot: true).withTabBar().routes()
                }
            case .club:
                NavigationStack(path: $state.clubPath) {
                    ClubView(isRoot: true).withTabBar().routes()
                }
            case .profile:
                NavigationStack(path: $state.profilePath) {
                    ProfileView().withTabBar().routes()
                }
            }
        }
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $state.showTrack) {
            TrackView()
                .environment(state)
        }
        .onAppear { NotificationManager.shared.requestAuthorization() }
    }
}

// MARK: - Tab bar (shown only on the root of each tab — pushed screens slide over it, like in the design)

struct SSTabBar: View {
    @Environment(AppState.self) private var state

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                let on = state.tab == tab
                Button {
                    if state.tab == tab { state.popToRoot() } else { state.tab = tab }
                } label: {
                    VStack(spacing: 5) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: .light))
                                .frame(height: 24)
                            if tab == .profile && state.cartCount > 0 {
                                Circle().fill(Color.ssGold).frame(width: 7, height: 7).offset(x: 5, y: -1)
                            }
                        }
                        Text(tab.title.uppercased())
                            .font(.mont(9, on ? .semibold : .regular))
                            .tracking(9 * 0.14)
                    }
                    .foregroundStyle(on ? Color.ssInk : Color.ssMuted2)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 9)
                    .contentShape(Rectangle())
                }
                .buttonStyle(FlatStyle())
                .accessibilityLabel(tab.title)
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 2)
        .background(Color.ssIvory.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) { Rectangle().fill(Color.ssLine).frame(height: 1) }
        .sensoryFeedback(.selection, trigger: state.tab)
    }
}

extension View {
    func withTabBar() -> some View {
        self.safeAreaInset(edge: .bottom, spacing: 0) { SSTabBar() }
            .hideNavBar()
    }

    func routes() -> some View {
        self.navigationDestination(for: Route.self) { route in
            RouteView(route: route)
        }
    }
}

struct RouteView: View {
    let route: Route

    var body: some View {
        Group {
            switch route {
            case .product(let p): ProductView(product: p)
            case .cart: CartView()
            case .shade: ShadeFinderView()
            case .apply: ApplyView()
            case .box(let p): BoxView(box: p)
            case .talk: TalkView(isRoot: false)
            case .search: SearchView()
            case .help(let t): HelpView(initial: t)
            case .stores: StoresView()
            case .collab: CollabView()
            case .creator(let k): CreatorFormView(kind: k)
            case .b2b: B2BView()
            case .club: ClubView(isRoot: false)
            }
        }
        .hideNavBar()
    }
}

#Preview {
    ContentView().environment(AppState())
}
