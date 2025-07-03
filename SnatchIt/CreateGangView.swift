//
//  CreateGangView.swift
//  SnatchIt
//
//  Created by Reiwa on 24.06.2025.
//
import SwiftUI
import FirebaseFirestore

struct CreateGangView: View {
    @Environment(\.dismiss) var dismiss
    @State private var gangName = ""
    @State private var gangDescription = ""
    @State private var avatar = "💰"
    @State private var isLoading = false
    
    // Closure to be called when gang creation is complete
    var onComplete: ((SharedGroup) -> Void)?
    
    // Current user's ID
    let userId: String
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gang Name")) {
                    TextField("e.g. The Fast Looters", text: $gangName)
                        .disabled(isLoading)
                }
                Section(header: Text("Avatar (emoji/SF Symbol)")) {
                    TextField("e.g. 💰 or safe.fill", text: $avatar)
                        .disabled(isLoading)
                }
                Section(header: Text("Description (optional)")) {
                    TextField("Say what makes your gang legendary", text: $gangDescription)
                        .disabled(isLoading)
                }
            }
            .navigationTitle("Start a New Gang")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(isLoading)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Become the Boss") {
                            createGang()
                        }
                        .disabled(gangName.isEmpty)
                    }
                }
            }
        }
    }
}

extension CreateGangView {
    private func createGang() {
        isLoading = true
        
        let db = Firestore.firestore()
        
        // Firestore requires Timestamp, not Date, for date fields
        // Explicitly set array types for Firestore compatibility
        let data: [String: Any] = [
            "name": gangName,
            "description": gangDescription,
            "avatar": avatar,
            "bosses": [String](arrayLiteral: userId),
            "members": [String](arrayLiteral: userId),
            "createdAt": Timestamp(date: Date()),
            "pendingInvites": [String]()
        ]
        
        // Add document and get reference to it
        let docRef = db.collection("groups").document()
        docRef.setData(data, completion: { error in
            isLoading = false
            if let error = error {
                print("Error creating gang: \(error.localizedDescription)")
                return
            }
            
            // Create SharedGroup instance with the document ID and data
            let newGroup = SharedGroup(
                id: docRef.documentID,
                name: gangName,
                description: gangDescription,
                avatar: avatar,
                members: [userId],
                bosses: [userId],
                inviteCode: nil,
                pendingInvites: [],
                createdAt: Date()
            )
            
            // Call the completion handler
            onComplete?(newGroup)
            
            // Dismiss the view
            dismiss()
        })
    }
}

#Preview {
    CreateGangView(userId: "testUser")
}
