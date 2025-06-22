//
//  ExpenseFormView.swift
//  SnatchIt
//
//  Created by Reiwa on 12.06.2025.
//
import SwiftUI

struct ExpenseFormView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var firestoreService: FirestoreService
    var userId: String
    var existingExpense: Expense?
    
static let predefinedCategories = [
    "🏁Quicky(Edit me)",
    "🛒 Groceries",
    "🚗 Transport",
    "🍽️ Dining",
    "🎮 Entertainment",
    "🩺 Health",
    "💡 Utilities",
    "🏠 Rent",
    "❓ Other"
]
    
    // Initialize state variables with existingExpense values if available
    @State private var amount: String
    @State private var category: String
    @State private var comment: String
    @State private var date: Date
    
    init(userId: String, existingExpense: Expense? = nil) {
        self.userId = userId
        self.existingExpense = existingExpense
        _amount = State(initialValue: existingExpense.map { String($0.amount) } ?? "")
        _category = State(initialValue: existingExpense?.category ?? "🏁Quicky(Edit me)")
        _comment = State(initialValue: existingExpense?.comment ?? "")
        _date = State(initialValue: existingExpense?.date ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Category")) {
                    Picker("Snatch type", selection: $category) {
                        ForEach(Self.predefinedCategories, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section(header: Text("Comment (Optional)")) {
                    TextField("What was it for?", text: $comment)
                }
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle(existingExpense == nil ? "Add Expense" : "Edit Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(amount.isEmpty || category.isEmpty)
                }
            }
        }
    }
    
    // Handles both new and existing expense saves
    private func saveExpense() {
        // Check that userId is not empty
        guard !userId.isEmpty else {
            print("User ID is empty, cannot save expense.")
            return
        }
        
        // Convert amount string to Double, print if fails
        guard let amountValue = Double(amount) else {
            print("Invalid amount entered: \(amount)")
            return
        }
        
        // Create or update expense object
        var expense: Expense
        if let existing = existingExpense {
            // Editing existing expense: update fields
            expense = existing
            expense.amount = amountValue
            expense.category = category
            expense.comment = comment.isEmpty ? nil : comment
            expense.date = date
        } else {
            // Creating new expense
            expense = Expense(amount: amountValue, category: category, date: date, comment: comment.isEmpty ? nil : comment, userId: userId, groupId: nil)
        }
        
        // Print userId and expense before saving
        print("Saving expense for userId: \(userId)")
        print("Expense details: \(expense)")
        
        if existingExpense == nil {
            firestoreService.addExpense(expense, forUser: userId)
        } else {
            firestoreService.updateExpense(expense, forUser: userId)
        }
        dismiss()
    }
}

#Preview {
    ExpenseFormView(userId: "testUserId")
        .environmentObject(FirestoreService())
}
