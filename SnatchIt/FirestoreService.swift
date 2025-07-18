//
//  FirestoreService.swift
//  SnatchIt
//
//  Created by Reiwa on 10.06.2025.
//
import Foundation
import FirebaseFirestore

open class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()

    @Published var expenses: [Expense] = []
    @Published internal var userNicknames: [String: String] = [:]

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
        }
        catch {
            print("Update failed: \(error)")
        }
    }
    // Fetch all gangs for a given user (either as a member or with pending invites)
    func fetchUserGangs(for userId: String, completion: @escaping ([SharedGroup]) -> Void) {
        let groupsRef = db.collection("groups")
        
        groupsRef.whereField("members", arrayContains: userId)
            .getDocuments { memberSnapshot, memberError in
                let memberGroups = memberSnapshot?.documents.compactMap {
                    try? $0.data(as: SharedGroup.self)
                } ?? []
                
                groupsRef.whereField("pendingInvites", arrayContains: userId)
                    .getDocuments { inviteSnapshot, inviteError in
                        let inviteGroups = inviteSnapshot?.documents.compactMap {
                            try? $0.data(as: SharedGroup.self)
                        } ?? []
                        
                        let combinedGroups = memberGroups + inviteGroups
                        DispatchQueue.main.async {
                            completion(combinedGroups)
                        }
                    }
            }
    }

    // Create a new gang and link it to the creator
    func createGang(_ gang: SharedGroup, creatorUserId: String, completion: @escaping (Bool) -> Void) {
        guard let gangId = gang.id else {
            print("Error: gang.id is nil")
            completion(false)
            return
        }
        let gangRef = db.collection("groups").document(gangId)

        gangRef.setData([
            "name": gang.name,
            "bosses": gang.bosses,
            "members": gang.members,
            "createdAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error creating gang: \(error.localizedDescription)")
                completion(false)
                return
            }

            let userRef = self.db.collection("users").document(creatorUserId)
            userRef.updateData([
                "gangs": FieldValue.arrayUnion([gangId])
            ]) { userError in
                if let userError = userError {
                    print("Error updating user with new gang: \(userError.localizedDescription)")
                }
                completion(userError == nil)
            }
        }
    }

    // Remove a user from a gang
    func removeMember(fromGang gangId: String, userId: String, completion: @escaping (Bool) -> Void) {
        let groupRef = db.collection("groups").document(gangId)
        
        groupRef.updateData([
            "members": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                print("Error removing member: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // Fetch nicknames for a list of user IDs
    func fetchNicknames(for userIds: [String]) {
        for userId in userIds {
            // Skip if we already have the nickname
            if userNicknames[userId] != nil {
                continue
            }
            
            db.collection("users").document(userId).getDocument { snapshot, error in
                guard let data = snapshot?.data(), error == nil else { return }
                
                if let nickname = data["nickname"] as? String {
                    DispatchQueue.main.async {
                        self.userNicknames[userId] = nickname
                    }
                }
            }
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
