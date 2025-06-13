//
//  Models.swift
//  SnatchIt
//
//  Created by Reiwa on 07.06.2025.
//
import Foundation
import FirebaseFirestore   // required for @DocumentID

// Single expense item
struct Expense: Identifiable, Codable {
    @DocumentID var id: String?
    
    var amount: Double
    var category: String
    var date: Date
    var comment: String?
    
    init(id: UUID = UUID(), amount: Double, category: String, date: Date, comment: String?) {
        self.amount = amount
        self.category = category
        self.date = date
        self.comment = comment
    }
    
    // User information
    
    struct User: Identifiable, Codable {
        var id = UUID()
        var email: String
        var name: String
        
        init(id: UUID = UUID(), email: String, name: String) {
            self.id = id
            self.email = email
            self.name = name
        }
    }
    
    // Represents group of users sharing expenses
    
    struct SharedGroup: Identifiable, Codable {
        var id = UUID()
        var groupName: String
        var members: [User]
        var expenses: [Expense]
        
        init(id: UUID = UUID(), groupName: String, members: [User], expenses: [Expense]) {
            self.id = id
            self.groupName = groupName
            self.members = members
            self.expenses = expenses
        }
    }
}
