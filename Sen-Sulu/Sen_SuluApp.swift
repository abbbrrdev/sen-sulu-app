//
//  Sen_SuluApp.swift
//  Sen-Sulu
//
//  Created by Рауан Аблайхан on 27.10.2026.
//

import SwiftUI

@main
struct Sen_SuluApp: App {
    @State private var state = AppState()

    init() {
        SSFonts.register()
        NotificationManager.shared.setup()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(state)
                .onAppear {
                    NotificationManager.shared.onOpenOrder = { [state] in
                        if state.order != nil { state.showTrack = true }
                    }
                }
        }
    }
}
