//
//  DashboardView.swift
//  SnatchIt
//
//  Created by Reiwa on 09.06.2025.
//
import SwiftUI

struct DashboardView: View {
    @StateObject private var firestoreService = FirestoreService()
    @ObservedObject var authService: AuthService
    
    @State private var showingAddExpense = false

    var body: some View {
        VStack {
            // Header with title and add button
            HStack {
                Text("🏠 My Expenses")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: {
                    showingAddExpense = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                }
                .accessibilityLabel("Add Expense")
            }
            .padding(.horizontal)
            .padding(.top)

            // Expense list
            List(firestoreService.expenses) { expense in
                VStack(alignment: .leading) {
                    Text(expense.category)
                        .font(.headline)
                    Text(expense.comment ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack {
                        Text("$\(expense.amount, specifier: "%.2f")")
                        Spacer()
                        Text(expense.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()
        }
        .onAppear {
            if let userId = authService.user?.uid {
                firestoreService.fetchExpenses(forUser: userId)
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(
                firestoreService: firestoreService,
                userId: authService.user?.uid ?? ""
            )
        }
    }
}

#Preview {
    DashboardView(authService: AuthService())
}
