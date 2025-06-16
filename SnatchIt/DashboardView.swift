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
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header with title
                    HStack {
                        Text("🏠 My Expenses")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // Totals
                    VStack(alignment: .leading, spacing: 6) {
                        Text("💰 Today's Total: $\(todayTotal, specifier: "%.2f")")
                            .font(.headline)
                        Text("📆 This Month: $\(monthTotal, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    // Expense Cards
                    LazyVStack(spacing: 12) {
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
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingExpense = expense
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32) // for spacing above tab bar
                }
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
