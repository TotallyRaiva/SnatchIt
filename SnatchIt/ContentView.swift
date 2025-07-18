//
//  ContentView.swift
//  SnatchIt
//
//  Created by Reiwa on 07.06.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService()
    @StateObject private var firestoreService = FirestoreService()

    var body: some View {
        if let _ = authService.user {
            MainTabView(authService: authService)
                .environmentObject(firestoreService)
        } else {
            LoginView(authService: authService)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
