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
        if authService.user != nil {
            DashboardView()
        } else {
            LoginView(authService: authService)
        }
    }
}

#Preview {
    ContentView()
}
