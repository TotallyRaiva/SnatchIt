// Uses SharedGroup model from Models.swift – no local duplicate definitions.

import SwiftUI
import Foundation
import FirebaseFirestore


// MARK: - Lightweight ViewModel for the Gangs list
class GangsViewModel: ObservableObject {
    /// All gangs the current user belongs to (loaded from Firestore later)
    @Published var userGangs: [SharedGroup] = []
}

struct GangsView: View {
    var userId: String
    @StateObject private var viewModel = GangsViewModel()
    @ObservedObject var firestoreService: FirestoreService
    @State private var showCreateSheet = false

    var body: some View {
        NavigationView {
            List(viewModel.userGangs) { gang in
                NavigationLink(destination: GangDetailsView(
                    gang: gang,
                    isBoss: gang.bosses.contains(userId)
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
            .sheet(isPresented: $showCreateSheet) {
                CreateGangView(onComplete: { newGang in
                    viewModel.userGangs.append(newGang)
                    showCreateSheet = false
                }, userId: userId)
            }
            .onAppear {
                firestoreService.fetchUserGangs(for: userId) { fetched in
                    viewModel.userGangs = fetched
                }
            }
        }
    }
}


#Preview {
    GangsView(userId: "testUserId", firestoreService: MockFirestoreService())
}

class MockFirestoreService: FirestoreService {
    override func fetchUserGangs(for userId: String, completion: @escaping ([SharedGroup]) -> Void) {
        let mockGangs = [
            SharedGroup(id: "1", name: "Mock Gang", members: ["testUserId"], bosses: ["testUserId"], createdAt: Date())
        ]
        completion(mockGangs)
    }
}
