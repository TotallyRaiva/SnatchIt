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
    @EnvironmentObject var firestoreService: FirestoreService
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

                SpendingChartView()
                    .tag(1)
                    .tabItem {
                        Label("Charts", systemImage: "chart.bar")
                    }

                GangsView(userId: authService.user?.id ?? "", firestoreService: firestoreService)
                    .tag(2)
                    .tabItem {
                        Label("Gangs", systemImage: "person.3.sequence.fill")
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
                userId: authService.user?.id ?? ""
            )
        }
        .onChange(of: showAddExpense) {
            if showAddExpense {
                print("Sheet presenting. userId: \(authService.user?.id ?? "nil")")
            }
        }
    }
}

#Preview {
    MainTabView(authService: AuthService())
        .environmentObject(FirestoreService())
}
