//
//  GangDetailsViewModel.swift
//  SnatchIt
//
//  Created by Reiwa on 02.07.2025.
//
import Foundation
import FirebaseFirestore

/// Model representing a crew member's profile for display.
struct CrewMemberProfile: Identifiable {
    let id: String
    let nickname: String
    let avatar: String?
    let isBoss: Bool
}

class GangDetailsViewModel: ObservableObject {
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var inviteInput: String = ""
    @Published var confirmKickMember: CrewMemberProfile? = nil
    
    let gang: SharedGroup
    
    init(gang: SharedGroup) {
        self.gang = gang
    }
    
    /// Invite a user by email or UID. Handles Firestore update.
    func recruitCrew(invitee: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        // Determine if input is email or UID
        if invitee.contains("@") {
            // Lookup user by email
            db.collection("users").whereField("email", isEqualTo: invitee).getDocuments { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error finding user: \(error.localizedDescription)"
                        completion(false)
                    }
                    return
                }
                
                guard let uid = snapshot?.documents.first?.documentID else {
                    DispatchQueue.main.async {
                        self.errorMessage = "User with that email not found."
                        completion(false)
                    }
                    return
                }
                
                self.sendGangInvite(uid: uid, completion: completion)
            }
        } else {
            // Treat input as UID
            self.sendGangInvite(uid: invitee, completion: completion)
        }
    }
    
    /// Adds the user UID to pendingInvites array of the group and gangInvites in the user doc.
    private func sendGangInvite(uid: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let groupId = gang.id ?? ""
        
        let groupRef = db.collection("groups").document(groupId)
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
        
        // Add gang ID to user's invite list
        let userRef = db.collection("users").document(uid)
        userRef.updateData([
            "gangInvites": FieldValue.arrayUnion([groupId])
        ]) { error in
            if let error = error {
                print("Warning: Could not update user invite list: \(error.localizedDescription)")
            }
        }
    }
    
    /// Accept a pending invite for a user
    func acceptInvite(forUserId userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let groupId = gang.id ?? ""
        let groupRef = db.collection("groups").document(groupId)
        let userRef = db.collection("users").document(userId)
        
        let batch = db.batch()
        batch.updateData([
            "members": FieldValue.arrayUnion([userId]),
            "pendingInvites": FieldValue.arrayRemove([userId])
        ], forDocument: groupRef)
        
        batch.updateData([
            "gangInvites": FieldValue.arrayRemove([groupId])
        ], forDocument: userRef)
        
        batch.commit { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to accept invite: \(error.localizedDescription)"
                    completion(false)
                } else {
                    self.successMessage = "Joined the gang!"
                    completion(true)
                }
            }
        }
    }
    
    /// Decline a pending invite for a user
    func declineInvite(forUserId userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let groupId = gang.id ?? ""
        let groupRef = db.collection("groups").document(groupId)
        let userRef = db.collection("users").document(userId)
        
        let batch = db.batch()
        batch.updateData([
            "pendingInvites": FieldValue.arrayRemove([userId])
        ], forDocument: groupRef)
        
        batch.updateData([
            "gangInvites": FieldValue.arrayRemove([groupId])
        ], forDocument: userRef)
        
        batch.commit { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to decline invite: \(error.localizedDescription)"
                    completion(false)
                } else {
                    self.successMessage = "Declined the invite."
                    completion(true)
                }
            }
        }
    }
    
    /// Kick member from gang
    func kickCrew(memberId: String, completion: @escaping (Bool) -> Void) {
        guard let gangId = gang.id else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let gangRef = db.collection("groups").document(gangId)
        
        gangRef.updateData([
            "members": FieldValue.arrayRemove([memberId])
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error kicking member: \(error.localizedDescription)"
                    completion(false)
                } else {
                    self.successMessage = "Crew member kicked."
                    completion(true)
                }
            }
            // Remove gang from user's document
            let userRef = db.collection("users").document(memberId)
            userRef.updateData([
                "gangs": FieldValue.arrayRemove([gangId])
            ]) { error in
                if let error = error {
                    print("Warning: Could not update user gang list: \(error.localizedDescription)")
                }
            }
        }
    }
    
}
