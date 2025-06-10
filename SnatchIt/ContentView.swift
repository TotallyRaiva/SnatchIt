//
//  ContentView.swift
//  SnatchIt
//
//  Created by Reiwa on 07.06.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService()

    var body: some View {
        if let _ = authService.user {
            DashboardView(authService: authService)
        } else {
            LoginView(authService: authService)
        }
    }
}

#Preview {
    ContentView()
}
