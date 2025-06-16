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
    @State private var editingExpense: Expense?    // nil when not editing
    
    @State private var recentlyDeletedExpense: Expense? // UNDO
    @State private var showUndoAlert = false
    
    private var todayTotal: Double {
        firestoreService.expenses
            .filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    private var monthTotal: Double {
        let now = Date()
        let calendar = Calendar.current
        return firestoreService.expenses
            .filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .month)
            }
            .reduce(0) { $0 + $1.amount }
    }
    var body: some View {
        NavigationView {
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
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("💰 Today's Total: $\(todayTotal, specifier: "%.2f")")
                        .font(.headline)
                    Text("📆 This Month: $\(monthTotal, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 4)
                // Expense list
                List {
                    ForEach(firestoreService.expenses) { expense in
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
                            .padding(.vertical, 4)
                            HStack {
                                Text("Tap to edit")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Image(systemName: "trash")
                                    .font(.caption)
                                    .foregroundColor(.gray.opacity(0.4))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingExpense = expense
                        }
                    }
                    .onDelete { indexSet in
                        guard let userID = authService.user?.uid else { return }
                        if let index = indexSet.first {
                            let expense = firestoreService.expenses[index]
                            recentlyDeletedExpense = expense
                            firestoreService.deleteExpense(expense, forUser: userID)
                            showUndoAlert = true
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
                ExpenseFormView(
                    firestoreService: firestoreService,
                    userId: authService.user?.uid ?? ""
                )
            }
            .sheet(item: $editingExpense) { expense in
                ExpenseFormView(
                    firestoreService: firestoreService,
                    userId: authService.user?.uid ?? "",
                    existingExpense: expense
                )
            }
            .alert("Expense Deleted", isPresented: $showUndoAlert) {
                Button("Undo", role: .cancel) {
                    if let expense = recentlyDeletedExpense {
                        firestoreService.addExpense(expense, forUser: authService.user?.uid ?? "")
                        recentlyDeletedExpense = nil
                    }
                }
                Button("OK", role: .destructive) { }
            } message: {
                Text("You can undo this action.")
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    NavigationLink("📊 View Chart") {
                        SpendingChartView(expenses: firestoreService.expenses)
                    }
                    Spacer()
                    Button("Logout") {
                        authService.signOut()
                    }
                }
            }
        }
    }
}
    #Preview {
        DashboardView(authService: AuthService())
    }
