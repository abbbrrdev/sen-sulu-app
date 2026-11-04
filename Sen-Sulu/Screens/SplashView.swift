import SwiftUI

struct SplashView: View {
    @Environment(AppState.self) private var state
    @State private var video = VideoController(resource: "hero")
    @State private var muted = true
    @State private var appeared = false

    var body: some View {
        @Bindable var state = state
        ZStack {
            Color.black.ignoresSafeArea()
            LoopingVideoView(controller: video)
                .ignoresSafeArea()
            Color(hex: 0x0A0A0A, alpha: 0.34).ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    LogoLockup(color: .ssIvory, markSize: 30, vertical: true)
                    HStack {
                        Spacer()
                        Button {
                            muted.toggle()
                            video.setMuted(muted)
                        } label: {
                            Image(systemName: muted ? "speaker.slash" : "speaker.wave.2")
                                .font(.system(size: 17, weight: .light))
                                .foregroundStyle(Color.ssIvory)
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel(muted ? "Включить звук" : "Выключить звук")
                    }
                    .padding(.trailing, 12)
                }
                .padding(.top, 14)

                Spacer()

                VStack(alignment: .leading, spacing: 18) {
                    Text("SENSULU")
                        .font(.mont(30))
                        .tracking(30 * 0.3)
                        .foregroundStyle(Color.ssIvory)
                    Text("Гармония стиля, макияжа и доступной роскоши.")
                        .font(.mont(14, .light))
                        .lineSpacing(5)
                        .foregroundStyle(Color(hex: 0xECE6E1))
                    VStack(spacing: 10) {
                        SSButton(title: "Войти", style: .filledLight, height: 52) {
                            state.tab = .home
                            state.entered = true
                        }
                        SSButton(title: "В каталог", style: .outlineLight, height: 52) {
                            state.tab = .catalog
                            state.entered = true
                        }
                    }
                    .padding(.top, 6)

                    HStack(spacing: 4) {
                        ForEach([("kk", "ҚАЗ"), ("ru", "РУС"), ("en", "ENG")], id: \.0) { item in
                            let on = state.language == item.0
                            Button { state.language = item.0 } label: {
                                Text(item.1)
                                    .font(.mont(11))
                                    .tracking(11 * 0.2)
                                    .underline(on, color: Color.ssIvory)
                                    .foregroundStyle(on ? Color.ssIvory : Color.ssSand)
                                    .frame(minWidth: 52, minHeight: 44)
                            }
                            .buttonStyle(FlatStyle())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .sensoryFeedback(.selection, trigger: state.language)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 24)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            video.play()
            withAnimation(.easeOut(duration: 0.9).delay(0.3)) { appeared = true }
        }
        .onDisappear { video.pause() }
    }
}
