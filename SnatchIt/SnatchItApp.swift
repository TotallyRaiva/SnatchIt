//
//  SnatchItApp.swift
//  SnatchIt
//
//  Created by Reiwa on 07.06.2025.
//

import SwiftUI
import Firebase

@main
struct SnatchItApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
