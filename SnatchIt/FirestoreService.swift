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
        print("Adding expense for userID:", userID)
        print("Expense to add:", expense)
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
    func deleteExpense(_ expense: Expense, forUser userID: String) {
        guard let docID = expense.id else { return }
        db.collection("users")
          .document(userID)
          .collection("expenses")
          .document(docID)
          .delete()
    }

    func updateExpense(_ expense: Expense, forUser userID: String) {
        guard let docID = expense.id else { return }
        do {
            try db.collection("users")
                  .document(userID)
                  .collection("expenses")
                  .document(docID)
                  .setData(from: expense, merge: true)
        } catch {
            print("Update failed: \(error)")
        }
    }
}

// MARK: - Gang Invitation Methods
extension FirestoreService {
    // Invite user to gang
    func sendGangInvite(to userId: String, for groupId: String, completion: @escaping (Error?) -> Void) {
        let groupRef = db.collection("groups").document(groupId)
        let userRef = db.collection("users").document(userId)

        let batch = db.batch()

        batch.updateData(["pendingInvites": FieldValue.arrayUnion([userId])], forDocument: groupRef)
        batch.updateData(["gangInvites": FieldValue.arrayUnion([groupId])], forDocument: userRef)

        batch.commit { error in
            if let error = error {
                print("Error sending gang invite: \(error)")
            }
            completion(error)
        }
    }

    // Accept gang invite
    func acceptGangInvite(groupId: String, userId: String, completion: @escaping (Error?) -> Void) {
        let groupRef = db.collection("groups").document(groupId)
        let userRef = db.collection("users").document(userId)

        let batch = db.batch()

        batch.updateData(["pendingInvites": FieldValue.arrayRemove([userId])], forDocument: groupRef)
        batch.updateData(["members": FieldValue.arrayUnion([userId])], forDocument: groupRef)
        batch.updateData(["gangInvites": FieldValue.arrayRemove([groupId])], forDocument: userRef)

        batch.commit { error in
            if let error = error {
                print("Error accepting gang invite: \(error)")
            }
            completion(error)
        }
    }

    // Decline gang invite
    func declineGangInvite(groupId: String, userId: String, completion: @escaping (Error?) -> Void) {
        let groupRef = db.collection("groups").document(groupId)
        let userRef = db.collection("users").document(userId)

        let batch = db.batch()

        batch.updateData(["pendingInvites": FieldValue.arrayRemove([userId])], forDocument: groupRef)
        batch.updateData(["gangInvites": FieldValue.arrayRemove([groupId])], forDocument: userRef)

        batch.commit { error in
            if let error = error {
                print("Error declining gang invite: \(error)")
            }
            completion(error)
        }
    }
}
