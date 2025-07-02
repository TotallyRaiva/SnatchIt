//
//  GangDetailsView.swift
//  SnatchIt
//
//  Created by Reiwa on 24.06.2025.
//
import SwiftUI
import FirebaseFirestore
import Combine

/// ViewModel responsible for managing gang details, including sending invites and handling success/error messages.
class GangDetailsViewModel: ObservableObject {
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    let gang: SharedGroup

    init(gang: SharedGroup) {
        self.gang = gang
    }

    /// Attempts to recruit a crew member by email or UID.
    /// - Parameters:
    ///   - invitee: The email or UID of the user to invite.
    ///   - completion: Closure called with success status.
    func recruitCrew(invitee: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        if invitee.contains("@") {
            // Lookup user by email
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
            // Directly send invite by UID
            self.sendGangInvite(uid: invitee, completion: completion)
        }
    }

    /// Sends a gang invite to a user by updating Firestore documents.
    /// - Parameters:
    ///   - uid: User ID to invite.
    ///   - completion: Closure called with success status.
    private func sendGangInvite(uid: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let groupRef = db.collection("groups").document(gang.id ?? "")
        // Add UID to group's pendingInvites array
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
        let userRef = db.collection("users").document(uid)
        // Add gang ID to user's gangInvites array
        userRef.updateData([
            "gangInvites": FieldValue.arrayUnion([gang.id ?? ""])
        ])
    }
}

/// Model representing a crew member's profile for display.
struct CrewMemberProfile: Identifiable {
    let id: String
    let nickname: String
    let avatar: String?
    let isBoss: Bool
}

/// View displaying detailed information about a gang, including crew members, loot, and management options.
struct GangDetailsView: View {
    let gang: SharedGroup
    let isBoss: Bool // True if user is boss
    @StateObject private var viewModel: GangDetailsViewModel

    // State array holding crew member profiles
    @State private var crew: [CrewMemberProfile] = []
    // State holding the boss profile separately for display
    @State private var bossProfile: CrewMemberProfile? = nil
    // Controls display of the recruit crew sheet
    @State private var showRecruitSheet = false
    
    init(gang: SharedGroup, isBoss: Bool, viewModel: GangDetailsViewModel) {
        self.gang = gang
        self.isBoss = isBoss
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            List {
                // Section displaying boss information and gang metadata
                Section {
                    HStack {
                        Text("Gang Boss:")
                        Text(bossProfile?.nickname ?? "Unknown") // Use bossProfile nickname or Unknown
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("Gang Name:")
                        Text(gang.name)
                    }
                    HStack {
                        Text("Description:")
                        Text("-")
                    }
                } header: {
                    Text("Boss Panel")
                }
                
                // Section listing all crew members with indication of boss
                Section {
                    if crew.isEmpty {
                        Text("No crew members")
                    } else {
                        ForEach(crew) { member in
                            HStack {
                                Image(systemName: member.avatar ?? "person.fill")
                                Text(member.nickname)
                                if member.isBoss {
                                    Text("Boss").font(.caption).foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Crew")
                }
                
                // Section for displaying loot or group expenses (currently placeholder)
                Section {
                    // Show group expenses here!
                    Text("No loot yet!") // Placeholder
                } header: {
                    Text("Loot Log")
                }
                
                // Section with management actions available only to the boss
                if isBoss {
                    Section {
                        Button("Recruit Crew") {
                            showRecruitSheet = true
                        }
                        Button("Kick from Gang") { /* Kick flow */ }
                        Button("Rename Gang") { /* Edit flow */ }
                        Button("Bust Up Gang") { /* Delete gang */ }
                            .foregroundColor(.red)
                    } header: {
                        Text("Recruit or Kick Crew")
                    }
                }
                
                // Section for leaving the gang, available to all members
                Section {
                    Button("Drop Out") { /* Leave gang flow */ }
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Gang: \(gang.name)")
            // Sheet for recruiting new crew members
            .sheet(isPresented: $showRecruitSheet) {
                RecruitCrewView { invitee in
                    viewModel.recruitCrew(invitee: invitee) { success in
                        showRecruitSheet = false
                    }
                }
            }
            // Alert to show error or success messages from ViewModel
            .alert(item: Binding<String?>(
                get: {
                    viewModel.errorMessage ?? viewModel.successMessage
                },
                set: { _ in
                    viewModel.errorMessage = nil
                    viewModel.successMessage = nil
                })) { message in
                    Alert(title: Text(message))
                }
            // Fetch crew and boss profiles when view appears
            .onAppear {
                let db = Firestore.firestore()
                var fetchedCrew: [CrewMemberProfile] = []
                let bossId = gang.bosses.first
                
                // Fetch bosses (Boss is first)
                for bossId in gang.bosses {
                    db.collection("users").document(bossId).getDocument { snapshot, error in
                        // Ensure document data exists and no error occurred
                        guard let data = snapshot?.data(), error == nil else { return }
                        let nickname = data["nickname"] as? String ?? "Unknown"
                        let avatar = data["avatar"] as? String
                        let profile = CrewMemberProfile(id: bossId, nickname: nickname, avatar: avatar, isBoss: true)
                        DispatchQueue.main.async {
                            // Update bossProfile state with fetched boss data
                            bossProfile = profile
                            // Append to crew list if not already included
                            if !fetchedCrew.contains(where: { $0.id == profile.id }) {
                                fetchedCrew.append(profile)
                                crew = fetchedCrew
                            }
                        }
                    }
                }
                
                // Fetch regular crew members
                for memberId in gang.members {
                    db.collection("users").document(memberId).getDocument { snapshot, error in
                        // Ensure document data exists and no error occurred
                        guard let data = snapshot?.data(), error == nil else { return }
                        let nickname = data["nickname"] as? String ?? "Unknown"
                        let avatar = data["avatar"] as? String
                        // Determine if this member is also a boss
                        let isBoss = memberId == bossId
                        let profile = CrewMemberProfile(id: memberId, nickname: nickname, avatar: avatar, isBoss: isBoss)
                        DispatchQueue.main.async {
                            // Update bossProfile if this member is boss
                            if isBoss {
                                bossProfile = profile
                            }
                            // Append to crew list if not already included
                            if !fetchedCrew.contains(where: { $0.id == profile.id }) {
                                fetchedCrew.append(profile)
                                crew = fetchedCrew
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let gang = SharedGroup(
        id: "dummyGang",
        name: "Snatchers",
        members: ["uid1", "uid2"],
        bosses: ["uid1"],
        inviteCode: nil,
        createdAt: Date()
    )
    let viewModel = GangDetailsViewModel(gang: gang)
    GangDetailsView(
        gang: gang,
        isBoss: true,
        viewModel: viewModel
    )
}
