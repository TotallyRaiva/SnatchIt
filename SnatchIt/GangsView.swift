// Uses SharedGroup model from Models.swift – no local duplicate definitions.

import SwiftUI

// MARK: - Lightweight ViewModel for the Gangs list
class GangsViewModel: ObservableObject {
    /// All gangs the current user belongs to (loaded from Firestore later)
    @Published var userGangs: [SharedGroup] = []
}

struct GangsView: View {
    @StateObject private var viewModel = GangsViewModel()
    @State private var showCreateSheet = false
    
    /// TODO: Inject the real userId from AuthService
    private let currentUserId = "testUserId"
    
    var body: some View {
        NavigationView {
            List(viewModel.userGangs) { gang in
                NavigationLink(destination: GangDetailsView(
                    gang: gang,
                    isBoss: gang.bosses.contains(currentUserId)
                )) {
                    VStack(alignment: .leading) {
                        Text(gang.name)
                            .font(.headline)
                        Text("Boss: \(gang.bosses.first ?? "Unknown")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Your Gangs")
            .toolbar {
                Button {
                    showCreateSheet = true
                } label: {
                    Label("Create Gang", systemImage: "plus")
                }
            }
            // Present the real CreateGangView from its own file
            .sheet(isPresented: $showCreateSheet) {
                CreateGangView(onComplete: { newGang in
                    viewModel.userGangs.append(newGang)
                    showCreateSheet = false
                }, userId: currentUserId)
            }
        }
    }
}

#Preview {
    GangsView()
}
