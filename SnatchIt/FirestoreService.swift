//
//  FirestoreService.swift
//  SnatchIt
//
//  Created by Reiwa on 10.06.2025.
//
import Foundation
import FirebaseFirestore

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()

    @Published var expenses: [Expense] = []

    func addExpense(_ expense: Expense, forUser userID: String) {
        do {
            let _ = try db.collection("users").document(userID)
                .collection("expenses").addDocument(from: expense)
        } catch {
            print("Error adding expense: \(error.localizedDescription)")
        }
    }

    func fetchExpenses(forUser userID: String) {
        db.collection("users").document(userID)
            .collection("expenses")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching expenses: \(error.localizedDescription)")
                    return
                }

                self.expenses = snapshot?.documents.compactMap { document in
                    try? document.data(as: Expense.self)
                } ?? []
            }
    }
}
