//
//  GangDetailsViewModel.swift
//  SnatchIt
//
//  Created by Reiwa on 02.07.2025.
//
import Foundation
import FirebaseFirestore

class GangDetailsViewModel: ObservableObject {
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    let gang: SharedGroup

    init(gang: SharedGroup) {
        self.gang = gang
    }

    /// Invite a user by email or UID. Handles Firestore update.
    func recruitCrew(invitee: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        // First, determine if input is UID or email
        if invitee.contains("@") {
            // Lookup by email
            db.collection("users").whereField("email", isEqualTo: invitee).getDocuments { snapshot, error in
                if let uid = snapshot?.documents.first?.documentID {
                    self.sendGangInvite(uid: uid, completion: completion)
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "User with that email not found."
                        completion(false)
                    }
                }
            }
        } else {
            // Treat as UID
            self.sendGangInvite(uid: invitee, completion: completion)
        }
    }

    /// Adds the user UID to pendingInvites array of the group.
    private func sendGangInvite(uid: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let groupRef = db.collection("groups").document(gang.id ?? "")
        groupRef.updateData([
            "pendingInvites": FieldValue.arrayUnion([uid])
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to send invite: \(error.localizedDescription)"
                    completion(false)
                } else {
                    self.successMessage = "Invite sent!"
                    completion(true)
                }
            }
        }
        // Optionally, update user doc for quick lookup:
        let userRef = db.collection("users").document(uid)
        userRef.updateData([
            "gangInvites": FieldValue.arrayUnion([gang.id ?? ""])
        ])
    }
}
