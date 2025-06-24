//
//  Models.swift
//  SnatchIt
//
//  Created by Reiwa on 07.06.2025.
//
import Foundation
import FirebaseFirestore

// MARK: - Expense Model
// Represents a single spending record, either personal or shared.
// Each expense belongs to a user and can optionally be part of a group.
struct Expense: Identifiable, Codable {
    @DocumentID var id: String?         // Unique Firestore document ID
    var amount: Double                  // Amount spent
    var category: String                // Category (e.g. Groceries, Rent)
    var date: Date                      // When the expense occurred
    var comment: String?                // Optional comment/note
    var userId: String                  // Who added this expense (user UID)
    var groupId: String?                // If present, this expense belongs to a group

    init(id: String? = nil, amount: Double, category: String, date: Date, comment: String? = nil, userId: String, groupId: String? = nil) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.comment = comment
        self.userId = userId
        self.groupId = groupId
    }
}

// MARK: - User Model
// Represents an app user, with info for personalization and groups.
// The user's id is their Firebase Auth UID.
struct User: Identifiable, Codable {
    var id: String          // Firebase UID (unique user ID)
    var email: String       // User's email (for login)
    var nickname: String    // Display name or nickname
    var avatar: String?     // Avatar/icon for personalization (SF Symbol name or URL)
    var groups: [String]?   // List of group IDs this user is a member of

    init(id: String, email: String, nickname: String, avatar: String? = nil, groups: [String]? = nil) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.avatar = avatar
        self.groups = groups
    }
}

// MARK: - SharedGroup (Gang) Model
// Represents a gang in SnatchIt (shared budget group).
// Holds the gang's info and membership/Boss lists.
// Only UIDs are stored for members and Bosses (admins).
// Nicknames and avatars should be fetched dynamically from the users collection using UIDs in the view/viewmodel.
struct SharedGroup: Identifiable, Codable {
    @DocumentID var id: String?         // Unique Firestore document ID
    var name: String                    // Gang display name
    var members: [String]               // UIDs of all gang members
    var bosses: [String]                // UIDs of gang Bosses (admins/owners)
    var inviteCode: String?             // Optional: code for easy joining
    var createdAt: Date                 // Timestamp of gang creation

    // MARK: - Helper Methods (stubs to be implemented in ViewModel/Service)
    // Use these in a ViewModel/Service to connect to Firestore.
    static func createGroup(name: String, creatorUid: String, avatar: String?, completion: @escaping (Result<SharedGroup, Error>) -> Void) {
        // Implementation will create and save a new group in Firestore
    }

    static func joinGroup(groupId: String, userUid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Implementation will add user to group's members array in Firestore
    }

    static func leaveGroup(groupId: String, userUid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Implementation will remove user from group's members array in Firestore
    }
}
