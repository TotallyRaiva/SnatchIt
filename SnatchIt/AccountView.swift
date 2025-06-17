//
//  AccountView.swift
//  SnatchIt
//
//  Created by Reiwa on 16.06.2025.
//
import SwiftUI

struct AccountView: View {
    @ObservedObject var authService: AuthService

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Placeholder avatar and user info
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)

                Text("Logged in as:")
                    .font(.headline)

                Text(authService.user?.email ?? "Unknown User")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Button(role: .destructive) {
                    authService.signOut()
                } label: {
                    Label("Logout", systemImage: "arrow.right.circle")
                }
                .padding(.bottom, 100)
            }
            .padding()
            .navigationTitle("Account")
        }
    }
}

#Preview {
    AccountView(authService: AuthService())
}
