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
                    isBoss: gang.bosses.contains(where: { $0 == userId }),
                    currentUserId: userId
                )) {
                    VStack(alignment: .leading) {
                        Text(gang.name)
                            .font(.headline)

                        BossDisplayView(gang: gang, firestoreService: firestoreService)
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
                firestoreService.fetchUserGangs(for: userId) { fetchedGroups in
                    DispatchQueue.main.async {
                        viewModel.userGangs = fetchedGroups
                        
                        let bossIds: [String] = fetchedGroups.compactMap { group in
                            return group.bosses.first
                        }
                        
                        firestoreService.fetchNicknames(for: bossIds)
                    }
                }
            }
        }
    }
}

// MARK: - Helper View for Boss Display
struct BossDisplayView: View {
    let gang: SharedGroup
    @ObservedObject var firestoreService: FirestoreService
    
    var body: some View {
        let bossId = gang.bosses.first ?? ""
        let bossName = firestoreService.userNicknames[bossId] ?? bossId
        
        Text("Boss: \(bossName)")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}

#Preview {
    GangsView(userId: "testUserId", firestoreService: MockFirestoreService())
}

class MockFirestoreService: FirestoreService {
    override func fetchUserGangs(for userId: String, completion: @escaping ([SharedGroup]) -> Void) {
        let mockGangs = [
            SharedGroup(
                id: "1",
                name: "Mock Gang",
                description: "A test gang",
                avatar: "💰",
                members: ["testUserId"],
                bosses: ["testUserId"],
                inviteCode: nil,
                pendingInvites: [],
                createdAt: Date()
            )
        ]
        completion(mockGangs)
    }
    
    override func fetchNicknames(for userIds: [String]) {
        // Mock implementation - set test nicknames
        DispatchQueue.main.async {
            for userId in userIds {
                self.userNicknames[userId] = "Test User"
            }
        }
    }
}
