//
//  JournaliApp.swift
//  Journali
//
//  Created by Najd Alsabi on 28/04/1447 AH.
//

import SwiftUI
import SwiftData

@main
struct JournaliApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView() // Main UI
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: Entry.self) // SwiftData persistence
    }
}

