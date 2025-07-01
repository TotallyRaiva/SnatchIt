//
//  RecruitCrewView.swift
//  SnatchIt
//
//  Created by Reiwa on 01.07.2025.
//
import SwiftUI

struct RecruitCrewView: View {
    @Environment(\.dismiss) var dismiss
    @State private var input = ""

    var onRecruit: (String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Invite by Email or UID")) {
                    TextField("e.g. snatcher@email.com or uid123", text: $input)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Recruit Crew")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send Invite") {
                        onRecruit(input)
                        dismiss()
                    }
                    .disabled(input.isEmpty)
                }
            }
        }
    }
}
#Preview {
    RecruitCrewView { input in
        print("Recruit: \(input)")
    }
}
