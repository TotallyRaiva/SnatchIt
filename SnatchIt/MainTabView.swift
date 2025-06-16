//
//  MainTabView.swift
//  SnatchIt
//
//  Created by Reiwa on 16.06.2025.
//
import SwiftUI
import Charts

struct MainTabView: View {
    @ObservedObject var authService: AuthService
    @State private var selectedTab = 0
    @State private var showAddExpense = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                DashboardView(authService: authService)
                    .tag(0)
                    .tabItem {
                        Label("Dashboard", systemImage: "house")
                    }

                SpendingChartView(expenses: []) // Replace with real data
                    .tag(1)
                    .tabItem {
                        Label("Charts", systemImage: "chart.bar")
                    }

                Text("History") // Placeholder
                    .tag(2)
                    .tabItem {
                        Label("History", systemImage: "clock")
                    }

                AccountView(authService: authService)
                    .tag(3)
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle")
                    }
            }
            .background(.ultraThinMaterial) // Simulated liquid glass

            // Floating Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showAddExpense = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .foregroundStyle(.primary)
                            .background(Circle().fill(.ultraThinMaterial))
                            .clipShape(Circle())
                            .shadow(radius: 8)
                    }
                    .offset(y: -32)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showAddExpense) {
            ExpenseFormView(
                firestoreService: FirestoreService(),
                userId: authService.user?.uid ?? ""
            )
        }
    }
}

#Preview {
    MainTabView(authService: AuthService())
}
