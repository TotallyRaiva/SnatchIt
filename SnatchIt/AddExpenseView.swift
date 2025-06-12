//
//  AddExpenseView.swift
//  SnatchIt
//
//  Created by Reiwa on 12.06.2025.
//
import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var firestoreService: FirestoreService
    var userId: String

    @State private var amount = ""
    @State private var category = ""
    @State private var comment = ""
    @State private var date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Category")) {
                    TextField("e.g. Groceries, Rent", text: $category)
                }
                Section(header: Text("Comment (Optional)")) {
                    TextField("What was it for?", text: $comment)
                }
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Expense")
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

    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        let newExpense = Expense(
            amount: amountValue,
            category: category,
            date: date,
            comment: comment.isEmpty ? nil : comment
        )
        firestoreService.addExpense(newExpense, forUser: userId)
        dismiss()
    }
}


#Preview {
    AddExpenseView(firestoreService: FirestoreService(), userId: "testUserId")
}
