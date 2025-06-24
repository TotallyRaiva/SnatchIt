//
//  CreateGangView.swift
//  SnatchIt
//
//  Created by Reiwa on 24.06.2025.
//
import SwiftUI

struct CreateGangView: View {
    @Environment(\.dismiss) var dismiss
    @State private var gangName = ""
    @State private var gangDescription = ""
    @State private var avatar = "💰"
    @State private var isLoading = false
    // Completion handler or view model for gang creation
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gang Name")) {
                    TextField("e.g. The Fast Looters", text: $gangName)
                }
                Section(header: Text("Avatar (emoji/SF Symbol)")) {
                    TextField("e.g. 💰 or safe.fill", text: $avatar)
                }
                Section(header: Text("Description (optional)")) {
                    TextField("Say what makes your gang legendary", text: $gangDescription)
                }
            }
            .navigationTitle("Start a New Gang")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Become the Boss") {
                        // Call create function here
                        isLoading = true
                        // ...
                    }
                    .disabled(gangName.isEmpty)
                }
            }
        }
    }
}
#Preview {
    CreateGangView()
}
